/*
 * Copyright 2014-2016 Canonical Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1 // For TouchGate
import Utils 0.1 // for InputWatcher
import Unity.Application 0.1 // for MirSurfaceItem

FocusScope {
    id: root
    objectName: "surfaceContainer"
    implicitWidth: surfaceItem.implicitWidth
    implicitHeight: surfaceItem.implicitHeight

    // Must be set from outside
    property var surface: null

    // Might be changed from outside
    property int requestedWidth: -1
    property int requestedHeight: -1
    property bool interactive
    property int surfaceOrientationAngle: 0
    property bool isPromptSurface: false
    // FIME - dont export, use interactive property. Need to fix qtmir to handle consumesInputChanged
    // to update surface activeFocus. See mock MirSurfaceItem.
    property alias consumesInput: surfaceItem.consumesInput

    onSurfaceChanged: {
        // Not a binding because animations might remove the surface from the surfaceItem
        // programatically (in order to signal that a zombie surface is free for deletion),
        // even though root.surface is still !null.
        surfaceItem.surface = surface;
    }

    InputWatcher {
        target: surfaceItem
        onTargetPressedChanged: {
            if (targetPressed && root.interactive) {
                root.focus = true;
                root.forceActiveFocus();
            }
        }
    }

    MirSurfaceItem {
        id: surfaceItem
        objectName: "surfaceItem"
        anchors.fill: parent

        focus: true

        fillMode: MirSurfaceItem.PadOrCrop
        consumesInput: true

        surfaceWidth: root.requestedWidth
        surfaceHeight: root.requestedHeight

        enabled: root.interactive
        antialiasing: !root.interactive
        orientationAngle: root.surfaceOrientationAngle
    }

    TouchGate {
        targetItem: surfaceItem
        anchors.fill: root
        enabled: surfaceItem.enabled
    }

    Loader {
        id: animationsLoader
        objectName: "animationsLoader"
        active: root.surface
        source: {
            if (root.isPromptSurface) {
                return "PromptSurfaceAnimations.qml";
            } else {
                // Let ApplicationWindow do the animations
                return "";
            }
        }
        Binding {
            target: animationsLoader.item
            when: animationsLoader.item
            property: "surfaceItem"
            value: surfaceItem
        }
        Binding {
            target: animationsLoader.item
            when: animationsLoader.item
            property: "container"
            value: root
        }
    }
}
