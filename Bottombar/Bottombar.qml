/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import "../Components"
import "../Components/Math.js" as MathLocal
import Unity 0.1
import Unity.Application 0.1
import Ubuntu.Gestures 0.1

Item {
    id: bottombar

    // Whether there's an application on foreground (as opposed to have shell's Dash on foreground)
    property bool applicationIsOnForeground

    property variant theHud
    property bool enabled: false
    property bool preventHiding: dragArea.dragging
    readonly property real bottomEdgeButtonCenterDistance: units.gu(34)

    state: "hidden"

    onStateChanged: {
        if (state == "hidden") {
            dismissTimer.stop()
        } else {
            dismissTimer.restart()
        }
    }

    onPreventHidingChanged: {
        if (dismissTimer.running) {
            dismissTimer.restart();
        }
    }

    Timer {
        id: dismissTimer
        interval: 5000
        onTriggered: {
            if (!bottombar.preventHiding) {
                bottombar.state = "hidden"
            } else {
                dismissTimer.restart()
            }
        }
    }

    HudButton {
        id: hudButton

        readonly property bool centeredHud: parent.width < units.gu(68) // Nexus 7 has 67 gu width

        x: centeredHud ? parent.width / 2 - width / 2 : MathLocal.clamp(dragArea.touchStartX - (width / 2), 0, bottombar.width - width)
        y: bottombar.height - bottomEdgeButtonCenterDistance - (height / 2) - bottomMargin
        z: 1
        visible: opacity != 0

        mouseOver: {
            if (dragArea.status === DirectionalDragArea.Recognized) {
                var touchLocal = mapFromItem(dragArea, dragArea.touchX, dragArea.touchY)
                return touchLocal.x > 0 && touchLocal.x < width
                    && touchLocal.y > 0 && touchLocal.y < height
            } else {
                return false
            }
        }

        onClicked: theHud.show()

        Behavior on bottomMargin {
            NumberAnimation{duration: hudButton.opacity < 0.01 ? 200 : 70; easing.type: Easing.OutQuart}
        }

        Behavior on opacity {
            NumberAnimation{duration: 200; easing.type: Easing.OutCubic}
        }
    }

    Connections {
        target: theHud
        onShownChanged: {
            bottomBarVisibilityCommunicatorShell.forceHidden = theHud.shown
            if (theHud.shown) {
                bottombar.state = "hidden"
            }
        }
    }

    EdgeDragArea {
        id: dragArea
        width: parent.width
        height: distanceThreshold
        anchors.bottom: parent.bottom

        distanceThreshold: units.gu(1)
        enabled: !theHud.shown && bottombar.enabled && applicationIsOnForeground
        direction: Direction.Upwards

        property int previousStatus: -1
        property real touchStartX: -1

        onStatusChanged: {
            if (status === DirectionalDragArea.WaitingForTouch) {
                if (previousStatus == DirectionalDragArea.Recognized) {
                    if (hudButton.mouseOver) {
                        hudButton.clicked()
                    } else {
                        bottombar.state = "hidden"
                    }
                }
            } else if (status === DirectionalDragArea.Undecided) {
                if (!hudButton.centeredHud) {
                    touchStartX = touchX
                }
            } else if (status === DirectionalDragArea.Recognized) {
                bottombar.state = "shown"
            }
            previousStatus = status
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: bottombar.state == "shown"
        onPressed: {
            bottombar.state = "hidden"
        }
    }

    InputFilterArea {
        anchors.fill: parent
        blockInput: hudButton.visible
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges { target: hudButton; opacity: 0}
            PropertyChanges { target: hudButton; bottomMargin: units.gu(-1)}
        },
        State {
            name: "shown"
            PropertyChanges { target: hudButton; opacity: 1}
            PropertyChanges { target: hudButton; bottomMargin: units.gu(0)}
        }
    ]
}
