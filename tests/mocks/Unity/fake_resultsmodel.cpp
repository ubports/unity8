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
    : QAbstractListModel(parent)
    , m_result_count(result_count)
    , m_categoryId(categoryId)
{
    m_roles[ResultsModel::RoleUri] = "uri";
    m_roles[ResultsModel::RoleCategoryId] = "categoryId";
    m_roles[ResultsModel::RoleDndUri] = "dndUri";
    m_roles[ResultsModel::RoleResult] = "result";
    m_roles[ResultsModel::RoleTitle] = "title";
    m_roles[ResultsModel::RoleArt] = "art";
    m_roles[ResultsModel::RoleSubtitle] = "subtitle";
    m_roles[ResultsModel::RoleMascot] = "mascot";
    m_roles[ResultsModel::RoleEmblem] = "emblem";
    m_roles[ResultsModel::RoleOldPrice] = "oldPrice";
    m_roles[ResultsModel::RolePrice] = "price";
    m_roles[ResultsModel::RoleAltPrice] = "altPrice";
    m_roles[ResultsModel::RoleRating] = "rating";
    m_roles[ResultsModel::RoleAltRating] = "altRating";
    m_roles[ResultsModel::RoleSummary] = "summary";
}

QString ResultsModel::categoryId() const
{
    return QString::number(m_categoryId);
}

void ResultsModel::setCategoryId(QString const& /*id*/)
{
    qFatal("Calling un-implemented ResultsModel::setCategoryId");
}

QHash<int, QByteArray>
ResultsModel::roleNames() const
{
    return m_roles;
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
            return QString("Title.%1.%2 a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a").arg(m_categoryId).arg(index.row());
        case RoleArt:
            return qmlDirectory() + "graphics/applicationIcons/dash.png";
        case RoleSubtitle:
            return QString("Subtitle.%1.%2 a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a").arg(m_categoryId).arg(index.row());
        case RoleMascot:
        case RoleEmblem:
        case RoleOldPrice:
        case RolePrice:
        case RoleAltPrice:
        case RoleRating:
        case RoleAltRating:
        case RoleSummary:
        default:
            return QVariant();
    }
}
