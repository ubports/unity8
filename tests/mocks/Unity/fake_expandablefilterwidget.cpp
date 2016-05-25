/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "fake_expandablefilterwidget.h"

#include "fake_filters.h"

FakeExpandbleFilterWidget::FakeExpandbleFilterWidget(const QString &id, const QString &tag, const QString &title, QObject* parent)
 : unity::shell::scopes::ExpandableFilterWidgetInterface(parent)
 , m_filterId(id)
 , m_filterTag(tag)
 , m_title(title)
{
    m_filters = new Filters(this);
}

QString FakeExpandbleFilterWidget::filterId() const
{
    return m_filterId;
}

QString FakeExpandbleFilterWidget::filterTag() const
{
    return m_filterTag;
}

QString FakeExpandbleFilterWidget::title() const
{
    return m_title;
}

unity::shell::scopes::FiltersInterface* FakeExpandbleFilterWidget::filters() const
{
    return m_filters;
}

void FakeExpandbleFilterWidget::addFilter(unity::shell::scopes::FilterBaseInterface* f)
{
    m_filters->addFilter(f);
}
