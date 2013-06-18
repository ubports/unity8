/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

// libunity-core
#include <UnityCore/Filters.h>

Filters::Filters(unity::dash::Filters::Ptr unityFilters, QObject *parent) :
    QAbstractListModel(parent), m_unityFilters(unityFilters)
{
    QHash<int, QByteArray> roles;
    roles[Filters::RoleFilter] = "filter";
    setRoleNames(roles);

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
    Q_UNUSED(role)

    if (!index.isValid()) {
        return QVariant();
    }

    Filter* filter = m_filters.at(index.row());

    if (role == Filters::RoleFilter) {
        return QVariant::fromValue(filter);
    } else {
        return QVariant();
    }
}

Filter* Filters::getFilter(const QString& id) const
{
    Q_FOREACH (Filter* filter, m_filters) {
        if (filter->id() == id) {
            return filter;
        }
    }
    return NULL;
}

void Filters::onFilterAdded(unity::dash::Filter::Ptr unityFilter)
{
    if (unityFilter == NULL) {
        return;
    }

    /* FIXME: figure out actual index of unityFilter; for now filters are appended */
    int index = m_filters.count();
    addFilter(unityFilter, index);
}

void Filters::onFilterChanged(unity::dash::Filter::Ptr unityFilter)
{
    if (unityFilter == NULL) {
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
    m_filters.insert(index, filter);
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
    int index;
    for (index=0; index<m_filters.count(); index++) {
        if (m_filters[index]->hasUnityFilter(unityFilter)) {
            return index;
        }
    }
    qWarning() << "Filter" << QString::fromStdString(unityFilter->name()) << "not found in local cache.";
    return -1;
}


#include "filters.moc"
