/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Authored by: Nick Dedekind <nick.dedekind@canonical.com
 */

#include "MockTelepathyHelper.h"

MockTelepathyHelper::MockTelepathyHelper(QObject *parent)
    : QObject(parent)
    , m_ready(true)
    , m_emergencyCallsAvailable(true)
{
}

MockTelepathyHelper *MockTelepathyHelper::instance()
{
    static MockTelepathyHelper* helper = new MockTelepathyHelper();
    return helper;
}

void MockTelepathyHelper::registerChannelObserver(const QString& name)
{
    Q_UNUSED(name);
}

bool MockTelepathyHelper::ready() const
{
    return m_ready;
}

void MockTelepathyHelper::setReady(bool value)
{
    if (m_ready != value) {
        m_ready = value;
        Q_EMIT readyChanged();
    }
}
bool MockTelepathyHelper::emergencyCallsAvailable() const
{
    return m_emergencyCallsAvailable;
}

void MockTelepathyHelper::setEmergencyCallsAvailable(bool value)
{
    if (m_emergencyCallsAvailable != value) {
        m_emergencyCallsAvailable = value;
        Q_EMIT emergencyCallsAvailableChanged();
    }
}
