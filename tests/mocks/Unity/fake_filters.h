/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef FAKE_FILTERS_H
#define FAKE_FILTERS_H

#include <unity/shell/scopes/FiltersInterface.h>
#include <unity/shell/scopes/FilterBaseInterface.h>

class Scope;

class Filters : public unity::shell::scopes::FiltersInterface
{
    Q_OBJECT

public:
    Filters(Scope* parent);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    int activeFiltersCount() const;

Q_SIGNALS:
    void activeFiltersCountChanged();

private:
    void addFilter(unity::shell::scopes::FilterBaseInterface* f);

    QVector<unity::shell::scopes::FilterBaseInterface*> m_filters;
};

#endif
