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

#ifndef FAKE_EXPANDABLEFILTERWIDGET_H
#define FAKE_EXPANDABLEFILTERWIDGET_H

#include <unity/shell/scopes/ExpandableFilterWidgetInterface.h>

class Filters;

class FakeExpandbleFilterWidget : public unity::shell::scopes::ExpandableFilterWidgetInterface
{
    Q_OBJECT

public:
    FakeExpandbleFilterWidget(const QString &id, const QString &tag, const QString &title, QObject* parent);

    QString filterId() const override;
    QString filterTag() const override;
    QString title() const override;

    unity::shell::scopes::FiltersInterface* filters() const override;

    // mock API
    void addFilter(unity::shell::scopes::FilterBaseInterface* f);

private:
    QString m_filterId;
    QString m_filterTag;
    QString m_title;

    Filters *m_filters;
};

#endif
