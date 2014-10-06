/*
 * Copyright (C) 2012 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

/* FIXME: This component is duplicating the UbuntuShape from the SDK, but shapes more
 * general (Item-based) components. This ability should be incorporated into the SDK's
 * UbuntuShape so this file can be removed.
 * Bug: https://bugs.launchpad.net/tavastia/+bug/1089595
 */

Item {
    id: root

    property alias radius: shape.radius
    property alias image: source.sourceItem

    ShaderEffectSource {
        id: source
        anchors.centerIn: parent // Placed under shape, so it's hidden
        width: 1
        height: 1
        hideSource: true
    }

    Shape {
        id: shape
        image: source

        anchors.fill: parent
    }
}
