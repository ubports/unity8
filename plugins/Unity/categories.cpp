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
#include "categoryfilter.h"
#include <QDebug>

Categories::Categories(QObject* parent)
    : DeeListModel(parent)
    , m_resultModel(0)
//    , m_globalResultModel(0)
{
    // FIXME: need to clean up unused filters on countChanged
    m_roles[Categories::RoleId] = "id";
    m_roles[Categories::RoleName] = "name";
    m_roles[Categories::RoleIcon] = "icon";
    m_roles[Categories::RoleRenderer] = "renderer";
    m_roles[Categories::RoleHints] = "hints";
    m_roles[Categories::RoleResults] = "results";
    m_roles[Categories::RoleGlobalResults] = "globalResults";
    m_roles[Categories::RoleCount] = "count";
    m_roles[Categories::RoleGlobalCount] = "globalCount";

    // TODO This should not be needed but accumulatting the count changes
    // makes the visualization more stable and also makes crashes on fast
    // change of the search term harder to reproduce
    m_timer.setSingleShot(true);
    m_timer.setInterval(50);
    connect(&m_timer, SIGNAL(timeout()), this, SLOT(onEmitCountChanged()));
}

Categories::~Categories()
{
    qDeleteAll(m_filters);
//    qDeleteAll(m_globalFilters);
}

CategoryFilter*
Categories::getFilter(int index) const
{
    if (!m_filters.contains(index)) {
        CategoryFilter* filter = new CategoryFilter();
        connect(filter, SIGNAL(countChanged()), this, SLOT(onCountChanged()));
        filter->setModel(m_resultModel);
        filter->setIndex(index);

        m_filters.insert(index, filter);
    }

    return m_filters[index];
}

/*CategoryFilter*
Categories::getGlobalFilter(int index) const
{
    if (!m_globalFilters.contains(index)) {
        CategoryFilter* filter = new CategoryFilter();
        connect(filter, SIGNAL(countChanged()), this, SLOT(onGlobalCountChanged()));
        filter->setModel(m_globalResultModel);
        filter->setIndex(index);

        m_globalFilters.insert(index, filter);
    }

    return m_globalFilters[index];
    }*/

void
Categories::setResultModel(DeeListModel* model)
{
    if (model != m_resultModel) {
        m_resultModel = model;

        Q_FOREACH(CategoryFilter* filter, m_filters) {
            filter->setModel(m_resultModel);
        }

        Q_EMIT resultModelChanged(m_resultModel);
    }
}

/*
void
Categories::setGlobalResultModel(DeeListModel* model)
{
    if (model != m_globalResultModel) {
        m_globalResultModel = model;

        Q_FOREACH(CategoryFilter* filter, m_globalFilters) {
            filter->setModel(m_globalResultModel);
        }

        Q_EMIT globalResultModelChanged(m_globalResultModel);
    }
    }*/

void
Categories::onCountChanged()
{
    CategoryFilter* filter = qobject_cast<CategoryFilter*>(sender());
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
    Q_FOREACH(CategoryFilter* filter, m_timerFilters) {
        QModelIndex changedIndex = index(filter->index());
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    m_timerFilters.clear();
}

/*
void
Categories::onGlobalCountChanged()
{
    CategoryFilter* filter = qobject_cast<CategoryFilter*>(sender());
    if (filter) {
        QModelIndex changedIndex = index(filter->index());
        QVector<int> roles;
        roles.append(Categories::RoleGlobalCount);
        Q_EMIT dataChanged(changedIndex, changedIndex, roles);
    }
    }*/

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

    if (role == RoleId) {
        return QVariant::fromValue(index.row());
    } else if (role == RoleName) {
        return QVariant::fromValue(DeeListModel::data(index, 1)); //DISPLAY_NAME
    } else if (role == RoleIcon) {
        return QVariant::fromValue(DeeListModel::data(index, 2)); //ICON_HINT
    } else if (role == RoleRenderer) {
        return QVariant::fromValue(DeeListModel::data(index, 3)); //RENDERER_NAME
    } else if (role == RoleHints) {
        return QVariant::fromValue(DeeListModel::data(index, 4)); //HINTS
    } else if (role == RoleResults) {
        return QVariant::fromValue(getFilter(index.row()));
    } else if (role == RoleGlobalResults) {
        qWarning() << "GLOBAL RESULTS???";
//        return QVariant::fromValue(getGlobalFilter(index.row()));
        return QVariant();
    } else if (role == RoleCount) {
        CategoryFilter* filter = getFilter(index.row());
        return QVariant::fromValue(filter->rowCount());
    } else if (role == RoleGlobalCount) {
        qWarning() << "GLOBAL COUNT???";
//        QSortFilterProxyModel* filter = getGlobalFilter(index.row());
        //       return QVariant::fromValue(filter->rowCount());
        return QVariant();
    } else {
        return QVariant();
    }
}
