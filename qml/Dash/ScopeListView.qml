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

import QtQuick 2.4
import Dash 0.1

ListViewWithPageHeader {
    maximumFlickVelocity: height * 10
    flickDeceleration: height * 2
    // 1073741823 is s^30 -1. A quite big number so that you have "infinite" cache, but not so
    // big so that if you add if with itself you're outside the 2^31 int range
    cacheBuffer: 1073741823
}
