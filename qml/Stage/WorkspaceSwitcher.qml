/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Lomiri.Components 1.3
import "Spread"
import WindowManager 1.0
import Unity.Application 0.1

Item {
    id: root

    opacity: d.shown ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { LomiriNumberAnimation {} }

    property var screensProxy: Screens.createProxy();
    property string background

    readonly property alias active: d.active

    function showLeft() {
        show();
        d.previousWorkspace();
    }
    function showRight() {
        show();
        d.nextWorkspace();
    }
    function showUp() {
        show();
        d.previousScreen();
    }
    function showDown() {
        show();
        d.nextScreen();
    }

    function show() {
        hideTimer.stop();
        d.altPressed = true;
        d.ctrlPressed = true;
        d.active = true;
        d.shown = true;
        focus = true;

        d.highlightedScreenIndex = screensProxy.activeScreen;
        var activeScreen = screensProxy.get(screensProxy.activeScreen);
        d.highlightedWorkspaceIndex = activeScreen.workspaces.indexOf(activeScreen.currentWorkspace)
    }

    QtObject {
        id: d

        property bool active: false
        property bool shown: false
        property bool altPressed: false
        property bool ctrlPressed: false

        property int rowHeight: root.height - units.gu(4)

        property int highlightedScreenIndex: -1
        property int highlightedWorkspaceIndex: -1

        function previousWorkspace() {
            highlightedWorkspaceIndex = Math.max(highlightedWorkspaceIndex - 1, 0);
        }
        function nextWorkspace() {
            var screen = screensProxy.get(highlightedScreenIndex);
            highlightedWorkspaceIndex = Math.min(highlightedWorkspaceIndex + 1, screen.workspaces.count - 1);
        }
        function previousScreen() {
            highlightedScreenIndex = Math.max(highlightedScreenIndex - 1, 0);
            var screen = screensProxy.get(highlightedScreenIndex);
            highlightedWorkspaceIndex = Math.min(highlightedWorkspaceIndex, screen.workspaces.count - 1)
        }
        function nextScreen() {
            highlightedScreenIndex = Math.min(highlightedScreenIndex + 1, screensProxy.count - 1);
            var screen = screensProxy.get(highlightedScreenIndex);
            highlightedWorkspaceIndex = Math.min(highlightedWorkspaceIndex, screen.workspaces.count - 1)
        }
    }

    Timer {
        id: hideTimer
        interval: 300
        onTriggered: d.shown = false;
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Left:
            d.previousWorkspace();
            break;
        case Qt.Key_Right:
            d.nextWorkspace()
            break;
        case Qt.Key_Up:
            d.previousScreen();
            break;
        case Qt.Key_Down:
            d.nextScreen();
        }
    }
    Keys.onReleased: {
        switch (event.key) {
        case Qt.Key_Alt:
            d.altPressed = false;
            break;
        case Qt.Key_Control:
            d.ctrlPressed = false;
            break;
        }

        if (!d.altPressed && !d.ctrlPressed) {
            d.active = false;
            hideTimer.start();
            focus = false;
            screensProxy.get(d.highlightedScreenIndex).workspaces.get(d.highlightedWorkspaceIndex).activate();
        }
    }

    LomiriShape {
        backgroundColor: "#F2111111"
        clip: true
        width: Math.min(parent.width, screensColumn.width + units.gu(4))
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height

        Column {
            id: screensColumn
            anchors {
                top: parent.top; topMargin: units.gu(2) - d.highlightedScreenIndex * (d.rowHeight + screensColumn.spacing)
                left: parent.left; leftMargin: units.gu(2)
            }
            width: screensRepeater.itemAt(d.highlightedScreenIndex).width
            spacing: units.gu(2)
            Behavior on anchors.topMargin { LomiriNumberAnimation {} }
            Behavior on width { LomiriNumberAnimation {} }

            Repeater {
                id: screensRepeater
                model: screensProxy

                delegate: Item {
                    height: d.rowHeight
                    width: workspaces.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: d.highlightedScreenIndex == index ? 1 : 0
                    Behavior on opacity { LomiriNumberAnimation {} }

                    LomiriShape {
                        id: header
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        height: units.gu(4)
                        backgroundColor: "white"

                        Label {
                            anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                            text: model.screen.name
                            color: LomiriColors.ash
                        }
                    }

                    Workspaces {
                        id: workspaces
                        height: parent.height - header.height - units.gu(2)
                        width: Math.min(implicitWidth, root.width - units.gu(4))

                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(1)
                        anchors.horizontalCenter: parent.horizontalCenter
                        screen: model.screen
                        background: root.background
                        selectedIndex: d.highlightedScreenIndex == index ? d.highlightedWorkspaceIndex : -1

                        workspaceModel: model.screen.workspaces
                    }
                }
            }
        }
    }
}
