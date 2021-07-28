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

#include "Direction.h"

bool Direction::isHorizontal(Direction::Type type)
{
    return type == Direction::Leftwards
        || type == Direction::Rightwards
        || type == Direction::Horizontal;
}

bool Direction::isVertical(Direction::Type type)
{
    return type == Direction::Upwards
        || type == Direction::Downwards
        || type == Direction::Vertical;
}

bool Direction::isPositive(Direction::Type type)
{
    return type == Rightwards
        || type == Downwards
        || type == Horizontal
        || type == Vertical;
}
