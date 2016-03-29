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

#ifndef FAKE_VALUESLIDERFILTER_H
#define FAKE_VALUESLIDERFILTER_H

#include <unity/shell/scopes/ValueSliderFilterInterface.h>

class FakeValueSliderFilter : public unity::shell::scopes::ValueSliderFilterInterface
{
    Q_OBJECT

public:
    FakeValueSliderFilter(const QString &id, const QString &tag, double value, double minValue, double maxValue, const QMap<double, QString> &labels, QObject* parent);

    QString filterId() const override;
    QString filterTag() const override;
    QString title() const override;

    double value() const override;
    void setValue(double value) override;
    double minValue() const override;
    double maxValue() const override;
    unity::shell::scopes::ValueSliderValuesInterface* values() const override;

    // Not part of the iface, for mock/testing purposes
    bool isActive() const;

    void setTitle(const QString &title);

private:
    QString m_filterId;
    QString m_filterTag;
    QString m_title;

    double m_value;
    double m_minValue;
    double m_maxValue;
    unity::shell::scopes::ValueSliderValuesInterface *m_values;
};

#endif
