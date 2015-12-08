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
    : unity::shell::scopes::CategoriesInterface(parent)
    , m_category_count(category_count)
{
}

int Categories::rowCount(const QModelIndex& /*parent*/) const
{
    return m_category_count;
}

bool Categories::overrideCategoryJson(QString const& /* categoryId */, QString const& /* json */)
{
    qFatal("Using un-implemented Categories::overrideCategoryJson");
}

QVariant
Categories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    ResultsModel *resultsModel = resultModel(index.row());
    switch (role) {
        case RoleCategoryId:
            if (index.row() == 6) {
                return QString("predefined");
            } else if (index.row() == 8) {
                return QString("local");
            } else {
                return QString("%1").arg(index.row());
            }
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
            if (index.row() % 2 == 0) {
                map["category-layout"] = "grid";
            } else {
                map["category-layout"] = "carousel";
            }
            if (index.row() == 18) {
                map["category-layout"] = "horizontal-list";
            }
            if (index.row() == 19) {
                map["category-layout"] = "grid";
                map["collapsed-rows"] = 0;
            }
            map["card-size"] = "small";

            map["category-layout"] = m_layouts.value(index.row(), map["category-layout"].toString());

            if (map["category-layout"] == "carousel") {
                map["overlay"] = true;
            }

            return map;
        }
        case RoleComponents:
        {
            QVariantMap map, artMap, attributeMap;
            if (index.row() % 2 != 0) {
                artMap["aspect-ratio"] = QString("1.%1").arg(index.row());
            } else {
                artMap["aspect-ratio"] = "1.0";
            }
            artMap["field"] = "art";
            map["art"] = artMap;
            map["title"] = "HOLA";
            map["subtitle"] = "HOLA";
            attributeMap["field"] = "attribute";
            map["attributes"] = attributeMap;
            return map;
        }
        case RoleHeaderLink:
        {
            QString res;
            if (index.row() == 1 || index.row() == 4) {
                res = QString("scope://query/1");
            }
            res = m_headerLinks.value(index.row(), res);
            return res;
        }
        case RoleResults:
            return QVariant::fromValue(resultsModel);
        case RoleCount:
            return resultsModel->rowCount();
        default:
            qFatal("Using un-implemented Categories role");
            return QVariant();
    }
}

QVariant
Categories::data(int row, int role) const
{
    return data(index(row, 0), role);
}

void Categories::setCount(int count)
{
    if (m_category_count != count) {
        beginResetModel(); // This is just for test setup so we can be lazy and reset
        m_category_count = count;
        endResetModel();
    }
}

ResultsModel* Categories::resultModel(int row) const
{
    ResultsModel *result = m_resultsModels[row];
    if (!result) {
        Categories *that = const_cast<Categories*>(this);
        result = new ResultsModel(15, row, that);
        m_resultsModels[row] = result;
    }
    return result;
}

void Categories::setLayout(int row, const QString &layout)
{
    m_layouts[row] = layout;
}

void Categories::setHeaderLink(int row, const QString &headerLink)
{
    m_headerLinks[row] = headerLink;
}
