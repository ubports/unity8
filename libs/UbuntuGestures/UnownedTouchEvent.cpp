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

#include "UnownedTouchEvent.h"

QEvent::Type UnownedTouchEvent::m_unownedTouchEventType = (QEvent::Type)-1;

UnownedTouchEvent::UnownedTouchEvent(QTouchEvent *touchEvent)
    : QEvent(unownedTouchEventType())
    , m_touchEvent(touchEvent)
{
}

QEvent::Type UnownedTouchEvent::unownedTouchEventType()
{
    if (m_unownedTouchEventType == (QEvent::Type)-1) {
        m_unownedTouchEventType = (QEvent::Type)registerEventType();
    }

    return m_unownedTouchEventType;
}

QTouchEvent *UnownedTouchEvent::touchEvent()
{
    return m_touchEvent.data();
}
