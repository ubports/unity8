/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "quicklistproxymodel.h"

#include <QDebug>

QuickListProxyModel::QuickListProxyModel(QObject *parent):
    QSortFilterProxyModel(parent)
{
    connect(this, &QAbstractListModel::rowsInserted, this, &QuickListProxyModel::countChanged);
    connect(this, &QAbstractListModel::rowsRemoved, this, &QuickListProxyModel::countChanged);
    connect(this, &QAbstractListModel::layoutChanged, this, &QuickListProxyModel::countChanged);
}

QAbstractItemModel *QuickListProxyModel::source() const
{
    return m_source;
}

bool QuickListProxyModel::privateMode() const
{
    return m_privateMode;
}

void QuickListProxyModel::setPrivateMode(bool privateMode)
{
    if (m_privateMode != privateMode) {
        m_privateMode = privateMode;
        invalidateFilter();
        Q_EMIT privateModeChanged();
    }
}

void QuickListProxyModel::setSource(QAbstractItemModel *source)
{
    if (m_source != source) {
        m_source = source;
        setSourceModel(m_source);
        connect(m_source, &QAbstractItemModel::rowsRemoved, this, &QuickListProxyModel::invalidate);
        connect(m_source, &QAbstractItemModel::rowsInserted, this, &QuickListProxyModel::invalidate);
        Q_EMIT sourceChanged();
    }
}

int QuickListProxyModel::count() const
{
    return rowCount();
}

bool QuickListProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    if (m_privateMode) {
        return !m_source->data(m_source->index(source_row, 0), QuickListModelInterface::RoleIsPrivate).toBool();
    }
    return true;
}
