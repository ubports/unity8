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
import Ubuntu.Components 1.3
import Unity.Application 0.1

Column {
    id: root

    Label {text: "Size hints for new surface:"; font.bold: true}

    SurfaceManagerField { text: "min width"; propertyName: "newSurfaceMinimumWidth"; }
    SurfaceManagerField { text: "max width"; propertyName: "newSurfaceMaximumWidth"; }
    SurfaceManagerField { text: "min height"; propertyName: "newSurfaceMinimumHeight"; }
    SurfaceManagerField { text: "max height"; propertyName: "newSurfaceMaximumHeight"; }
    SurfaceManagerField { text: "width increment"; propertyName: "newSurfaceWidthIncrement"; }
    SurfaceManagerField { text: "height increment"; propertyName: "newSurfaceHeightIncrement"; }
}
