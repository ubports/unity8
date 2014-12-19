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

MockQOfono::MockQOfono(QObject *parent)
    : QObject(parent),
      m_available(false),
      m_modems()
{
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

QStringList MockQOfono::modems() const
{
    return m_modems.keys();
}

void MockQOfono::setModems(const QStringList &modems, const QList<bool> &present)
{
    m_modems.clear();
    for (int i = 0; i < modems.length(); i++) {
        m_modems[modems[i]] = present[i];
    }
    Q_EMIT modemsChanged();
}

bool MockQOfono::isModemPresent(const QString &modem)
{
    return m_modems.value(modem, false);
}
