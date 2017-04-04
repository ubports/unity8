/*
 * Copyright (C) 2014-2017 Canonical, Ltd.
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
import "Spread/MathUtils.js" as MathUtils
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators
import "../Components/PanelState"

FocusScope {
    id: root

    // The DecoratedWindow takes requestedWidth/requestedHeight and asks its surface to be resized to that
    // (minus the window decoration size in case hasDecoration and showDecoration are true)
    // The surface might not be able to resize to the requested values. It will return its actual size
    // in implicitWidth/implicitHeight.

    property alias application: applicationWindow.application
    property alias surface: applicationWindow.surface
    readonly property alias focusedSurface: applicationWindow.focusedSurface
    property alias active: decoration.active
    readonly property alias title: applicationWindow.title
    property alias maximizeButtonShown: decoration.maximizeButtonShown
    property alias interactive: applicationWindow.interactive
    readonly property alias orientationChangesEnabled: applicationWindow.orientationChangesEnabled
    property alias windowControlButtonsVisible: decoration.windowControlButtonsVisible

    // Changing this will actually add/remove a decoration, meaning, requestedHeight will take the decoration into account.
    property bool hasDecoration: true
    // This will temporarily show/hide the decoration without actually changing the surface's dimensions
    property real showDecoration: 1
    property alias decorationHeight: decoration.height
    property bool animateDecoration: false
    property bool showHighlight: false
    property int highlightSize: units.gu(1)
    property real shadowOpacity: 0
    property bool darkening: false

    property real requestedWidth
    property real requestedHeight
    property real scaleToPreviewProgress: 0
    property int scaleToPreviewSize: units.gu(30)

    property alias surfaceOrientationAngle: applicationWindow.surfaceOrientationAngle

    // Height of the decoration that's actually being displayed at this moment. Will match decorationHeight
    // when the decoration is being fully displayed
    readonly property real actualDecorationHeight: Math.min(d.visibleDecorationHeight, d.requestedDecorationHeight)

    readonly property bool counterRotate: surfaceOrientationAngle != 0 && surfaceOrientationAngle != 180

    readonly property int minimumWidth: !counterRotate ? applicationWindow.minimumWidth : applicationWindow.minimumHeight
    readonly property int minimumHeight: actualDecorationHeight + (!counterRotate ? applicationWindow.minimumHeight : applicationWindow.minimumWidth)
    readonly property int maximumWidth: !counterRotate ? applicationWindow.maximumWidth : applicationWindow.maximumHeight
    readonly property int maximumHeight: (root.decorationShown && applicationWindow.maximumHeight > 0 ? decoration.height : 0)
                                         + (!counterRotate ? applicationWindow.maximumHeight : applicationWindow.maximumWidth)
    readonly property int widthIncrement: !counterRotate ? applicationWindow.widthIncrement : applicationWindow.heightIncrement
    readonly property int heightIncrement: !counterRotate ? applicationWindow.heightIncrement : applicationWindow.widthIncrement

    property alias overlayShown: decoration.overlayShown
    property alias boundsItem: moveHandler.boundsItem
    readonly property alias dragging: moveHandler.dragging

    readonly property Item clientAreaItem: applicationWindow

    property alias altDragEnabled: altDragHandler.enabled

    property Item windowMargins

    signal closeClicked()
    signal maximizeClicked()
    signal maximizeHorizontallyClicked()
    signal maximizeVerticallyClicked()
    signal minimizeClicked()
    signal decorationPressed()
    signal decorationReleased()

    function cancelDrag() {
        moveHandler.cancelDrag();
    }

    QtObject {
        id: d
        property int requestedDecorationHeight: root.hasDecoration ? decoration.height : 0
        Behavior on requestedDecorationHeight { enabled: root.animateDecoration; UbuntuNumberAnimation { } }

        property int visibleDecorationHeight: root.hasDecoration ? root.showDecoration * decoration.height : 0
        Behavior on visibleDecorationHeight { enabled: root.animateDecoration; UbuntuNumberAnimation { } }
    }

    StateGroup {
        states: [
            State {
                name: "normal"; when: root.scaleToPreviewProgress <= 0 && root.application.state === ApplicationInfoInterface.Running
                PropertyChanges {
                    target: root
                    implicitWidth: counterRotate ? applicationWindow.implicitHeight : applicationWindow.implicitWidth
                    implicitHeight: root.actualDecorationHeight + (counterRotate ? applicationWindow.implicitWidth:  applicationWindow.implicitHeight)
                }
            },
            State {
                name: "normalSuspended"; when: root.scaleToPreviewProgress <= 0 && root.application.state !== ApplicationInfoInterface.Running
                extend: "normal"
                PropertyChanges {
                    target: root
                    implicitWidth: counterRotate ? applicationWindow.requestedHeight : applicationWindow.requestedWidth
                    implicitHeight: root.actualDecorationHeight + (counterRotate ? applicationWindow.requestedWidth:  applicationWindow.requestedHeight)
                }
            },
            State {
                name: "preview"; when: root.scaleToPreviewProgress > 0
                PropertyChanges {
                    target: root
                    implicitWidth: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedWidth, root.scaleToPreviewSize, root.scaleToPreviewProgress)
                    implicitHeight: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedHeight, root.scaleToPreviewSize, root.scaleToPreviewProgress)
                }
                PropertyChanges {
                    target: applicationWindow;
                    requestedWidth: applicationWindow.oldRequestedWidth
                    requestedHeight: applicationWindow.oldRequestedHeight
                    width: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedWidth, applicationWindow.minSize, root.scaleToPreviewProgress)
                    height: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedHeight, applicationWindow.minSize, root.scaleToPreviewProgress)
                    itemScale: root.implicitWidth / width
                }
            }
        ]
    }

    Rectangle {
        id: selectionHighlight
        objectName: "selectionHighlight"
        anchors.fill: parent
        anchors.margins: -root.highlightSize
        color: "white"
        opacity: showHighlight ? 0.55 : 0
        visible: opacity > 0
    }

    BorderImage {
        id: dropShadow
        anchors {
            left: parent.left; top: parent.top; right: parent.right
            margins: active ? -units.gu(2) : -units.gu(1.5)
        }
        height: Math.min(applicationWindow.implicitHeight, applicationWindow.height) * applicationWindow.itemScale
                + root.actualDecorationHeight * Math.min(1, root.showDecoration) + (active ? units.gu(4) : units.gu(3))
        source: "../graphics/dropshadow2gu.sci"
        opacity: root.shadowOpacity
    }

    ApplicationWindow {
        id: applicationWindow
        objectName: "appWindow"
        anchors.top: parent.top
        anchors.topMargin: root.actualDecorationHeight * Math.min(1, root.showDecoration)
        anchors.left: parent.left
        width: implicitWidth
        height: implicitHeight
        requestedHeight: !counterRotate ? root.requestedHeight - d.requestedDecorationHeight : root.requestedWidth
        requestedWidth: !counterRotate ? root.requestedWidth : root.requestedHeight - d.requestedDecorationHeight
        property int oldRequestedWidth: requestedWidth
        property int oldRequestedHeight: requestedHeight
        onRequestedWidthChanged: oldRequestedWidth = requestedWidth
        onRequestedHeightChanged: oldRequestedHeight = requestedHeight
        focus: true

        property real itemScale: 1
        property real minSize: Math.min(root.scaleToPreviewSize, Math.min(requestedHeight, Math.min(requestedWidth, Math.min(implicitHeight, implicitWidth))))

        transform: [
            Rotation {
                id: rotationTransform
                readonly property int rotationAngle: applicationWindow.application &&
                                                     applicationWindow.application.rotatesWindowContents
                                                     ? ((360 - applicationWindow.surfaceOrientationAngle) % 360) : 0
                origin.x: {
                    if (rotationAngle == 90) return applicationWindow.height / 2;
                    else if (rotationAngle == 270) return applicationWindow.width / 2;
                    else if (rotationAngle == 180) return applicationWindow.width / 2;
                    else return 0;
                }
                origin.y: {
                    if (rotationAngle == 90) return applicationWindow.height / 2;
                    else if (rotationAngle == 270) return applicationWindow.width / 2;
                    else if (rotationAngle == 180) return applicationWindow.height / 2;
                    else return 0;
                }
                angle: rotationAngle
            },
            Scale {
                xScale: applicationWindow.itemScale
                yScale: applicationWindow.itemScale
            }
        ]
    }

    WindowDecoration {
        id: decoration
        closeButtonVisible: true
        objectName: "appWindowDecoration"

        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(3) // a default value. overwritten by root.decorationHeight

        title: applicationWindow.title
        windowMoving: moveHandler.moving && !altDragHandler.dragging

        opacity: root.hasDecoration ? Math.min(1, root.showDecoration) : 0
        Behavior on opacity { UbuntuNumberAnimation { } }
        visible: opacity > 0 // don't eat input when decoration is fully translucent

        onPressed: root.decorationPressed();
        onPressedChanged: moveHandler.handlePressedChanged(pressed, pressedButtons, mouseX, mouseY)
        onPressedChangedEx: moveHandler.handlePressedChanged(pressed, pressedButtons, mouseX, mouseY)
        onPositionChanged: moveHandler.handlePositionChanged(mouse)
        onReleased: {
            root.decorationReleased();
            moveHandler.handleReleased();
        }

        onCloseClicked: root.closeClicked();
        onMaximizeClicked: { root.decorationPressed(); root.maximizeClicked(); }
        onMaximizeHorizontallyClicked: { root.decorationPressed(); root.maximizeHorizontallyClicked(); }
        onMaximizeVerticallyClicked: { root.decorationPressed(); root.maximizeVerticallyClicked(); }
        onMinimizeClicked: root.minimizeClicked();

        enableMenus: {
            return active &&
                     surface &&
                      (PanelState.focusedPersistentSurfaceId === surface.persistentId && !PanelState.decorationsVisible)
        }
        menu: sharedAppModel.model

        Indicators.SharedUnityMenuModel {
            id: sharedAppModel
            property var menus: surface ? ApplicationMenuRegistry.getMenusForSurface(surface.persistentId) : []
            property var menuService: menus.length > 0 ? menus[0] : undefined

            busName: menuService ? menuService.service : ""
            menuObjectPath: menuService && menuService.menuPath ? menuService.menuPath : ""
            actions: menuService && menuService.actionPath ? { "unity": menuService.actionPath } : {}
        }

        Connections {
            target: ApplicationMenuRegistry
            onSurfaceMenuRegistered: {
                if (surface && surfaceId === surface.persistentId) {
                    sharedAppModel.menus = Qt.binding(function() { return surface ? ApplicationMenuRegistry.getMenusForSurface(surface.persistentId) : [] });
                }
            }
            onSurfaceMenuUnregistered: {
                if (surface && surfaceId === surface.persistentId) {
                    sharedAppModel.menus = Qt.binding(function() { return surface ? ApplicationMenuRegistry.getMenusForSurface(surface.persistentId) : [] });
                }
            }
        }
    }

    MouseArea {
        id: altDragHandler
        anchors.fill: applicationWindow
        acceptedButtons: Qt.LeftButton
        property bool dragging: false
        cursorShape: undefined // don't interfere with the cursor shape set by the underlying MirSurfaceItem
        visible: enabled
        onPressed: {
            if (mouse.button == Qt.LeftButton && mouse.modifiers == Qt.AltModifier) {
                root.decorationPressed(); // to raise it
                moveHandler.handlePressedChanged(true, Qt.LeftButton, mouse.x, mouse.y);
                dragging = true;
                mouse.accepted = true;
            } else {
                mouse.accepted = false;
            }
        }
        onPositionChanged: {
            if (dragging) {
                moveHandler.handlePositionChanged(mouse);
            }
        }
        onReleased: {
            if (dragging) {
                moveHandler.handlePressedChanged(false, Qt.LeftButton);
                root.decorationReleased();  // commits the fake preview max rectangle
                moveHandler.handleReleased();
                dragging = false;
            }
        }
    }

    MoveHandler {
        id: moveHandler
        objectName: "moveHandler"
        target: root.parent
        buttonsWidth: decoration.buttonsWidth
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.darkening && !root.showHighlight ? 0.05 : 0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
    }
}
