/*
 * Copyright (C)  2016 Canonical, Ltd.
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

import "../Components"
import ".." 0.1

Showable {
    id: root

    readonly property bool active: required || hasLockedApp

    readonly property bool hasLockedApp: lockedApp !== ""
    readonly property bool locked: false
    readonly property bool waiting: false
    readonly property bool fullyShown: shown

    property string lockedApp: ""

    function forceShow() { show(); }
    property var notifyAppFocusRequested: (function(appId) { return; })
    property var notifyUserRequestedApp: (function(appId) { return; })
    property var notifyShowingDashFromDrag: (function(appId) { return false; })

    showAnimation: StandardAnimation { property: "opacity"; to: 1 }
    hideAnimation: StandardAnimation { property: "opacity"; to: 0 }

    shown: ShellNotifier.greeter.shown
    Component.onCompleted: opacity = shown ? 1 : 0
    visible: opacity != 0

    Rectangle {
        anchors.fill: parent
        color: LomiriColors.purple
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: wheel.accepted = true
    }

    Connections {
        target: ShellNotifier.greeter
        onHide: {
            if (now) {
                root.hideNow(); // skip hide animation
            } else {
                root.hide();
            }
        }
        onShownChanged: {
            if (ShellNotifier.greeter.shown) {
                root.show();
            } else {
                root.hide();
            }
        }
    }
}
