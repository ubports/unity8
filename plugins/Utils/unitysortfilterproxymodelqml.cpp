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
#include "unitysortfilterproxymodelqml.h"

// Qt
#include <QDebug>

UnitySortFilterProxyModelQML::UnitySortFilterProxyModelQML(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_invertMatch(false)
{
    connect(this, &UnitySortFilterProxyModelQML::modelReset, this, &UnitySortFilterProxyModelQML::countChanged);
    connect(this, &UnitySortFilterProxyModelQML::rowsInserted, this, &UnitySortFilterProxyModelQML::countChanged);
    connect(this, &UnitySortFilterProxyModelQML::rowsRemoved, this, &UnitySortFilterProxyModelQML::countChanged);
}

/*
 * Enter row index of filtered/sorted model, returns row index of source model
 */
int UnitySortFilterProxyModelQML::mapRowToSource(int row)
{
    if (sourceModel() == nullptr)
        return -1;

    return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
}

QHash<int, QByteArray> UnitySortFilterProxyModelQML::roleNames() const
{
    return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
}

void
UnitySortFilterProxyModelQML::setModel(QAbstractItemModel *itemModel)
{
    if (itemModel == nullptr) {
        return;
    }

    if (itemModel != sourceModel()) {
        if (sourceModel() != nullptr) {
            sourceModel()->disconnect(this);
        }

        setSourceModel(itemModel);

        connect(itemModel, &QAbstractItemModel::modelReset, this, &UnitySortFilterProxyModelQML::totalCountChanged);
        connect(itemModel, &QAbstractItemModel::rowsInserted, this, &UnitySortFilterProxyModelQML::totalCountChanged);
        connect(itemModel, &QAbstractItemModel::rowsRemoved, this, &UnitySortFilterProxyModelQML::totalCountChanged);

        Q_EMIT totalCountChanged();
        Q_EMIT modelChanged();
    }
}

QVariantMap
UnitySortFilterProxyModelQML::get(int row)
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
UnitySortFilterProxyModelQML::data(int row, int role)
{
    if (sourceModel() == nullptr) {
        return QVariant();
    }

    return index(row, 0).data(role);
}

int
UnitySortFilterProxyModelQML::totalCount() const
{
    if (sourceModel() != nullptr) {
        return sourceModel()->rowCount();
    } else {
        return 0;
    }
}

int
UnitySortFilterProxyModelQML::count()
{
    return rowCount();
}

bool
UnitySortFilterProxyModelQML::invertMatch() const
{
    return m_invertMatch;
}

void
UnitySortFilterProxyModelQML::setInvertMatch(bool invertMatch)
{
    if (invertMatch != m_invertMatch) {
        m_invertMatch = invertMatch;
        Q_EMIT invertMatchChanged(invertMatch);
        invalidateFilter();
    }
}

bool
UnitySortFilterProxyModelQML::filterAcceptsRow(int sourceRow,
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
UnitySortFilterProxyModelQML::findFirst(int role, const QVariant& value) const
{
    QModelIndexList matches = match(index(0, 0), role, value, 1, Qt::MatchExactly);
    if (!matches.isEmpty()) {
        return matches.first().row();
    } else {
        return -1;
    }
}

int
UnitySortFilterProxyModelQML::mapFromSource(int row)
{
    if (sourceModel() != nullptr) {
        return QSortFilterProxyModel::mapFromSource(sourceModel()->index(row, 0)).row();
    } else {
        return -1;
    }
}

int
UnitySortFilterProxyModelQML::mapToSource(int row)
{
    if (sourceModel() != nullptr) {
        return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
    } else {
        return -1;
    }
}
