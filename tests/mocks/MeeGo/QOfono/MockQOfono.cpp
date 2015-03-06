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
 */

#include "MockQOfono.h"

static MockQOfono *m_instance = nullptr;

MockQOfono *MockQOfono::instance()
{
    if (!m_instance) {
        m_instance = new MockQOfono();
    }
    return m_instance;
}

MockQOfono::MockQOfono()
    : QObject(),
      m_available(false),
      m_ready(false),
      m_modems()
{
}

MockQOfono::~MockQOfono()
{
    if (m_instance == this) {
        m_instance = nullptr;
    }
}

bool MockQOfono::available() const
{
    return m_available;
}

void MockQOfono::setAvailable(bool available)
{
    m_available = available;
    Q_EMIT availableChanged();
}

bool MockQOfono::ready() const
{
    return m_ready;
}

void MockQOfono::setReady(bool ready)
{
    m_ready = ready;
    Q_EMIT readyChanged();
}

QStringList MockQOfono::modems() const
{
    return m_modems.keys();
}

void MockQOfono::setModems(const QStringList &modems, const QList<bool> &present, const QList<bool> &ready)
{
    m_modems.clear();
    for (int i = 0; i < modems.length(); i++) {
        QList<bool> props;
        props << present.value(i, true) << ready.value(i, true);
        m_modems[modems[i]] = props;
    }
    Q_EMIT modemsChanged();
}

bool MockQOfono::isModemPresent(const QString &modem)
{
    return m_modems.value(modem).value(0, false);
}

bool MockQOfono::isModemReady(const QString &modem)
{
    return m_modems.value(modem).value(1, false);
}
