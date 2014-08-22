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
*/

import QtQuick 2.0
import "Animations"

Item {
    id: root
    objectName: "surfaceContainer"
    property Item surface: null
    property var childSurfaces: surface ? surface.childSurfaces : 0

    onSurfaceChanged: {
        console.log("SURFACE " + surface)
        if (surface) {
            surface.parent = root;
            surface.z = 1;
            state = "initial"
        }
    }

    Connections {
        target: surface
        onRemoved: {
            surface.release();
        }
    }

    Repeater {
        model: root.childSurfaces

        delegate: Loader {
            objectName: "childDelegate" + index
            anchors.fill: root
            z: 2

            // Only way to do recursive qml items.
            source: Qt.resolvedUrl("SurfaceContainer.qml")
            onLoaded: {
                item.surface = modelData;
            }
        }
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: surface; anchors.fill: root }
        }
    ]
}
