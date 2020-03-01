/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import "../Components"
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import Unity.Launcher 0.1
import Utils 0.1 as Utils

FocusScope {
    id: root

    readonly property int ignoreHideIfMouseOverLauncher: 1

    property bool autohideEnabled: false
    property bool lockedVisible: false
    property bool available: true // can be used to disable all interactions
    property alias inverted: panel.inverted
    property int topPanelHeight: 0
    property bool drawerEnabled: true
    property alias privateMode: panel.privateMode
    property url background

    property int panelWidth: units.gu(10)
    property int dragAreaWidth: units.gu(1)
    property real progress: dragArea.dragging && dragArea.touchPosition.x > panelWidth ?
                                (width * (dragArea.touchPosition.x-panelWidth) / (width - panelWidth)) : 0

    property bool superPressed: false
    property bool superTabPressed: false
    property bool takesFocus: false;

    readonly property bool dragging: dragArea.dragging
    readonly property real dragDistance: dragArea.dragging ? dragArea.touchPosition.x : 0
    readonly property real visibleWidth: panel.width + panel.x
    readonly property alias shortcutHintsShown: panel.shortcutHintsShown

    readonly property bool shown: panel.x > -panel.width
    readonly property bool drawerShown: drawer.x == 0

    // emitted when an application is selected
    signal launcherApplicationSelected(string appId)

    // emitted when the dash icon in the launcher has been tapped
    signal showDashHome()

    onStateChanged: {
        if (state == "") {
            panel.dismissTimer.stop()
        } else {
            panel.dismissTimer.restart()
        }
    }

    onFocusChanged: {if (!focus) { root.takesFocus = false; }}

    onSuperPressedChanged: {
        if (state == "drawer")
            return;

        if (superPressed) {
            superPressTimer.start();
            superLongPressTimer.start();
        } else {
            superPressTimer.stop();
            superLongPressTimer.stop();
            switchToNextState(root.lockedVisible ? "visible" : "");
            panel.shortcutHintsShown = false;
        }
    }

    onSuperTabPressedChanged: {
        if (superTabPressed) {
            switchToNextState("visible")
            panel.highlightIndex = -1;
            root.takesFocus = true;
            root.focus = true;
            superPressTimer.stop();
            superLongPressTimer.stop();
        } else {
            switchToNextState(root.lockedVisible ? "visible" : "");
            root.focus = false;
            if (panel.highlightIndex == -1) {
                root.showDashHome();
            } else if (panel.highlightIndex >= 0){
                launcherApplicationSelected(LauncherModel.get(panel.highlightIndex).appId);
            }
            panel.highlightIndex = -2;
        }
    }

    onLockedVisibleChanged: {
        if (lockedVisible && state == "") {
            panel.dismissTimer.stop();
            fadeOutAnimation.stop();
            switchToNextState("visible")
        } else if (!lockedVisible && state == "visible") {
            hide();
        }
    }

    onPanelWidthChanged: {
        hint();
    }

    // Switches the Launcher to the visible state, but only if it's not already
    // opened.
    // Prevents closing the Drawer when trying to show the Launcher.
    function show() {
        if (state === "" || state === "visibleTemporary") {
            switchToNextState("visible");
        }
    }

    function hide(flags) {
        if ((flags & ignoreHideIfMouseOverLauncher) && Utils.Functions.itemUnderMouse(panel)) {
            if (state == "drawer") {
                switchToNextState("visibleTemporary");
            }
            return;
        }
        if (root.lockedVisible) {
            // Due to binding updates when switching between modes
            // it could happen that our request to show will be overwritten
            // with a hide request. Rewrite it when we know hiding is not allowed.
            switchToNextState("visible")
        } else {
            switchToNextState("")
        }
        root.focus = false;
    }

    function fadeOut() {
        if (!root.lockedVisible) {
            fadeOutAnimation.start();
        }
    }

    function switchToNextState(state) {
        animateTimer.nextState = state
        animateTimer.start();
    }

    function tease() {
        if (available && !dragArea.dragging) {
            teaseTimer.mode = "teasing"
            teaseTimer.start();
        }
    }

    function hint() {
        if (available && root.state == "") {
            teaseTimer.mode = "hinting"
            teaseTimer.start();
        }
    }

    function pushEdge(amount) {
        if (root.state === "" || root.state == "visible" || root.state == "visibleTemporary") {
            edgeBarrier.push(amount);
        }
    }

    function openForKeyboardNavigation() {
        panel.highlightIndex = -1; // The BFB
        drawer.focus = false;
        root.takesFocus = true;
        root.focus = true;
        switchToNextState("visible")
    }

    function toggleDrawer(focusInputField, onlyOpen) {
        if (!drawerEnabled) {
            return;
        }

        panel.shortcutHintsShown = false;
        superPressTimer.stop();
        superLongPressTimer.stop();
        root.takesFocus = true;
        root.focus = true;
        if (focusInputField) {
            drawer.focusInput();
        }
        if (state === "drawer" && !onlyOpen) {
            switchToNextState("visible");
        } else {
            switchToNextState("drawer");
        }
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Backtab:
            panel.highlightPrevious();
            event.accepted = true;
            break;
        case Qt.Key_Up:
            if (root.inverted) {
                panel.highlightNext()
            } else {
                panel.highlightPrevious();
            }
            event.accepted = true;
            break;
        case Qt.Key_Tab:
            panel.highlightNext();
            event.accepted = true;
            break;
        case Qt.Key_Down:
            if (root.inverted) {
                panel.highlightPrevious();
            } else {
                panel.highlightNext();
            }
            event.accepted = true;
            break;
        case Qt.Key_Right:
        case Qt.Key_Menu:
            panel.openQuicklist(panel.highlightIndex)
            event.accepted = true;
            break;
        case Qt.Key_Escape:
            panel.highlightIndex = -2;
            // Falling through intentionally
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Space:
            if (panel.highlightIndex == -1) {
                root.showDashHome();
            } else if (panel.highlightIndex >= 0) {
                launcherApplicationSelected(LauncherModel.get(panel.highlightIndex).appId);
            }
            root.hide();
            panel.highlightIndex = -2
            event.accepted = true;
        }
    }

    Timer {
        id: superPressTimer
        interval: 200
        onTriggered: {
            switchToNextState("visible")
        }
    }

    Timer {
        id: superLongPressTimer
        interval: 1000
        onTriggered: {
            switchToNextState("visible")
            panel.shortcutHintsShown = true;
        }
    }

    Timer {
        id: teaseTimer
        interval: mode == "teasing" ? 200 : 300
        property string mode: "teasing"
    }

    // Because the animation on x is disabled while dragging
    // switching state directly in the drag handlers would not animate
    // the completion of the hide/reveal gesture. Lets update the state
    // machine and switch to the final state in the next event loop run
    Timer {
        id: animateTimer
        objectName: "animateTimer"
        interval: 1
        property string nextState: ""
        onTriggered: {
            // switching to an intermediate state here to make sure all the
            // values are restored, even if we were already in the target state
            root.state = "tmp"
            root.state = nextState
        }
    }

    Connections {
        target: LauncherModel
        onHint: hint();
    }

    Connections {
        target: i18n
        onLanguageChanged: LauncherModel.refresh()
    }

    SequentialAnimation {
        id: fadeOutAnimation
        ScriptAction {
            script: {
                animateTimer.stop(); // Don't change the state behind our back
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

    InverseMouseArea {
        id: closeMouseArea
        anchors.fill: panel
        enabled: (root.state == "visible" && !root.lockedVisible) || root.state == "drawer" || hoverEnabled
        hoverEnabled: panel.quickListOpen
        visible: enabled
        onPressed: {
            mouse.accepted = false;
            panel.highlightIndex = -2;
            root.hide();
        }
    }

    MouseArea {
        id: launcherDragArea
        enabled: root.available && (root.state == "visible" || root.state == "visibleTemporary") && !root.lockedVisible
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

    Drawer {
        id: drawer
        objectName: "drawer"
        anchors {
            top: parent.top
            topMargin: root.inverted ? root.topPanelHeight : 0
            bottom: parent.bottom
            right: parent.left
        }
        background: root.background
        width: Math.min(root.width, units.gu(81))
        panelWidth: panel.width
        allowSlidingAnimation: !dragArea.dragging && !launcherDragArea.drag.active && panel.animate

        onApplicationSelected: {
            root.launcherApplicationSelected(appId)
            root.hide();
            root.focus = false;
        }

        onHideRequested: {
            root.hide();
        }

        onOpenRequested: {
            root.toggleDrawer(false, true);
        }
    }

    LauncherPanel {
        id: panel
        objectName: "launcherPanel"
        enabled: root.available && (root.state == "visible" || root.state == "visibleTemporary" || root.state == "drawer")
        width: root.panelWidth
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: -width
        visible: root.x > 0 || x > -width || dragArea.pressed
        model: LauncherModel

        property var dismissTimer: Timer { interval: 500 }
        Connections {
            target: panel.dismissTimer
            onTriggered: {
                if (root.autohideEnabled && !root.lockedVisible) {
                    if (!edgeBarrier.containsMouse && !panel.preventHiding) {
                        root.state = ""
                    } else {
                        panel.dismissTimer.restart()
                    }
                }
            }
        }

        property bool animate: true

        onApplicationSelected: {
            launcherApplicationSelected(appId);
            root.hide(ignoreHideIfMouseOverLauncher);
        }
        onShowDashHome: {
            root.hide(ignoreHideIfMouseOverLauncher);
            root.showDashHome();
        }

        onPreventHidingChanged: {
            if (panel.dismissTimer.running) {
                panel.dismissTimer.restart();
            }
        }

        onKbdNavigationCancelled: {
            panel.highlightIndex = -2;
            root.hide();
            root.focus = false;
        }

        onDraggingChanged: {
            drawer.unFocusInput()
        }

        Behavior on x {
            enabled: !dragArea.dragging && !launcherDragArea.drag.active && panel.animate;
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: UbuntuAnimation.FastDuration; easing.type: Easing.OutCubic
            }
        }
    }

    EdgeBarrier {
        id: edgeBarrier
        edge: Qt.LeftEdge
        target: parent
        enabled: root.available
        onProgressChanged: {
            if (progress > .5 && root.state != "visibleTemporary" && root.state != "drawer" && root.state != "visible") {
                root.switchToNextState("visibleTemporary");
            }
        }
        onPassed: {
            if (root.drawerEnabled) {
                root.toggleDrawer()
            }
        }

        material: Component {
            Item {
                Rectangle {
                    width: parent.height
                    height: parent.width
                    rotation: -90
                    anchors.centerIn: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(panel.color.r, panel.color.g, panel.color.b, .5)}
                        GradientStop { position: 1.0; color: Qt.rgba(panel.color.r,panel.color.g,panel.color.b,0)}
                    }
                }
            }
        }
    }

    SwipeArea {
        id: dragArea
        objectName: "launcherDragArea"

        direction: Direction.Rightwards

        enabled: root.available
        x: -root.x // so if launcher is adjusted relative to screen, we stay put (like tutorial does when teasing)
        width: root.dragAreaWidth
        height: root.height

        function easeInOutCubic(t) { return t<.5 ? 4*t*t*t : (t-1)*(2*t-2)*(2*t-2)+1 }

        property var lastDragPoints: []

        function dragDirection() {
            if (lastDragPoints.length < 5) {
                return "unknown";
            }

            var toRight = true;
            var toLeft = true;
            for (var i = lastDragPoints.length - 5; i < lastDragPoints.length; i++) {
                if (toRight && lastDragPoints[i] < lastDragPoints[i-1]) {
                    toRight = false;
                }
                if (toLeft && lastDragPoints[i] > lastDragPoints[i-1]) {
                    toLeft = false;
                }
            }
            return toRight ? "right" : toLeft ? "left" : "unknown";
        }

        onDistanceChanged: {
            if (dragging && launcher.state != "visible" && launcher.state != "drawer") {
                panel.x = -panel.width + Math.min(Math.max(0, distance), panel.width);
            }

            if (root.drawerEnabled && dragging && launcher.state != "drawer") {
                lastDragPoints.push(distance)
                var drawerHintDistance = panel.width + units.gu(1)
                if (distance < drawerHintDistance) {
                    drawer.anchors.rightMargin = -Math.min(Math.max(0, distance), drawer.width);
                } else {
                    var linearDrawerX = Math.min(Math.max(0, distance - drawerHintDistance), drawer.width);
                    var linearDrawerProgress = linearDrawerX / (drawer.width)
                    var easedDrawerProgress = easeInOutCubic(linearDrawerProgress);
                    drawer.anchors.rightMargin = -(drawerHintDistance + easedDrawerProgress * (drawer.width - drawerHintDistance));
                }
            }
        }

        onDraggingChanged: {
            if (!dragging) {
                if (distance > panel.width / 2) {
                    if (root.drawerEnabled && distance > panel.width * 3 && dragDirection() !== "left") {
                        root.toggleDrawer(false)
                    } else {
                        root.switchToNextState("visible");
                    }
                } else if (root.state === "") {
                    // didn't drag far enough. rollback
                    root.switchToNextState("");
                }
            }
            lastDragPoints = [];
        }
    }

    states: [
        State {
            name: "" // hidden state. Must be the default state ("") because "when:" falls back to this.
            PropertyChanges {
                target: panel
                x: -root.panelWidth
            }
            PropertyChanges {
                target: drawer
                anchors.rightMargin: 0
                focus: false
            }
        },
        State {
            name: "visible"
            PropertyChanges {
                target: panel
                x: -root.x // so we never go past panelWidth, even when teased by tutorial
                focus: true
            }
            PropertyChanges {
                target: drawer
                anchors.rightMargin: 0
                focus: false
            }
        },
        State {
            name: "drawer"
            extend: "visible"
            PropertyChanges {
                target: drawer
                anchors.rightMargin: -drawer.width + root.x // so we never go past panelWidth, even when teased by tutorial
                focus: true
            }
            PropertyChanges {
                target: panel
            }
        },
        State {
            name: "visibleTemporary"
            extend: "visible"
            PropertyChanges {
                target: root
                autohideEnabled: true
            }
        },
        State {
            name: "teasing"
            when: teaseTimer.running && teaseTimer.mode == "teasing"
            PropertyChanges {
                target: panel
                x: -root.panelWidth + units.gu(2)
            }
        },
        State {
            name: "hinting"
            when: teaseTimer.running && teaseTimer.mode == "hinting"
            PropertyChanges {
                target: panel
                x: 0
            }
        }
    ]
}
