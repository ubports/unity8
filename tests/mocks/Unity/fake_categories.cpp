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

Categories::Categories(QObject* parent)
    : DeeListModel(parent)
{
    // FIXME: need to clean up unused filters on countChanged
    m_roles[Categories::RoleId] = "id";
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
        case RoleId:
            return DeeListModel::data(index, 0); //ID
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
