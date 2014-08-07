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

SurfaceContainer {
    id: container
    property var promptSurfaces

    Repeater {
        model: container.promptSurfaces

        delegate: SurfaceContainer {
            anchors {
                fill: container
                topMargin: container.surface.anchors.topMargin
                rightMargin: container.surface.anchors.rightMargin
                bottomMargin: container.surface.anchors.bottomMargin
                leftMargin: container.surface.anchors.leftMargin
            }

            z: 3 + index
            surface: modelData

            Component.onCompleted: {
                animateIn();
            }
        }
    }
}
