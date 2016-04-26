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

#include "fake_valuesliderfilter.h"
#include "fake_valueslidervalues.h"

FakeValueSliderFilter::FakeValueSliderFilter(const QString &id, const QString &tag, double value, double minValue, double maxValue, const QMap<double, QString> &labels, QObject* parent)
 : unity::shell::scopes::ValueSliderFilterInterface(parent),
   m_filterId(id),
   m_filterTag(tag),
   m_value(value),
   m_minValue(minValue),
   m_maxValue(maxValue),
   m_values(new FakeValueSliderValues(labels, this))
{
}

QString FakeValueSliderFilter::filterId() const
{
    return m_filterId;
}

QString FakeValueSliderFilter::filterTag() const
{
    return m_filterTag;
}

QString FakeValueSliderFilter::title() const
{
    return m_title;
}

double FakeValueSliderFilter::value() const
{
    return m_value;
}

void FakeValueSliderFilter::setValue(double value)
{
    if (value != m_value) {
        m_value = value;
        Q_EMIT valueChanged();
    }
}

double FakeValueSliderFilter::minValue() const
{
    return  m_minValue;
}

double FakeValueSliderFilter::maxValue() const
{
    return  m_maxValue;
}

unity::shell::scopes::ValueSliderValuesInterface* FakeValueSliderFilter::values() const
{
    return m_values;
}

bool FakeValueSliderFilter::isActive() const
{
    // Doesn't really matter
    return false;
}

void FakeValueSliderFilter::setTitle(const QString &title)
{
    m_title = title;
    Q_EMIT titleChanged();
}
