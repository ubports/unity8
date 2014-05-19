/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

import QtQuick 2.0

Item {
    id: root

    signal clicked()
    property real topMarginProgress
    property bool interactive: true

    // FIXME: This really should be invisible to QML code.
    // e.g. Create a SurfaceItem {} in C++ which we just use without any imperative hacks.
    property var surface
    onSurfaceChanged: {
        if (surface) {
            root.width = surface.implicitWidth;
            root.height = surface.implicitHeight;
            surface.parent = root;
            surface.anchors.fill = root;
            surface.enabled = root.interactive;
            surface.z = 1;
        }
    }

    Component.onDestruction: {
        if (surface) {
            surface.release();
        }
    }

    BorderImage {
        id: dropShadow
        anchors.fill: root
        anchors.margins: -units.gu(2)
        source: "graphics/dropshadow.png"
        opacity: .4
        border { left: 50; right: 50; top: 50; bottom: 50 }
    }

    // This is used to get clicked events on the whole app. e.g. when in spreadView.
    // It's only enabled when the surface is !interactive
    MouseArea {
        anchors.fill: parent
        z: 2
        enabled: !root.interactive
        onClicked: {
            root.clicked()
        }
    }
}
