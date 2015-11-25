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
    FakeValueSliderFilter(const QString &id, const QString &tag, int value, int minValue, int maxValue, const QMap<int, QString> &labels, QObject* parent);

    QString filterId() const override;
    QString filterTag() const override;
    QString title() const override;

    int value() const override;
    void setValue(int value) override;
    int minValue() const override;
    int maxValue() const override;
    unity::shell::scopes::ValueSliderValuesInterface* values() const override;

    // Not part of the iface, for mock/testing purposes
    bool isActive() const;

    void setTitle(const QString &title);

private:
    QString m_filterId;
    QString m_filterTag;
    QString m_title;

    int m_value;
    int m_minValue;
    int m_maxValue;
    unity::shell::scopes::ValueSliderValuesInterface *m_values;
};

#endif
