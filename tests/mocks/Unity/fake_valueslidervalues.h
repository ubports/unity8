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

#ifndef FAKE_VALUESLIDERVALUES_H
#define FAKE_VALUESLIDERVALUES_H

#include <unity/shell/scopes/ValueSliderValuesInterface.h>

class FakeValueSliderValues : public unity::shell::scopes::ValueSliderValuesInterface
{
    Q_OBJECT

public:
    FakeValueSliderValues(const QMap<double, QString> &labels, QObject* parent);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    const QMap<double, QString> m_labels;
};

#endif
