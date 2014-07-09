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
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import Unity.Launcher 0.1

Item {
    id: root

    property bool available: true // can be used to disable all interactions

    property int panelWidth: units.gu(8)
    property int dragAreaWidth: units.gu(1)
    property int minimizeDistance: units.gu(26)
    property real progress: dragArea.dragging && dragArea.touchX > panelWidth ?
                                (width * (dragArea.touchX-panelWidth) / (width - panelWidth)) :
                                (dragArea.dragging ? 0.001 : 0)

    readonly property bool shown: panel.x > -panel.width

    // emitted when an application is selected
    signal launcherApplicationSelected(string appId)

    // emitted when the apps dash should be shown because of a swipe gesture
    signal dash()

    // emitted when the dash icon in the launcher has been tapped
    signal showDashHome()

    onStateChanged: {
        if (state == "") {
            dismissTimer.stop()
        } else {
            dismissTimer.restart()
        }
    }

    function hide() {
        switchToNextState("")
    }

    function fadeOut() {
        fadeOutAnimation.start();
    }

    function switchToNextState(state) {
        animateTimer.nextState = state
        animateTimer.start();
    }

    function tease() {
        if (available) {
            teaseTimer.start();
        }
    }

    Timer {
        id: teaseTimer
        interval: 200
    }

    Timer {
        id: dismissTimer
        interval: 5000
        onTriggered: {
            if (!panel.preventHiding) {
                root.state = ""
            } else {
                dismissTimer.restart()
            }
        }
    }

    // Because the animation on x is disabled while dragging
    // switching state directly in the drag handlers would not animate
    // the completion of the hide/reveal gesture. Lets update the state
    // machine and switch to the final state in the next event loop run
    Timer {
        id: animateTimer
        interval: 1
        property string nextState: ""
        onTriggered: {
            // switching to an intermediate state here to make sure all the
            // values are restored, even if we were already in the target state
            root.state = "tmp"
            root.state = nextState
        }
    }

    SequentialAnimation {
        id: fadeOutAnimation
        ScriptAction {
            script: {
                panel.layer.enabled = true
            }
        }
        UbuntuNumberAnimation {
            target: panel
            property: "opacity"
            easing.type: Easing.InQuad
            to: 0
        }
        ScriptAction {
            script: {
                panel.layer.enabled = false
                panel.animate = false;
                root.state = "";
                panel.x = -panel.width
                panel.opacity = 1;
                panel.animate = true;
            }
        }
    }

    MouseArea {
        id: launcherDragArea
        enabled: root.state == "visible"
        anchors.fill: panel
        anchors.rightMargin: -units.gu(2)
        drag {
            axis: Drag.XAxis
            maximumX: 0
            target: panel
        }

        onReleased: {
            if (panel.x < -panel.width/3) {
                root.switchToNextState("")
            } else {
                root.switchToNextState("visible")
            }
        }

    }
    MouseArea {
        id: closeMouseArea
        anchors {
            left: launcherDragArea.right
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        enabled: root.state == "visible"
        onPressed: {
            root.state = ""
        }
    }

    Rectangle {
        id: backgroundShade
        anchors.fill: parent
        color: "black"
        opacity: root.state == "visible" ? 0.6 : 0

        Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.BriskDuration } }
    }

    LauncherPanel {
        id: panel
        objectName: "launcherPanel"
        enabled: root.available
        width: root.panelWidth
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: -width
        opacity: (x == -width && dragArea.status === DirectionalDragArea.WaitingForTouch) ? 0 : 1
        model: LauncherModel

        property bool animate: true

        onApplicationSelected: {
            root.state = ""
            launcherApplicationSelected(appId)
        }
        onShowDashHome: {
            root.state = ""
            root.showDashHome();
        }

        onPreventHidingChanged: {
            if (dismissTimer.running) {
                dismissTimer.restart();
            }
        }

        Behavior on x {
            enabled: dragArea.dragging || launcherDragArea.drag.active || !panel.animate ?  0 : 300;
            NumberAnimation {
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: UbuntuAnimation.FastDuration; easing.type: Easing.OutCubic
            }
        }
    }

    EdgeDragArea {
        id: dragArea

        direction: Direction.Rightwards

        enabled: root.available
        width: root.dragAreaWidth
        height: root.height

        onTouchXChanged: {
            if (status !== DirectionalDragArea.Recognized || launcher.state == "visible")
                return;

            // When the gesture finally gets recognized, the finger will likely be
            // reasonably far from the edge. If we made the panel immediately
            // follow the finger position it would be visually unpleasant as it
            // would appear right next to the user's finger out of nowhere.
            // Instead, we make the panel go towards the user's finger in several
            // steps. ie., in an animated way.
            var targetPanelX = Math.min(0, touchX - panel.width)
            var delta = targetPanelX - panel.x
            // the trick is not to go all the way (1.0) as it would cause a sudden jump
            panel.x += 0.4 * delta
        }

        onDraggingChanged: {
            if (!dragging) {
                if (distance > panel.width / 2) {
                    if (distance > minimizeDistance) {
                        root.dash()
                    } else {
                        root.switchToNextState("visible")
                    }
                } else {
                    root.switchToNextState("")
                }
            }
        }
    }

    states: [
        State {
            name: "" // hidden state. Must be the default state ("") because "when:" falls back to this.
            PropertyChanges {
                target: panel
                x: -root.panelWidth
            }
        },
        State {
            name: "visible"
            PropertyChanges {
                target: panel
                x: 0
            }
        },
        State {
            name: "teasing"
            when: teaseTimer.running
            PropertyChanges {
                target: panel
                x: -root.panelWidth + units.gu(2)
            }
        }
    ]
}
