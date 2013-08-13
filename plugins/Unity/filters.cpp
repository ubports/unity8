/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

// Self
#include "filters.h"

// Local
#include "filter.h"

// Qt
#include <QDebug>

Filters::Filters(unity::dash::Filters::Ptr unityFilters, QObject *parent) :
    QAbstractListModel(parent), m_unityFilters(unityFilters)
{
    // setup roles
    m_roles[Filters::RoleId] = "id";
    m_roles[Filters::RoleName] = "name";
    m_roles[Filters::RoleIconHint] = "iconHint";
    m_roles[Filters::RoleRendererName] = "rendererName";
    m_roles[Filters::RoleVisible] = "visible";
    m_roles[Filters::RoleCollapsed] = "collapsed";
    m_roles[Filters::RoleFiltering] = "filtering";

    for (unsigned int i=0; i<m_unityFilters->count(); i++) {
        unity::dash::Filter::Ptr unityFilter = m_unityFilters->FilterAtIndex(i);
        addFilter(unityFilter, i);
    }
    m_unityFilters->filter_added.connect(sigc::mem_fun(this, &Filters::onFilterAdded));
    m_unityFilters->filter_changed.connect(sigc::mem_fun(this, &Filters::onFilterChanged));
    m_unityFilters->filter_removed.connect(sigc::mem_fun(this, &Filters::onFilterRemoved));
}

Filters::~Filters()
{
    while (!m_filters.isEmpty()) {
        delete m_filters.takeFirst();
    }
}

int Filters::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)

    return m_unityFilters->count();
}

QVariant Filters::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    Filter* filter = m_filters.at(index.row());
    switch (role)
    {
        case Filters::RoleId:
            return filter->id();
        case Filters::RoleName:
        case Qt::DisplayRole:
            return filter->name();
        case Filters::RoleIconHint:
            return filter->iconHint();
        case Filters::RoleRendererName:
            return filter->rendererName();
        case Filters::RoleVisible:
            return filter->visible();
        case Filters::RoleCollapsed:
            return filter->collapsed();
        case Filters::RoleFiltering:
            return filter->filtering();
        default:
            break;
    }
    return QVariant();
}

QHash<int, QByteArray> Filters::roleNames() const
{
    return m_roles;
}

Filter* Filters::getFilter(const QString& id) const
{
    Q_FOREACH (Filter* filter, m_filters) {
        if (filter->id() == id) {
            return filter;
        }
    }
    return nullptr;
}

void Filters::onFilterAdded(unity::dash::Filter::Ptr unityFilter)
{
    if (unityFilter == nullptr) {
        return;
    }

    int index = m_filters.count();
    addFilter(unityFilter, index);
}

void Filters::onFilterChanged(unity::dash::Filter::Ptr unityFilter)
{
    if (unityFilter == nullptr) {
        return;
    }

    QModelIndex filterIndex = index(indexForFilter(unityFilter));
    Q_EMIT dataChanged(filterIndex, filterIndex);
}

void Filters::onFilterRemoved(unity::dash::Filter::Ptr unityFilter)
{
    removeFilter(indexForFilter(unityFilter));
}

void Filters::addFilter(unity::dash::Filter::Ptr unityFilter, int index)
{
    beginInsertRows(QModelIndex(), index, index);
    Filter* filter = Filter::newFromUnityFilter(unityFilter);
    if (filter != nullptr) {
        m_filters.insert(index, filter);
    }
    endInsertRows();
}

void Filters::removeFilter(int index)
{
    beginRemoveRows(QModelIndex(), index, index);
    Filter* filter = m_filters.takeAt(index);
    delete filter;
    endRemoveRows();
}

int Filters::indexForFilter(unity::dash::Filter::Ptr unityFilter)
{
    for (int index=0; index<m_filters.count(); index++) {
        if (m_filters[index]->hasUnityFilter(unityFilter)) {
            return index;
        }
    }
    qWarning() << "Filter" << QString::fromStdString(unityFilter->name()) << "not found in local cache.";
    return -1;
}
