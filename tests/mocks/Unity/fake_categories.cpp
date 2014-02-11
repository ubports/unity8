/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

// self
#include "fake_categories.h"

#include "fake_resultsmodel.h"

Categories::Categories(int category_count, QObject* parent)
    : QAbstractListModel(parent)
    , m_category_count(category_count)
{
    m_roles[Categories::RoleCategoryId] = "categoryId";
    m_roles[Categories::RoleName] = "name";
    m_roles[Categories::RoleIcon] = "icon";
    m_roles[Categories::RoleRawRendererTemplate] = "rawRendererTemplate";
    m_roles[Categories::RoleRenderer] = "renderer";
    m_roles[Categories::RoleComponents] = "components";
    m_roles[Categories::RoleProgressSource] = "progressSource";
    m_roles[Categories::RoleResults] = "results";
    m_roles[Categories::RoleCount] = "count";
}

QHash<int, QByteArray>
Categories::roleNames() const
{
    return m_roles;
}

int Categories::rowCount(const QModelIndex& /*parent*/) const
{
    return m_category_count;
}


QVariant
Categories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    ResultsModel *resultsModel = m_resultsModels[index.row()];
    if (!resultsModel) {
        resultsModel = new ResultsModel(15, index.row());
        m_resultsModels[index.row()] = resultsModel;
    }
    switch (role) {
        case RoleCategoryId:
            return QString("%1").arg(index.row());
        case RoleName:
            return QString("Category %1").arg(index.row());
        case RoleIcon:
            return "gtk-apply";
        case RoleRawRendererTemplate:
            qFatal("Using un-implemented RoleRawRendererTemplate Categories role");
            return QVariant();
        case RoleRenderer:
        {
            QVariantMap map;
            map["category-layout"] = index.row() % 2 == 0 ? "grid" : "carousel";
            map["card-size"] = "small";
            return map;
        }
        case RoleComponents:
        {
            QVariantMap map, artMap;
            artMap["aspect-ratio"] = "1.0";
            artMap["field"] = "art";
            map["art"] = artMap;
            map["title"] = "HOLA";
            return map;
        }
        case RoleProgressSource:
            qFatal("Using un-implemented RoleProgressSource Categories role");
            return QVariant();
        case RoleResults:
            return QVariant::fromValue(resultsModel);
        case RoleCount:
            return resultsModel->rowCount();
        default:
            qFatal("Using un-implemented Categories role");
            return QVariant();
    }
}
