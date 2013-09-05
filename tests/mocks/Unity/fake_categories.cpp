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

// local
#include "categoryresults.h"

#define CATEGORY_COLUMN 2

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
    // FIXME: need to clean up unused filters on countChanged
    m_roles[Categories::RoleCategoryId] = "categoryId";
    m_roles[Categories::RoleName] = "name";
    m_roles[Categories::RoleIcon] = "icon";
    m_roles[Categories::RoleRenderer] = "renderer";
    m_roles[Categories::RoleContentType] = "contentType";
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

DeeListModel*
Categories::getFilter(int index) const
{
    if (!m_filters.contains(index)) {
        auto results = new CategoryResults ();
        results->setCategoryIndex(index);
        connect(results, SIGNAL(countChanged()), this, SLOT(onCountChanged()));

        unsigned cat_index = static_cast<unsigned>(index);
        auto model = getResultsForCategory(cat_index);
        results->setModel(model);

        m_filters.insert(index, results);
    }

    return m_filters[index];
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

void Categories::onOverrideModelDestroyed()
{
    QObject* model = sender();
    auto iter = m_overriddenCategories.begin();
    while (iter != m_overriddenCategories.end()) {
        if (iter.value() == model) {
            iter = m_overriddenCategories.erase(iter);
            continue;
        }
        ++iter;
    }
}

void Categories::overrideResults(const QString& categoryId, QAbstractItemModel* model)
{
    m_overriddenCategories[categoryId] = model;
    // watch the model
    connect(model, &QObject::destroyed, this, &Categories::onOverrideModelDestroyed);
    connect(model, &QAbstractItemModel::rowsInserted, this, &Categories::onRowCountChanged);
    connect(model, &QAbstractItemModel::rowsRemoved, this, &Categories::onRowCountChanged);
    connect(model, &QAbstractItemModel::modelReset, this, &Categories::onRowCountChanged);

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

void Categories::setResultModel(DeeModel* model)
{
  // FIXME: should ref it
  m_dee_results = model;
}


static void category_filter_map_func (DeeModel* orig_model,
                                      DeeFilterModel* filter_model,
                                      gpointer user_data)
{
    DeeModelIter* iter;
    DeeModelIter* end;
    unsigned index = GPOINTER_TO_UINT(user_data);

    iter = dee_model_get_first_iter(orig_model);
    end = dee_model_get_last_iter(orig_model);
    while (iter != end) {
        unsigned category_index = dee_model_get_uint32(orig_model, iter, CATEGORY_COLUMN);
        if (index == category_index) {
            dee_filter_model_append_iter(filter_model, iter);
        }
        iter = dee_model_next(orig_model, iter);
    }
}

static gboolean category_filter_notify_func (DeeModel* orig_model,
                                             DeeModelIter* orig_iter,
                                             DeeFilterModel* filter_model,
                                             gpointer user_data)
{
    unsigned index = GPOINTER_TO_UINT(user_data);
    unsigned category_index = dee_model_get_uint32(orig_model, orig_iter, CATEGORY_COLUMN);

    if (index != category_index)
        return FALSE;

    dee_filter_model_insert_iter_with_original_order(filter_model, orig_iter);
    return TRUE;
}

DeeModel* Categories::getResultsForCategory(unsigned cat_index) const
{
    DeeFilter filter;
    filter.map_func = category_filter_map_func;
    filter.map_notify = category_filter_notify_func;
    filter.destroy = nullptr;
    filter.userdata = GUINT_TO_POINTER(cat_index);

    DeeModel* filtered_model = dee_filter_model_new(m_dee_results, &filter);
    return filtered_model;
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
            return  hints.contains("content-type") ? hints["content-type"] : QVariant(QString("default"));
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
            return QVariant::fromValue(getFilter(index.row()));
        case RoleCount:
            if (m_overriddenCategories.size() > 0)
            {
                auto id = DeeListModel::data(index, CategoryColumn::ID).toString();
                if (m_overriddenCategories.find(id) != m_overriddenCategories.end())
                    return QVariant::fromValue(m_overriddenCategories[id]->rowCount());
            }
            return QVariant::fromValue(getFilter(index.row())->rowCount());
        default:
            return QVariant();
    }
}
