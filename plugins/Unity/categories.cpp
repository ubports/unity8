/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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
#include "categories.h"
#include "categoryresults.h"

// TODO: use something from libunity once it's public
enum CategoryColumn {
    ID,
    DISPLAY_NAME,
    ICON_HINT,
    RENDERER_NAME,
    HINTS
};

Categories::Categories(QObject* parent)
    : DeeListModel(parent)
{
    m_roles[Categories::RoleCategoryId] = "categoryId";
    m_roles[Categories::RoleName] = "name";
    m_roles[Categories::RoleIcon] = "icon";
    m_roles[Categories::RoleRenderer] = "renderer";
    m_roles[Categories::RoleContentType] = "contentType";
    m_roles[Categories::RoleHints] = "hints";
    m_roles[Categories::RoleResults] = "results";
    m_roles[Categories::RoleCount] = "count";
    m_roles[Categories::RoleCategoryIndex] = "categoryIndex";

    // TODO This should not be needed but accumulatting the count changes
    // makes the visualization more stable and also makes crashes on fast
    // change of the search term harder to reproduce
    m_timer.setSingleShot(true);
    m_timer.setInterval(50);
    connect(&m_timer, &QTimer::timeout, this, &Categories::onEmitCountChanged);
}

DeeListModel*
Categories::getResults(int index) const
{
    if (!m_results.contains(index)) {
        CategoryResults* results = new CategoryResults(const_cast<Categories*>(this));
        results->setCategoryIndex(index);
        connect(results, &DeeListModel::countChanged, this, &Categories::onCountChanged);

        unsigned categoryIndex = static_cast<unsigned>(index);
        auto unity_results = m_unityScope->GetResultsForCategory(categoryIndex);
        results->setModel(unity_results->model());

        m_results.insert(index, results);
    }

    return m_results[index];
}

void Categories::onCategoriesModelChanged(unity::glib::Object<DeeModel> model)
{
    m_updatedCategories.clear();
    // FIXME: this might destroy the renderer view and re-create it, optimize?
    Q_FOREACH(DeeListModel* model, m_results) {
      delete model;
    }
    m_results.clear();
    setModel(model);
}

void
Categories::setUnityScope(const unity::dash::Scope::Ptr& scope)
{
    m_unityScope = scope;

    // no need to call this, we'll get notified
    //setModel(m_unityScope->categories()->model());

    m_categoriesChangedConnection.disconnect();
    m_categoriesChangedConnection =
        m_unityScope->categories()->model.changed.connect(sigc::mem_fun(this, &Categories::onCategoriesModelChanged));
}

void
Categories::onCountChanged()
{
    CategoryResults* results = qobject_cast<CategoryResults*>(sender());
    if (results) {
        m_updatedCategories << results->categoryIndex();
        m_timer.start();
    }
}

void Categories::onRowCountChanged()
{
    QAbstractItemModel* model = qobject_cast<QAbstractItemModel*>(sender());
    // find the corresponding category index
    for (auto iter = m_overriddenCategories.begin(); iter != m_overriddenCategories.end(); ++iter) {
        if (iter.value() == model) {
            for (int i = 0; i < rowCount(); i++) {
                auto id = data(index(i), RoleCategoryId).toString();
                if (id != iter.key()) continue;
                QVector<int> roles;
                roles.append(RoleCount);
                QModelIndex changedIndex = index(i);
                Q_EMIT dataChanged(changedIndex, changedIndex, roles);
                break;
            }
        }
    }
}

void
Categories::onEmitCountChanged()
{
    QVector<int> roles;
    roles.append(Categories::RoleCount);
    Q_FOREACH(int categoryIndex, m_updatedCategories) {
        if (!m_results.contains(categoryIndex)) continue;
        QModelIndex changedIndex = index(categoryIndex);
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    m_updatedCategories.clear();
}

QHash<int, QByteArray>
Categories::roleNames() const
{
    return m_roles;
}

void Categories::overrideResults(const QString& categoryId, QAbstractItemModel* model)
{
    m_overriddenCategories[categoryId] = model;
    // TODO: change the parent of the model?
    connect(model, &QAbstractItemModel::rowsInserted, this, &Categories::onRowCountChanged);
    connect(model, &QAbstractItemModel::rowsRemoved, this, &Categories::onRowCountChanged);

    // emit the dataChanged signal if the category is already in the model
    for (int i = 0; i < rowCount(); i++) {
        auto id = data(index(i), RoleCategoryId).toString();
        if (id != categoryId) continue;
        QVector<int> roles;
        roles.append(RoleCount);
        roles.append(RoleResults);
        QModelIndex changedIndex = index(i);
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
        break;
    }
}

QVariant
Categories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
        case RoleCategoryId:
            return DeeListModel::data(index, CategoryColumn::ID);
        case RoleName:
            return DeeListModel::data(index, CategoryColumn::DISPLAY_NAME);
        case RoleIcon:
            return DeeListModel::data(index, CategoryColumn::ICON_HINT);
        case RoleRenderer:
            return DeeListModel::data(index, CategoryColumn::RENDERER_NAME);
        case RoleContentType:
        {
            auto hints = DeeListModel::data(index, CategoryColumn::HINTS).toHash();
            return hints.contains("content-type") ? hints["content-type"] : QVariant(QString("default"));
        }
        case RoleHints:
            return DeeListModel::data(index, CategoryColumn::HINTS);
        case RoleResults:
            if (m_overriddenCategories.size() > 0)
            {
                auto id = DeeListModel::data(index, CategoryColumn::ID).toString();
                if (m_overriddenCategories.find(id) != m_overriddenCategories.end())
                    return QVariant::fromValue(m_overriddenCategories[id]);
            }
            return QVariant::fromValue(getResults(index.row()));
        case RoleCount:
            if (m_overriddenCategories.size() > 0)
            {
                auto id = DeeListModel::data(index, CategoryColumn::ID).toString();
                if (m_overriddenCategories.find(id) != m_overriddenCategories.end())
                    return QVariant::fromValue(m_overriddenCategories[id]->rowCount());
            }
            return QVariant::fromValue(getResults(index.row())->rowCount());
        case RoleCategoryIndex:
            return QVariant::fromValue(index.row());
        default:
            return QVariant();
    }
}
