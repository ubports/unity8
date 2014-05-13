/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michal Hruby <michal.hruby@canonical.com>
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
#include "fake_resultsmodel.h"

#include <paths.h>

ResultsModel::ResultsModel(int result_count, int categoryId, QObject* parent)
    : m_result_count(result_count)
    , m_categoryId(categoryId)
{
    setParent(parent);
}

QString ResultsModel::categoryId() const
{
    return QString::number(m_categoryId);
}

void ResultsModel::setCategoryId(QString const& /*id*/)
{
    qFatal("Calling un-implemented ResultsModel::setCategoryId");
}

int ResultsModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);

    return m_result_count;
}

int ResultsModel::count() const
{
    return rowCount();
}

QVariant ResultsModel::get(int row) const
{
    if (row >= m_result_count || row < 0) return QVariantMap();

    QVariantMap result;
    QModelIndex modelIndex(index(row));
    QHashIterator<int, QByteArray> it(roleNames());
    while (it.hasNext()) {
        it.next();
        QVariant val(data(modelIndex, it.key()));
        if (val.isNull()) continue;
        result[it.value()] = val;
    }

    return result;
}

QVariant
ResultsModel::data(const QModelIndex& index, int role) const
{
    switch (role) {
        case RoleUri:
        case RoleCategoryId:
        case RoleDndUri:
        case RoleResult:
            return QString();
        case RoleTitle:
            return QString("Title.%1.%2").arg(m_categoryId).arg(index.row());
        case RoleArt:
            return qmlDirectory() + "graphics/applicationIcons/dash.png";
        case RoleSubtitle:
        case RoleMascot:
        case RoleEmblem:
        case RoleSummary:
        default:
            return QVariant();
    }
}
