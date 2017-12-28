/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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

FocusScope {
    id: root
    objectName: "childWindow"

    // Set from outside.
    property var surface
    property Item boundsItem
    property Item target
    property alias requestedWidth: surfaceContainer.requestedWidth
    property alias requestedHeight: surfaceContainer.requestedHeight
    property real decorationHeight

    width: surface ? surface.size.width : 0
    height: surface ? surface.size.height : 0

    // Make it get shown and hidden with a fade in/out effect
    opacity: surface && surface.state !== Mir.MinimizedState && surface.state !== Mir.HiddenState ? 1.0 : 0.0
    Behavior on opacity { UbuntuNumberAnimation {} }
    visible: opacity !== 0.0 // make it transparent to input as well

    readonly property bool dragging: windowResizeArea.dragging || d.touchOverlayDragging || d.moveHandlerDragging

    QtObject {
        id: d
        readonly property bool decorated:  surface ? surface.type === Mir.UtilityType
                                                       || surface.type === Mir.DialogType
                                                       || surface.type === Mir.NormalType
                                                       || surface.type === Mir.SatelliteType
                                                   : false

        readonly property bool moveable: decorated
        readonly property bool resizeable: decorated

        property alias decoration: decorationLoader.item
        property alias moveHandler: moveHandlerLoader.item

        readonly property bool touchOverlayDragging: touchOverlayLoader.item ? touchOverlayLoader.item.dragging : false
        readonly property bool moveHandlerDragging: moveHandlerLoader.item ? moveHandlerLoader.item.dragging : false
    }

    WindowResizeArea {
        id: windowResizeArea
        anchors {
            top: decorationLoader.top
            bottom: parent.bottom
            left: parent.left; right: parent.right
        }
        target: root.target
        boundsItem: root.boundsItem
        minWidth: units.gu(10)
        minHeight: units.gu(10)
        borderThickness: units.gu(2)
        enabled: d.resizeable
        visible: enabled
        onPressed: root.surface.activate();
    }

    BorderImage {
        property real shadowThickness: root.surface && root.surface.focused ? units.gu(2) : units.gu(1.5)
        anchors {
            top: decorationLoader.top
            bottom: parent.bottom
            left: parent.left; right: parent.right
            margins: -shadowThickness
        }
        source: "../graphics/dropshadow2gu.sci"
        opacity: .3
    }

    Loader {
        id: decorationLoader
        anchors.bottom: root.top
        anchors.left: root.left
        anchors.right: root.right

        visible: active
        active: d.decorated

        height: item ? item.height : 0

        sourceComponent: Component {
            WindowDecoration {
                id: windowDecoration
                height: root.decorationHeight
                title: root.surface ? root.surface.name : ""
                active: root.surface ? root.surface.focused : false
                minimizeButtonVisible: false
                maximizeButtonShown: false
                onPressed: root.surface.activate();
                onPressedChanged: if (d.moveHandler) { d.moveHandler.handlePressedChanged(pressed, pressedButtons, mouseX, mouseY); }
                onPositionChanged: if (d.moveHandler) {
                    d.moveHandler.handlePositionChanged(mouse);
                }
                onReleased: if (d.moveHandler) { d.moveHandler.handleReleased(); }
                onCloseClicked: root.surface.close();
                Binding {
                    target: root.surface
                    property: "topMargin"
                    value: windowDecoration.height
                }
            }
        }
    }

    Loader {
        id: moveHandlerLoader
        active: d.moveable
        sourceComponent: Component {
            MoveHandler {
                target: root.target
                buttonsWidth: d.decoration ? d.decoration.buttonsWidth : 0
                boundsItem: root.boundsItem
                boundsTopMargin: decorationLoader.height
            }
        }
    }

    SurfaceContainer {
        id: surfaceContainer

        // Do not hold on to a dead surface so that it can be destroyed.
        // FIXME It should not be QML's job to release the MirSurface if its backing surface goes away. Instead backing
        //       MirSurface should go away but the MirSurfaceItem should be able to live on with the last drawn frame
        //       and properties.
        surface: root.surface && root.surface.live ? root.surface : null

        requestedWidth: surface ? surface.size.width : 0
        requestedHeight: surface ? surface.size.height : 0

        // TODO ChildWindow parent will probably want to control those
        interactive: true
        consumesInput: true

        focus: true
    }

    Loader {
        active: d.moveable
        anchors.fill: parent
        sourceComponent: Component {
            MouseArea {
                acceptedButtons: Qt.LeftButton
                property bool dragging: false
                cursorShape: undefined // don't interfere with the cursor shape set by the underlying MirSurfaceItem
                onPressed: {
                    if (mouse.button == Qt.LeftButton && mouse.modifiers == Qt.AltModifier) {
                        d.moveHandler.handlePressedChanged(true, Qt.LeftButton, mouse.x, mouse.y);
                        dragging = true;
                        mouse.accepted = true;
                    } else {
                        mouse.accepted = false;
                    }
                }
                onPositionChanged: {
                    if (dragging) {
                        d.moveHandler.handlePositionChanged(mouse);
                    }
                }
                onReleased: {
                    if (dragging) {
                        d.moveHandler.handlePressedChanged(false, Qt.LeftButton);
                        d.moveHandler.handleReleased();
                        dragging = false;
                    }
                }
            }
        }
    }

    Loader {
        id: touchOverlayLoader
        active: d.resizeable || d.moveable
        anchors.top: decorationLoader.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent: Component { WindowControlsOverlay {
            target: root.target
            resizeArea: windowResizeArea
            boundsItem: root.boundsItem
        } }
    }
}
