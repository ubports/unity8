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

Item {
    id: bottombar
    width: shell.width
    height: shell.height

    property variant theHud
    property bool enabled: false
    readonly property real bottomEdgeButtonCenterDistance: units.gu(34)
    readonly property real bottomEdgeShowButtonDistance: units.gu(2)

    property bool __applicationInFocus: false

    state: "hidden"

    HudButton {
        id: hudButton

        x: MathLocal.clamp(hudButtonRevealer.pressedX - width / 2, 0, bottombar.width - width)
        y: bottombar.height - bottomEdgeButtonCenterDistance - height / 2 - bottomMargin
        Behavior on bottomMargin {
            NumberAnimation{duration: hudButton.opacity < 0.01 ? 200 : 70; easing.type: Easing.OutQuart}
        }
        mouse: {
            if (hudButtonRevealer.draggingArea.pressed) {
                var mapped = mapFromItem(hudButtonRevealer.draggingArea, hudButtonRevealer.draggingArea.mouseX, hudButtonRevealer.draggingArea.mouseY)
                return Qt.point(mapped.x, mapped.y)
            } else {
                return mouse
            }
        }

        Behavior on opacity {
            NumberAnimation{ duration: 200; easing.type: Easing.OutCubic}
        }
    }

    Connections {
        target: theHud
        onShownChanged: bottomBarVisibilityCommunicatorShell.forceHidden = theHud.shown
    }

    function updateApplicationInFocus() {
        if (shell.applicationManager.mainStageFocusedApplication || shell.applicationManager.sideStageFocusedApplication) {
            __applicationInFocus = true
        } else {
            __applicationInFocus = false
        }
    }

    Connections {
        target: shell.applicationManager
        ignoreUnknownSignals: true
        onMainStageFocusedApplicationChanged: updateApplicationInFocus()
        onSideStageFocusedApplicationChanged: updateApplicationInFocus()
    }

    Showable {
        id: hudButtonShowable

        opacity: 1.0
        width: parent.width
        height: bottomEdgeShowButtonDistance
        shown: false
        showAnimation: StandardAnimation { property: "y"; duration: 350; to: hudButtonRevealer.openedValue; easing.type: Easing.OutCubic }
        hideAnimation: StandardAnimation { property: "y"; duration: 350; to: hudButtonRevealer.closedValue; easing.type: Easing.OutCubic }
        onYChanged: {
            if (y == hudButtonRevealer.openedValue)
                bottombar.state = "shown"
        }

        // eater
        MouseArea {
            anchors.fill: parent
        }
    }

    Revealer {
        id: hudButtonRevealer

        property double pressedX

        enabled: !theHud.shown && bottombar.enabled && __applicationInFocus
        direction: Qt.RightToLeft
        openedValue: bottombar.height - height
        closedValue: bottombar.height
        target: hudButtonShowable
        width: hudButtonShowable.width
        height: hudButtonShowable.height
        anchors.bottom: bottombar.bottom
        onOpenPressed: {
            pressedX = mouseX
        }

        onOpenReleased: {
            if (hudButton.opacity != 0 && hudButton.mouseOver) {
                hudButtonShowable.hide()
                theHud.show()
            } else {
                hudButtonShowable.hide()
            }
        }
    }

    Connections {
        target: hudButtonShowable.hideAnimation
        onRunningChanged: {
            if (hudButtonShowable.hideAnimation.running) {
                bottombar.state = "hidden"
            }
        }
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
