/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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

#ifndef DIRECTION_H
#define DIRECTION_H

#include "UbuntuGesturesQmlGlobal.h"
#include <QObject>

/*
    A Direction enum wrapper so that we can do things like "direction: Direction.Righwards"
    from QML.
 */
class UBUNTUGESTURESQML_EXPORT Direction : public QObject {
    Q_OBJECT
    Q_ENUMS(Type)

public:
    // Make sure it is kept synchronized with SDK UCSwipeArea::Direction
    enum Type {
        Rightwards, // Along the positive direction of the X axis
        Leftwards, // Along the negative direction of the X axis
        Downwards, // Along the positive direction of the Y axis
        Upwards, // Along the negative direction of the Y axis
        Horizontal, // Along the X axis, in any direction
        Vertical // Along the Y axis, in any direction
    };

    Q_INVOKABLE static bool isHorizontal(Direction::Type type);
    Q_INVOKABLE static bool isVertical(Direction::Type type);
    Q_INVOKABLE static bool isPositive(Direction::Type type);
};

#endif // DIRECTION_H
