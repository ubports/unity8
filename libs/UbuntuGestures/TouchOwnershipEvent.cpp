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

#include "TouchOwnershipEvent.h"

QEvent::Type TouchOwnershipEvent::m_touchOwnershipType = (QEvent::Type)-1;

TouchOwnershipEvent::TouchOwnershipEvent(int touchId, bool gained)
    : QEvent(touchOwnershipEventType())
    , m_touchId(touchId)
    , m_gained(gained)
{
}

QEvent::Type TouchOwnershipEvent::touchOwnershipEventType()
{
    if (m_touchOwnershipType == (QEvent::Type)-1) {
        m_touchOwnershipType = (QEvent::Type)registerEventType();
    }

    return m_touchOwnershipType;
}
