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
    return m_category_count + m_specialCategories.count();
}

void Categories::addSpecialCategory(QString const& categoryId, QString const& name, QString const& icon, QString const& rawTemplate, QObject* countObject)
{
    CategoryData catData;
    catData.categoryId = categoryId;
    catData.name = name;
    catData.icon = icon;
    catData.rawTemplate = rawTemplate;
    catData.countObject = countObject;

    beginInsertRows(QModelIndex(), 0, 0);
    m_specialCategories.prepend(catData);
    endInsertRows();

    if (countObject) {
        connect(countObject, SIGNAL(countChanged()), this, SLOT(countChanged()));
    }
}

bool Categories::overrideCategoryJson(QString const& /* categoryId */, QString const& /* json */)
{
    qFatal("Using un-implemented Categories::overrideCategoryJson");
}

void Categories::countChanged()
{
    QObject* countObject = sender();

    for (int i = 0; i < m_specialCategories.count(); ++i) {
        const CategoryData &catData = m_specialCategories.at(i);
        if (catData.countObject == countObject) {
            QVector<int> roles;
            roles.append(RoleCount);

            QModelIndex changedIndex(index(i));
            dataChanged(changedIndex, changedIndex, roles);
            break;
        }
    }
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
    if (index.row() < m_specialCategories.count()) {
        const CategoryData &catData = m_specialCategories.at(index.row());
        switch (role) {
            case RoleCategoryId:
                return catData.categoryId;
            case RoleName:
                return catData.name;
            case RoleIcon:
                return catData.icon;
            case RoleRawRendererTemplate:
                return catData.rawTemplate;
            case RoleRenderer:
            {
                QVariantMap map;
                if (index.row() % 2 == 0) {
                    map["category-layout"] = "grid";
                } else {
                    map["category-layout"] = "carousel";
                    map["overlay"] = true;
                }
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
            case RoleHeaderLink:
                return QString();
            case RoleResults:
                return QVariant();
            case RoleCount:
                return catData.countObject->property("count");
            default:
                qFatal("Using un-implemented Categories role");
                return QVariant();
        }
    } else {
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
                if (index.row() % 2 == 0) {
                    map["category-layout"] = "grid";
                } else {
                    map["category-layout"] = "carousel";
                    map["card-size"] = "medium";
                    map["overlay"] = true;
                }
                if (index.row() == 19) {
                    map["category-layout"] = "grid";
                    map["collapsed-rows"] = 0;
                }
                map["card-size"] = "small";
                return map;
            }
            case RoleComponents:
            {
                QVariantMap map, artMap;
                if (index.row() % 2 != 0) {
                    artMap["aspect-ratio"] = QString("1.%1").arg(index.row());
                } else {
                    artMap["aspect-ratio"] = "1.0";
                }
                artMap["field"] = "art";
                map["art"] = artMap;
                map["title"] = "HOLA";
                map["subtitle"] = "HOLA";
                return map;
            }
            case RoleHeaderLink:
                if (index.row() == 1) {
                    return QString("scope://query/1");
                }
                return QString();
            case RoleResults:
                return QVariant::fromValue(resultsModel);
            case RoleCount:
                return resultsModel->rowCount();
            default:
                qFatal("Using un-implemented Categories role");
                return QVariant();
        }
    }
}

QVariant
Categories::data(int row, int role) const
{
    return data(index(row, 0), role);
}
