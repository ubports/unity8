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

Categories::Categories(QObject* parent)
    : DeeListModel(parent)
    , m_resultModel(0)
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
    qDeleteAll(m_filters);
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
            return QVariant::fromValue(DeeListModel::data(index, 1)); //DISPLAY_NAME
        case RoleIcon:
            return QVariant::fromValue(DeeListModel::data(index, 2)); //ICON_HINT
        case RoleRenderer:
            return QVariant::fromValue(DeeListModel::data(index, 3)); //RENDERER_NAME
        case RoleContentType:
        {
            auto hints = QVariant::fromValue(DeeListModel::data(index, 4)).toHash();
            return hints.contains("content-type") ? hints["content-type"] : QVariant(QString("default"));
        }
        case RoleHints:
            return QVariant::fromValue(DeeListModel::data(index, 4)); //HINTS
        case RoleResults:
            return QVariant::fromValue(getFilter(index.row()));
        case RoleCount:
        {
            CategoryFilter* filter = getFilter(index.row());
            return QVariant::fromValue(filter->rowCount());
        }
        default:
            return QVariant();
    }
}
