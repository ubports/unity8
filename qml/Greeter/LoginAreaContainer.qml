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

import QtQuick 2.4
import "." 0.1

Rectangle {
    height: units.gu(10)
    color: Qt.rgba(0.1, 0.1, 0.1, 0.4)
    border.color: Qt.rgba(0.4, 0.4, 0.4, 0.4)
    border.width: units.dp(1)
    radius: units.gu(1.5)
    antialiasing: true
}
