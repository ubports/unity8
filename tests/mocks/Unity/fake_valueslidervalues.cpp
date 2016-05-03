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

#include "fake_valueslidervalues.h"

FakeValueSliderValues::FakeValueSliderValues(const QMap<double, QString> &labels, QObject* parent)
 : unity::shell::scopes::ValueSliderValuesInterface(parent)
 , m_labels(labels)
{
}

int FakeValueSliderValues::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_labels.count();
}

QVariant FakeValueSliderValues::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    const int row = index.row();
    auto it = m_labels.begin();
    it += row;

    switch (role) {
        case RoleValue:
            return it.key();

        case RoleLabel:
            return it.value();
    }

    return QVariant();
}
