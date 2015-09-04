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

#include "MockQOfono.h"
#include "MockQOfonoManager.h"
#include <QTimer>

MockQOfonoManager::MockQOfonoManager(QObject *parent)
    : QObject(parent),
      m_modemsSet(false),
      m_startedSet(false)
{
    connect(MockQOfono::instance(), &MockQOfono::availableChanged,
            this, &MockQOfonoManager::availableChanged);
    connect(MockQOfono::instance(), &MockQOfono::readyChanged,
            this, &MockQOfonoManager::checkReady);
    connect(MockQOfono::instance(), &MockQOfono::modemsChanged,
            this, &MockQOfonoManager::maybeModemsChanged);

    checkReady();
}

bool MockQOfonoManager::available() const
{
    return MockQOfono::instance()->available();
}

QStringList MockQOfonoManager::modems() const
{
    return m_modemsSet ? MockQOfono::instance()->modems() : QStringList();
}

void MockQOfonoManager::maybeModemsChanged()
{
    if (m_modemsSet) {
        Q_EMIT modemsChanged();
    }
}

void MockQOfonoManager::checkReady()
{
    if (!m_startedSet && MockQOfono::instance()->ready()) {
        m_startedSet = true;
        // Simulate QOfono's asynchronous initialization
        QTimer::singleShot(1, this, &MockQOfonoManager::setModems);
    }
}

void MockQOfonoManager::setModems()
{
    m_modemsSet = true;
    Q_EMIT modemsChanged(); // always emitted, even if new modem list is empty too
}
