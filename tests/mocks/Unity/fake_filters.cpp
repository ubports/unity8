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

#include "fake_filters.h"

#include "fake_optionselectorfilter.h"
#include "fake_scope.h"

Filters::Filters(Scope* parent)
 : unity::shell::scopes::FiltersInterface(parent)
{
    addFilter(new FakeOptionSelectorFilter("OSF1", "Tag1", "Which Cake you like More", false, QStringList() << "cheese" << "carrot" << "chocolate", this));
    addFilter(new FakeOptionSelectorFilter("OSF2", "Tag2", "Which Countries have you been to?", true, QStringList() << "Germany" << "UK" << "New Zealand", this));
}

void Filters::addFilter(FakeOptionSelectorFilter *f)
{
    connect(f, &FakeOptionSelectorFilter::isActiveChanged, this, &Filters::activeFiltersCountChanged);
    m_filters << f;
}

int Filters::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_filters.count();
}

QVariant Filters::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if (row < 0 || row >= m_filters.count())
        return QVariant();

    unity::shell::scopes::FilterBaseInterface *filter = m_filters[row];

    switch (role) {
        case RoleFilterId:
            return filter->filterId();
        case RoleFilterType:
            return filter->filterType();
        case RoleFilter:
            return QVariant::fromValue<unity::shell::scopes::FilterBaseInterface *>(filter);
        default:
            return QVariant();
    }
}

int Filters::activeFiltersCount() const
{
    int active = 0;
    Q_FOREACH(FakeOptionSelectorFilter *f, m_filters) {
        if (f->isActive()) ++active;
    }
    return active;
}
