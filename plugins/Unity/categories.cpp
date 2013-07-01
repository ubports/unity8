/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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

Categories::Categories(QObject* parent)
    : DeeListModel(parent)
{
    // FIXME: need to clean up unused filters on countChanged
    m_roles[Categories::RoleId] = "id";
    m_roles[Categories::RoleName] = "name";
    m_roles[Categories::RoleIcon] = "icon";
    m_roles[Categories::RoleRenderer] = "renderer";
    m_roles[Categories::RoleContentType] = "content_type";
    m_roles[Categories::RoleHints] = "hints";
    m_roles[Categories::RoleResults] = "results";
    m_roles[Categories::RoleCount] = "count";

    // TODO This should not be needed but accumulatting the count changes
    // makes the visualization more stable and also makes crashes on fast
    // change of the search term harder to reproduce
    m_timer.setSingleShot(true);
    m_timer.setInterval(50);
    connect(&m_timer, SIGNAL(timeout()), this, SLOT(onEmitCountChanged()));
}

Categories::~Categories()
{
}

DeeListModel*
Categories::getFilter(int index) const
{
    if (!m_results.contains(index) || m_results[index].isNull()) {
        auto results = new CategoryResults;
        results->setCategoryIndex(index);
        connect(results, &DeeListModel::countChanged, this, &Categories::onCountChanged);

        unsigned cat_index = static_cast<unsigned>(index);
        auto unity_results = m_unityScope->GetResultsForCategory(cat_index);
        results->setModel(unity_results->model());

        m_results.insert(index, results);
    }

    return m_results[index];
}

void Categories::onCategoriesModelChanged(unity::glib::Object<DeeModel> model)
{
    m_updatedCategories.clear();
    // FIXME: this might destroy the renderer view and re-create it, optimize?
    m_results.clear();
    setModel(model);
}

void
Categories::setUnityScope(const unity::dash::Scope::Ptr& scope)
{
    m_unityScope = scope;

    // no need to call this, we'll get notified
    //setModel(m_unityScope->categories()->model());

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

void
Categories::onEmitCountChanged()
{
    QVector<int> roles;
    roles.append(Categories::RoleCount);
    Q_FOREACH(int cat_index, m_updatedCategories) {
        if (m_results[cat_index].isNull()) continue;
        QModelIndex changedIndex = index(cat_index);
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    m_updatedCategories.clear();
}

QHash<int, QByteArray>
Categories::roleNames() const
{
    return m_roles;
}

QVariant
Categories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
        case RoleId:
            return QVariant::fromValue(index.row());
        case RoleName:
            return DeeListModel::data(index, 1); //DISPLAY_NAME
        case RoleIcon:
            return DeeListModel::data(index, 2); //ICON_HINT
        case RoleRenderer:
            return DeeListModel::data(index, 3); //RENDERER_NAME
        case RoleContentType:
        {
            auto hints = DeeListModel::data(index, 4).toHash();
            return hints.contains("content-type") ? hints["content-type"] : QVariant(QString("default"));
        }
        case RoleHints:
            return DeeListModel::data(index, 4); //HINTS
        case RoleResults:
            return QVariant::fromValue(getFilter(index.row()));
        case RoleCount:
            return QVariant::fromValue(getFilter(index.row())->rowCount());
        default:
            return QVariant();
    }
}
