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

#include "fake_rangeinputfilter.h"

FakeRangeInputFilter::FakeRangeInputFilter(const QString &id, const QString &tag, QObject* parent)
 : unity::shell::scopes::RangeInputFilterInterface(parent),
   m_filterId(id),
   m_filterTag(tag),
   m_hasStartValue(false),
   m_hasEndValue(false),
   m_startValue(-1),
   m_endValue(-1)
{
    connect(this, &FakeRangeInputFilter::hasStartValueChanged, this, &FakeRangeInputFilter::isActiveChanged);
    connect(this, &FakeRangeInputFilter::hasEndValueChanged, this, &FakeRangeInputFilter::isActiveChanged);
}

QString FakeRangeInputFilter::filterId() const
{
    return m_filterId;
}

QString FakeRangeInputFilter::filterTag() const
{
    return m_filterTag;
}

QString FakeRangeInputFilter::title() const
{
    return m_title;
}

double FakeRangeInputFilter::startValue() const
{
    return m_startValue;
}

double FakeRangeInputFilter::endValue() const
{
    return m_endValue;
}

void FakeRangeInputFilter::setStartValue(double value)
{
    if (m_startValue != value) {
        m_startValue = value;
        Q_EMIT startValueChanged();
    }
    if (!m_hasStartValue) {
        m_hasStartValue = true;
        Q_EMIT hasStartValueChanged();
    }
}

void FakeRangeInputFilter::setEndValue(double value)
{
    if (m_endValue != value) {
        m_endValue = value;
        Q_EMIT endValueChanged();
    }
    if (!m_hasEndValue) {
        m_hasEndValue = true;
        Q_EMIT hasEndValueChanged();
    }
}

QString FakeRangeInputFilter::startPrefixLabel() const
{
    return m_startPrefixLabel;
}

QString FakeRangeInputFilter::startPostfixLabel() const
{
    return m_startPostfixLabel;
}

QString FakeRangeInputFilter::centralLabel() const
{
    return m_centralLabel;
}

QString FakeRangeInputFilter::endPrefixLabel() const
{
    return m_endPrefixLabel;
}

QString FakeRangeInputFilter::endPostfixLabel() const
{
    return m_endPostfixLabel;
}

bool FakeRangeInputFilter::hasStartValue() const
{
    return m_hasStartValue;
}

bool FakeRangeInputFilter::hasEndValue() const
{
    return m_hasEndValue;
}

void FakeRangeInputFilter::eraseStartValue()
{
    m_hasStartValue = false;
    Q_EMIT hasStartValueChanged();
}

void FakeRangeInputFilter::eraseEndValue()
{
    m_hasEndValue = false;
    Q_EMIT hasEndValueChanged();
}

bool FakeRangeInputFilter::isActive() const
{
    return hasStartValue() && hasEndValue();
}

void FakeRangeInputFilter::setTitle(const QString &title)
{
    m_title = title;
    Q_EMIT titleChanged();
}

void FakeRangeInputFilter::setStartPrefixLabel(const QString &startPrefixLabel)
{
    m_startPrefixLabel = startPrefixLabel;
    Q_EMIT startPrefixLabelChanged();
}

void FakeRangeInputFilter::setStartPostfixLabel(const QString &startPostfixLabel)
{
    m_startPostfixLabel = startPostfixLabel;
    Q_EMIT startPostfixLabelChanged();
}

void FakeRangeInputFilter::setCentralLabel(const QString &centralLabel)
{
    m_centralLabel = centralLabel;
    Q_EMIT centralLabelChanged();
}

void FakeRangeInputFilter::setEndPrefixLabel(const QString &endPrefixLabel)
{
    m_endPrefixLabel = endPrefixLabel;
    Q_EMIT endPrefixLabelChanged();
}

void FakeRangeInputFilter::setEndPostfixLabel(const QString &endPostfixLabel)
{
    m_endPostfixLabel = endPostfixLabel;
    Q_EMIT endPostfixLabelChanged();
}
