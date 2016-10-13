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

#include "URLDispatcher.h"

#include <QDBusConnection>

URLDispatcher::URLDispatcher(QObject *parent)
  : QObject(parent)
  , m_active(false)
{
}

bool URLDispatcher::active() const
{
    return m_active;
}

void URLDispatcher::setActive(bool value)
{
    if (m_active != value) {
        m_active = value;
        Q_EMIT activeChanged();
    }
}
