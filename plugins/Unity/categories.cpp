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
    if (!m_filters.contains(index)) {
        auto results = std::make_shared<CategoryResults> ();
        results->setCategoryIndex(index);
        connect(results.get(), SIGNAL(countChanged()), this, SLOT(onCountChanged()));

        unsigned cat_index = static_cast<unsigned>(index);
        auto unity_results = m_unityScope->GetResultsForCategory(cat_index);
        results->setModel(unity_results->model());

        m_filters.insert(index, results);
    }

    return m_filters[index].get();
}

void Categories::onCategoriesModelChanged(unity::glib::Object<DeeModel> model)
{
    m_timerFilters.clear();
    m_filters.clear();

    setModel(model);
}

void
Categories::setUnityScope(const unity::dash::Scope::Ptr& scope)
{
    m_unityScope = scope;

    // no need to call this, we'll get notified
    //setModel(m_unityScope->categories()->model());

    m_unityScope->categories()->model.changed.connect(sigc::mem_fun(this, &Categories::onCategoriesModelChanged));

    /*
    if (model != m_resultModel) {
        Q_FOREACH(CategoryFilter* filter, m_filters) {
            filter->setModel(m_resultModel);
        }
    }
    */
}

void
Categories::onCountChanged()
{
    DeeListModel* filter = qobject_cast<DeeListModel*>(sender());
    if (filter) {
        m_timerFilters << filter;
        m_timer.start();
    }
}

void
Categories::onEmitCountChanged()
{
    QVector<int> roles;
    roles.append(Categories::RoleCount);
    Q_FOREACH(DeeListModel* results, m_timerFilters) {
        auto cat_results = qobject_cast<CategoryResults*>(results);
        QModelIndex changedIndex = index(cat_results->categoryIndex());
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    m_timerFilters.clear();
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
