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
import Ubuntu.Components 1.3
import "Spread"
import WindowManager 1.0
import Unity.Application 0.1

UbuntuShape {
    id: root

    backgroundColor: "#F2111111"
    width: screensRow.childrenRect.width + units.gu(4)
    opacity: d.shown ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { UbuntuNumberAnimation {} }

    property var screensProxy: Screens.createProxy();
    property string background

    readonly property alias active: d.active

    function showLeft() {
        show();
        d.decreaseHighlight();
    }
    function showRight() {
        show();
        d.increaseHighlight();
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

        property int highlightedScreenIndex: -1
        property int highlightedWorkspaceIndex: -1

        function increaseHighlight() {
            var screen = screensProxy.get(highlightedScreenIndex);
            highlightedWorkspaceIndex++
            if (highlightedWorkspaceIndex >= screen.workspaces.count) {
                highlightedScreenIndex = (highlightedScreenIndex + 1) % screensProxy.count;
                highlightedWorkspaceIndex = 0;
            }
        }
        function decreaseHighlight() {
            highlightedWorkspaceIndex--;
            if (highlightedWorkspaceIndex < 0) {
                highlightedScreenIndex--;
                if (highlightedScreenIndex < 0) {
                    highlightedScreenIndex = screensProxy.count - 1
                }
                var screen = screensProxy.get(highlightedScreenIndex);
                highlightedWorkspaceIndex = screen.workspaces.count -1;
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 300
        onTriggered: d.shown = false;
    }

    Keys.onPressed: {
        hideTimer.restart();
        switch (event.key) {
        case Qt.Key_Left:
            d.decreaseHighlight();
            break;
        case Qt.Key_Right:
            d.increaseHighlight();
            break;
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
            print("starting hidetimer")
            d.active = false;
            hideTimer.start();
            focus = false;
            screensProxy.get(d.highlightedScreenIndex).workspaces.get(d.highlightedWorkspaceIndex).activate();
        }
    }

    Row {
        id: screensRow
        anchors {
            top: parent.top; topMargin: units.gu(2)
            left: parent.left; leftMargin: units.gu(2)
        }
        spacing: units.gu(2)

        Repeater {
            model: screensProxy

            delegate: Item {
                height: root.height - units.gu(4)
                width: workspaces.width

                UbuntuShape {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(4)
                    backgroundColor: "white"

                    Label {
                        anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                        text: model.screen.name
                        color: UbuntuColors.ash
                    }
                }

                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: {
                        var width = 0;
                        if (screensProxy.count == 1) {
                            width = Math.min(implicitWidth, root.width - units.gu(8));
                        } else {
                            width = Math.min(implicitWidth, model.screen.active ? root.width - units.gu(48) : units.gu(40))
                        }
                        return Math.max(workspaces.minimumWidth, width);
                    }

                    Behavior on width { UbuntuNumberAnimation {} }
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
