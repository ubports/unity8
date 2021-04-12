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
#include "lomirisortfilterproxymodelqml.h"

// Qt
#include <QDebug>

LomiriSortFilterProxyModelQML::LomiriSortFilterProxyModelQML(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_invertMatch(false)
{
    connect(this, &LomiriSortFilterProxyModelQML::modelReset, this, &LomiriSortFilterProxyModelQML::countChanged);
    connect(this, &LomiriSortFilterProxyModelQML::rowsInserted, this, &LomiriSortFilterProxyModelQML::countChanged);
    connect(this, &LomiriSortFilterProxyModelQML::rowsRemoved, this, &LomiriSortFilterProxyModelQML::countChanged);
}

/*
 * Enter row index of filtered/sorted model, returns row index of source model
 */
int LomiriSortFilterProxyModelQML::mapRowToSource(int row)
{
    if (sourceModel() == nullptr)
        return -1;

    return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
}

QHash<int, QByteArray> LomiriSortFilterProxyModelQML::roleNames() const
{
    return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
}

void
LomiriSortFilterProxyModelQML::setModel(QAbstractItemModel *itemModel)
{
    if (itemModel == nullptr) {
        return;
    }

    if (itemModel != sourceModel()) {
        if (sourceModel() != nullptr) {
            sourceModel()->disconnect(this);
        }

        setSourceModel(itemModel);

        connect(itemModel, &QAbstractItemModel::modelReset, this, &LomiriSortFilterProxyModelQML::totalCountChanged);
        connect(itemModel, &QAbstractItemModel::rowsInserted, this, &LomiriSortFilterProxyModelQML::totalCountChanged);
        connect(itemModel, &QAbstractItemModel::rowsRemoved, this, &LomiriSortFilterProxyModelQML::totalCountChanged);

        Q_EMIT totalCountChanged();
        Q_EMIT modelChanged();
    }
}

QVariantMap
LomiriSortFilterProxyModelQML::get(int row)
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
LomiriSortFilterProxyModelQML::data(int row, int role)
{
    if (sourceModel() == nullptr) {
        return QVariant();
    }

    return index(row, 0).data(role);
}

int
LomiriSortFilterProxyModelQML::totalCount() const
{
    if (sourceModel() != nullptr) {
        return sourceModel()->rowCount();
    } else {
        return 0;
    }
}

int
LomiriSortFilterProxyModelQML::count()
{
    return rowCount();
}

bool
LomiriSortFilterProxyModelQML::invertMatch() const
{
    return m_invertMatch;
}

void
LomiriSortFilterProxyModelQML::setInvertMatch(bool invertMatch)
{
    if (invertMatch != m_invertMatch) {
        m_invertMatch = invertMatch;
        Q_EMIT invertMatchChanged(invertMatch);
        invalidateFilter();
    }
}

bool
LomiriSortFilterProxyModelQML::filterAcceptsRow(int sourceRow,
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
LomiriSortFilterProxyModelQML::findFirst(int role, const QVariant& value) const
{
    QModelIndexList matches = match(index(0, 0), role, value, 1, Qt::MatchExactly);
    if (!matches.isEmpty()) {
        return matches.first().row();
    } else {
        return -1;
    }
}

int
LomiriSortFilterProxyModelQML::mapFromSource(int row)
{
    if (sourceModel() != nullptr) {
        return QSortFilterProxyModel::mapFromSource(sourceModel()->index(row, 0)).row();
    } else {
        return -1;
    }
}

int
LomiriSortFilterProxyModelQML::mapToSource(int row)
{
    if (sourceModel() != nullptr) {
        return QSortFilterProxyModel::mapToSource(index(row, 0)).row();
    } else {
        return -1;
    }
}
