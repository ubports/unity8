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
#include <QDebug>

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
    m_roles[Categories::RoleRendererHint] = "rendererHint";
    m_roles[Categories::RoleProgressSource] = "progressSource";
    m_roles[Categories::RoleHints] = "hints";
    m_roles[Categories::RoleResults] = "results";
    m_roles[Categories::RoleCount] = "count";

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
        if (unity_results) {
            results->setModel(unity_results->model());
        } else {
            // No results model returned by unity core; this can be the case when the global
            // results model of this scope is still not set in unity core. Don't set backend
            // model in DeeListModel - it will still beahve properly as an empty model. Since
            // we're connected to the category model change signal, and it is set by unity core
            // at the same time as results model (on channel opening), we'll reset category
            // results models with proper models when we're notifed again.
            qWarning() << "No results model for category" << categoryIndex;
        }

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
    m_categoryOrder.clear();

    setModel(model);
}

void Categories::onCategoryOrderChanged(const std::vector<unsigned int>& cat_order)
{
    for (unsigned int pos = 0; pos<cat_order.size(); pos++)
    {
        unsigned int cat = cat_order[pos];
        const int old_pos = m_categoryOrder.indexOf(cat);

        if (old_pos < 0) {
            qWarning() << "No such category index:" << cat;
            continue;
        }

        if (static_cast<int>(pos) != old_pos) {
            int target_pos = pos;
            if (target_pos > old_pos)
                target_pos++;
            const bool status = beginMoveRows(QModelIndex(), old_pos, old_pos, QModelIndex(), target_pos);
            if (status)
                m_categoryOrder.move(old_pos, pos);
            else
                qWarning() << "beginMoveRows failed:" << old_pos << target_pos;
            endMoveRows();
        }
    }
}

void
Categories::setUnityScope(const unity::dash::Scope::Ptr& scope)
{
    m_unityScope = scope;

    // no need to call this, we'll get notified
    //setModel(m_unityScope->categories()->model());

    m_signals.disconnectAll();
    m_signals << m_unityScope->categories()->model.changed.connect(sigc::mem_fun(this, &Categories::onCategoriesModelChanged));

    // Don't handle category order changes for now as it causes UI issues (https://bugs.launchpad.net/unity8/+bug/1239584).
    //m_signals << m_unityScope->category_order.changed.connect(sigc::mem_fun(this, &Categories::onCategoryOrderChanged));
}

void
Categories::onCountChanged()
{
    CategoryResults* results = qobject_cast<CategoryResults*>(sender());
    if (results) {
        if (!m_updatedCategories.contains(results->categoryIndex())) {
            m_updatedCategories << results->categoryIndex();
        }
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
        const int realIndex = m_categoryOrder.indexOf(categoryIndex);
        const QModelIndex changedIndex = index(realIndex);
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    m_updatedCategories.clear();
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

QVariant
Categories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (m_categoryOrder.size() != rowCount())
    {
        // populate category order vector with 0..n
        m_categoryOrder.clear();
        const unsigned int lim = rowCount();
        for (unsigned int i = 0; i<lim; i++) {
            m_categoryOrder.append(i);
        }
    }

    int realRow = index.row();
    if (index.row() < m_categoryOrder.size()) {
        realRow = m_categoryOrder[index.row()];
    } else {
        qWarning() << "Invalid index" << index.row();
        return QVariant();
    }

    const QModelIndex realIndex = createIndex(realRow, index.column());

    switch (role) {
        case RoleCategoryId:
            return DeeListModel::data(realIndex, CategoryColumn::ID);
        case RoleName:
            return DeeListModel::data(realIndex, CategoryColumn::DISPLAY_NAME);
        case RoleIcon:
            return DeeListModel::data(realIndex, CategoryColumn::ICON_HINT);
        case RoleRenderer:
            return DeeListModel::data(realIndex, CategoryColumn::RENDERER_NAME);
        case RoleContentType:
        {
            auto hints = DeeListModel::data(realIndex, CategoryColumn::HINTS).toHash();
            return hints.contains("content-type") ? hints["content-type"] : QVariant(QString("default"));
        }
        case RoleRendererHint:
        {
            auto hints = DeeListModel::data(realIndex, CategoryColumn::HINTS).toHash();
            return hints.contains("renderer-hint") ? hints["renderer-hint"] : QVariant(QString());
        }
        case RoleProgressSource:
        {
            auto hints = DeeListModel::data(realIndex, CategoryColumn::HINTS).toHash();
            return hints.contains("progress-source") ? hints["progress-source"] : QVariant();
        }
        case RoleHints:
            return DeeListModel::data(realIndex, CategoryColumn::HINTS);
        case RoleResults:
            if (m_overriddenCategories.size() > 0)
            {
                auto id = DeeListModel::data(realIndex, CategoryColumn::ID).toString();
                if (m_overriddenCategories.find(id) != m_overriddenCategories.end())
                    return QVariant::fromValue(m_overriddenCategories[id]);
            }
            return QVariant::fromValue(getResults(realRow));
        case RoleCount:
            if (m_overriddenCategories.size() > 0)
            {
                auto id = DeeListModel::data(realIndex, CategoryColumn::ID).toString();
                if (m_overriddenCategories.find(id) != m_overriddenCategories.end())
                {
                    return QVariant::fromValue(m_overriddenCategories[id]->rowCount());
                }
            }
            return QVariant::fromValue(getResults(realRow)->rowCount());
        default:
            return QVariant();
    }
}
