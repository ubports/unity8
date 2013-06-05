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
    if (sourceModel() != NULL) {
        sourceModel()->disconnect(this);
    }

    if (itemModel != sourceModel()) {
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
        beginInsertRows(mapFromSource(parent), start, qMin(m_limit - 1, end));
        m_sourceInserting = true;
    }
}

void
QLimitProxyModelQML::sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    if (m_limit < 0) {
        beginRemoveRows(mapFromSource(parent), start, end);
        m_sourceRemoving = true;
    } else if (start < m_limit) {
        beginRemoveRows(mapFromSource(parent), start, qMin(m_limit - 1, end));
        m_sourceRemoving = true;
    }
}

void
QLimitProxyModelQML::sourceRowsInserted(const QModelIndex & /*parent*/, int /*start*/, int /*end*/)
{
    if (m_sourceInserting) {
        endInsertRows();
        m_sourceInserting = false;
    }
}

void
QLimitProxyModelQML::sourceRowsRemoved(const QModelIndex & /*parent*/, int /*start*/, int /*end*/)
{
    if (m_sourceRemoving) {
        endRemoveRows();
        m_sourceRemoving = false;
    }
}
