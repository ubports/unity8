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

#ifndef UBUNTUGESTURES_DEBUG_HELPER_H
#define UBUNTUGESTURES_DEBUG_HELPER_H

#include <QString>

#include "UbuntuGesturesGlobal.h"

class QMouseEvent;
class QTouchEvent;

UBUNTUGESTURES_EXPORT QString touchPointStateToString(Qt::TouchPointState state);
UBUNTUGESTURES_EXPORT QString touchEventToString(const QTouchEvent *ev);
UBUNTUGESTURES_EXPORT QString mouseEventToString(const QMouseEvent *ev);

#endif // UBUNTUGESTURES_DEBUG_HELPER_H
