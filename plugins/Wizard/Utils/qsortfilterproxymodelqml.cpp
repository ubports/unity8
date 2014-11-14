/*
 * Copyright (C) 2012 Canonical, Ltd.
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
#include "qsortfilterproxymodelqml.h"

// Qt
#include <QDebug>

QSortFilterProxyModelQML::QSortFilterProxyModelQML(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_invertMatch(false)
{
    connect(this, SIGNAL(modelReset()), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)), SIGNAL(countChanged()));
}

/*
 * Enter row index of filtered/sorted model, returns row index of source model
 */
int QSortFilterProxyModelQML::mapRowToSource(int row)
{
    if (sourceModel() == NULL)
        return -1;

    return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
}

QHash<int, QByteArray> QSortFilterProxyModelQML::roleNames() const
{
    return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
}

void
QSortFilterProxyModelQML::setModel(QAbstractItemModel *itemModel)
{
    if (itemModel == NULL) {
        return;
    }

    if (itemModel != sourceModel()) {
        if (sourceModel() != NULL) {
            sourceModel()->disconnect(this);
        }

        setSourceModel(itemModel);

        connect(itemModel, SIGNAL(modelReset()), SIGNAL(totalCountChanged()));
        connect(itemModel, SIGNAL(rowsInserted(QModelIndex,int,int)), SIGNAL(totalCountChanged()));
        connect(itemModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), SIGNAL(totalCountChanged()));

        Q_EMIT totalCountChanged();
        Q_EMIT modelChanged();
    }
}

QVariantMap
QSortFilterProxyModelQML::get(int row)
{
    QVariantMap res;
    const QHash<int, QByteArray> roles = roleNames();
    auto it = roles.begin();
    for ( ; it != roles.end(); ++it) {
        res[*it] = data(row, it.key());
    }
    return res;
}

QVariant
QSortFilterProxyModelQML::data(int row, int role)
{
    if (sourceModel() == NULL) {
        return QVariant();
    }

    return index(row, 0).data(role);
}

int
QSortFilterProxyModelQML::totalCount() const
{
    if (sourceModel() != NULL) {
        return sourceModel()->rowCount();
    } else {
        return 0;
    }
}

int
QSortFilterProxyModelQML::count()
{
    return rowCount();
}

bool
QSortFilterProxyModelQML::invertMatch() const
{
    return m_invertMatch;
}

void
QSortFilterProxyModelQML::setInvertMatch(bool invertMatch)
{
    if (invertMatch != m_invertMatch) {
        m_invertMatch = invertMatch;
        Q_EMIT invertMatchChanged(invertMatch);
        invalidateFilter();
    }
}

bool
QSortFilterProxyModelQML::filterAcceptsRow(int sourceRow,
                                           const QModelIndex &sourceParent) const
{
    // If there's no regexp set, always accept all rows indepenently of the invertMatch setting
    if (filterRegExp().isEmpty()) {
        return true;
    }

    bool result = QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    return (m_invertMatch) ? !result : result;
}

int
QSortFilterProxyModelQML::findFirst(int role, const QVariant& value) const
{
    QModelIndexList matches = match(index(0, 0), role, value, 1, Qt::MatchExactly);
    if (!matches.isEmpty()) {
        return matches.first().row();
    } else {
        return -1;
    }
}

int
QSortFilterProxyModelQML::mapFromSource(int row)
{
    if (sourceModel() != NULL) {
        return QSortFilterProxyModel::mapFromSource(sourceModel()->index(row, 0)).row();
    } else {
        return -1;
    }
}

int
QSortFilterProxyModelQML::mapToSource(int row)
{
    if (sourceModel() != NULL) {
        return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
    } else {
        return -1;
    }
}
