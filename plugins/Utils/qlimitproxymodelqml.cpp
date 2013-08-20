/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// self
#include "qlimitproxymodelqml.h"

// Qt
#include <QDebug>

QLimitProxyModelQML::QLimitProxyModelQML(QObject *parent)
    : QIdentityProxyModel(parent)
    , m_limit(-1)
    , m_sourceInserting(false)
    , m_sourceRemoving(false)
    , m_dataChangedBegin(-1)
    , m_dataChangedEnd(-1)
{
    connect(this, SIGNAL(modelReset()), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)), SIGNAL(countChanged()));
}

QHash<int, QByteArray> QLimitProxyModelQML::roleNames() const
{
    return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
}

void
QLimitProxyModelQML::setModel(QAbstractItemModel *itemModel)
{
    if (itemModel != sourceModel()) {
        if (sourceModel() != NULL) {
            sourceModel()->disconnect(this);
        }

        setSourceModel(itemModel);

        if (sourceModel() != NULL) {
            // Disconnect the QIdentityProxyModel handling for rows removed/added...
            disconnect(sourceModel(), SIGNAL(rowsAboutToBeInserted(QModelIndex,int,int)), this, NULL);
            disconnect(sourceModel(), SIGNAL(rowsInserted(QModelIndex,int,int)), this, NULL);
            disconnect(sourceModel(), SIGNAL(rowsAboutToBeRemoved(QModelIndex,int,int)), this, NULL);
            disconnect(sourceModel(), SIGNAL(rowsRemoved(QModelIndex,int,int)), this, NULL);

            // ... and use our own
            connect(sourceModel(), SIGNAL(rowsAboutToBeInserted(QModelIndex,int,int)),
                    this, SLOT(sourceRowsAboutToBeInserted(QModelIndex,int,int)));
            connect(sourceModel(), SIGNAL(rowsInserted(QModelIndex,int,int)),
                    this, SLOT(sourceRowsInserted(QModelIndex,int,int)));
            connect(sourceModel(), SIGNAL(rowsAboutToBeRemoved(QModelIndex,int,int)),
                    this, SLOT(sourceRowsAboutToBeRemoved(QModelIndex,int,int)));
            connect(sourceModel(), SIGNAL(rowsRemoved(QModelIndex,int,int)),
                    this, SLOT(sourceRowsRemoved(QModelIndex,int,int)));
        }
        Q_EMIT modelChanged();
    }
}

int
QLimitProxyModelQML::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) // We are not a tree
        return 0;

    const int unlimitedCount = QIdentityProxyModel::rowCount(parent);
    return m_limit < 0 ? unlimitedCount : qMin(m_limit, unlimitedCount);
}

int
QLimitProxyModelQML::limit() const
{
    return m_limit;
}

void
QLimitProxyModelQML::setLimit(int limit)
{
    if (limit != m_limit) {
        bool inserting = false;
        bool removing = false;
        const int oldCount = rowCount();
        const int unlimitedCount = QIdentityProxyModel::rowCount();
        if (m_limit < 0) {
            if (limit < oldCount) {
                removing = true;
                beginRemoveRows(QModelIndex(), limit, oldCount - 1);
            }
        } else if (limit < 0) {
            if (m_limit < unlimitedCount) {
                inserting = true;
                beginInsertRows(QModelIndex(), m_limit, unlimitedCount - 1);
            }
        } else {
            if (limit > m_limit && unlimitedCount > m_limit) {
                inserting = true;
                beginInsertRows(QModelIndex(), m_limit, qMin(limit, unlimitedCount) - 1);
            } else if (limit < m_limit && limit < oldCount) {
                removing = true;
                beginRemoveRows(QModelIndex(), limit, oldCount - 1);
            }
        }

        m_limit = limit;

        if (inserting) {
            endInsertRows();
        } else if (removing) {
            endRemoveRows();
        }

        Q_EMIT limitChanged();
    }
}

void
QLimitProxyModelQML::sourceRowsAboutToBeInserted(const QModelIndex &parent, int start, int end)
{
    if (m_limit < 0) {
        beginInsertRows(mapFromSource(parent), start, end);
        m_sourceInserting = true;
    } else if (start < m_limit) {
        const int nSourceAddedItems = end - start + 1;
        const int currentCount = QIdentityProxyModel::rowCount();
        if (currentCount + nSourceAddedItems <= m_limit) {
            beginInsertRows(mapFromSource(parent), start, end);
            m_sourceInserting = true;
        } else if (currentCount < m_limit) {
            const int nItemsToInsert = m_limit - currentCount;
            beginInsertRows(mapFromSource(parent), start, start + nItemsToInsert - 1);
            m_sourceInserting = true;
            m_dataChangedBegin = start + nItemsToInsert;
            m_dataChangedEnd = m_limit - 1;
            if (m_dataChangedBegin > m_dataChangedEnd) {
                m_dataChangedBegin = -1;
                m_dataChangedEnd = -1;
            }
        } else {
            m_dataChangedBegin = start;
            m_dataChangedEnd = m_limit - 1;
        }
    }
}

void
QLimitProxyModelQML::sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    if (m_limit < 0) {
        beginRemoveRows(mapFromSource(parent), start, end);
        m_sourceRemoving = true;
    } else if (start < m_limit) {
        const int nSourceRemovedItems = end - start + 1;
        const int currentCount = QIdentityProxyModel::rowCount();
        if (currentCount <= m_limit) {
            beginRemoveRows(mapFromSource(parent), start, end);
            m_sourceRemoving = true;
        } else if (currentCount - nSourceRemovedItems < m_limit) {
            const int nItemsToRemove = m_limit - (currentCount - nSourceRemovedItems);
            beginRemoveRows(mapFromSource(parent), m_limit - nItemsToRemove, m_limit - 1);
            m_sourceRemoving = true;
            m_dataChangedBegin = start;
            m_dataChangedEnd = m_limit - nItemsToRemove - 1;
            if (m_dataChangedBegin > m_dataChangedEnd) {
                m_dataChangedBegin = -1;
                m_dataChangedEnd = -1;
            }
        } else {
            m_dataChangedBegin = start;
            m_dataChangedEnd = m_limit - 1;
        }
    }
}

void
QLimitProxyModelQML::sourceRowsInserted(const QModelIndex & /*parent*/, int /*start*/, int /*end*/)
{
    if (m_sourceInserting) {
        endInsertRows();
        m_sourceInserting = false;
    }
    if (m_dataChangedBegin != -1 && m_dataChangedEnd != -1) {
        dataChanged(index(m_dataChangedBegin, 0), index(m_dataChangedEnd, 0));
        m_dataChangedBegin = -1;
        m_dataChangedEnd = -1;
    }
}

void
QLimitProxyModelQML::sourceRowsRemoved(const QModelIndex & /*parent*/, int /*start*/, int /*end*/)
{
    if (m_sourceRemoving) {
        endRemoveRows();
        m_sourceRemoving = false;
    }
    if (m_dataChangedBegin != -1 && m_dataChangedEnd != -1) {
        dataChanged(index(m_dataChangedBegin, 0), index(m_dataChangedEnd, 0));
        m_dataChangedBegin = -1;
        m_dataChangedEnd = -1;
    }
}
