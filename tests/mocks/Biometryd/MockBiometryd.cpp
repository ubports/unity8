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

#include "MockBiometryd.h"
#include "MockDevice.h"

MockBiometryd::MockBiometryd(QObject *parent)
    : QObject(parent)
    , m_device(new MockDevice(this))
    , m_valid(false)
{
}

MockDevice *MockBiometryd::defaultDevice() const
{
    return m_device;
}

bool MockBiometryd::valid() const
{
    return m_valid;
}

void MockBiometryd::setValid(bool valid)
{
    if (m_valid != valid) {
        m_valid = valid;
        Q_EMIT validChanged();
    }
}
