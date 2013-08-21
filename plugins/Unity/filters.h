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

#ifndef FILTERS_H
#define FILTERS_H

// Qt
#include <QAbstractListModel>
#include <QList>

// libunity-core
#include <UnityCore/Filters.h>
#include <UnityCore/Filter.h>

class Filter;

class Filters : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

public:
    explicit Filters(unity::dash::Filters::Ptr unityFilters, QObject *parent = nullptr);
    ~Filters();

    enum Roles {
        RoleId = Qt::UserRole,
        RoleName,
        RoleIconHint,
        RoleRendererName,
        RoleVisible,
        RoleCollapsed,
        RoleFiltering,
        RoleOptions
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    Filter* getFilter(const QString& id) const;

private:
    void onFilterAdded(unity::dash::Filter::Ptr unityFilter);
    void onFilterChanged(unity::dash::Filter::Ptr unityFilter);
    void onFilterRemoved(unity::dash::Filter::Ptr unityFilter);

    void addFilter(unity::dash::Filter::Ptr unityFilter, int index);
    void removeFilter(int index);

    int indexForFilter(unity::dash::Filter::Ptr unityFilter);

    unity::dash::Filters::Ptr m_unityFilters;
    QList<Filter*> m_filters;
};

Q_DECLARE_METATYPE(Filters*)

#endif // FILTERS_H
