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

#include "fake_optionselectorfilter.h"

#include "fake_optionselectoroptions.h"

FakeOptionSelectorFilter::FakeOptionSelectorFilter(const QString &id, const QString &tag, const QString &label, bool multiselect, const QStringList &optionLabels, QObject* parent)
 : unity::shell::scopes::OptionSelectorFilterInterface(parent),
   m_filterId(id),
   m_filterTag(tag),
   m_label(label),
   m_multiSelect(multiselect)
{
    m_options = new FakeOptionSelectorOptions(optionLabels, this);
    connect(m_options, &FakeOptionSelectorOptions::anyCheckedChanged, this, &FakeOptionSelectorFilter::isActiveChanged);
}

QString FakeOptionSelectorFilter::filterId() const
{
    return m_filterId;
}

QString FakeOptionSelectorFilter::filterTag() const
{
    return m_filterTag;
}

QString FakeOptionSelectorFilter::title() const
{
    return m_title;
}

QString FakeOptionSelectorFilter::label() const
{
    return m_label;
}

bool FakeOptionSelectorFilter::multiSelect() const
{
    return m_multiSelect;
}

unity::shell::scopes::OptionSelectorOptionsInterface* FakeOptionSelectorFilter::options() const
{
    return m_options;
}

bool FakeOptionSelectorFilter::isActive() const
{
    return m_options->anyChecked();
}

void FakeOptionSelectorFilter::clear()
{
    m_options->clear();
}
