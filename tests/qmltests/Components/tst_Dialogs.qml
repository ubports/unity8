/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.2
import QtTest 1.0
import Ubuntu.Components 1.1
import Unity.Test 0.1

import "../../../qml/Components"

Rectangle {
    id: root
    color: "black"
    width: units.gu(70)
    height: fakeShell.longestDimension

    QtObject {
        id: fakeUnitySession
        signal logoutRequested
        signal shutdownRequested
        signal rebootRequested
        function logout() {}
        function shutdown() {}
        function reboot() {}
    }

    Rectangle {
        id: fakeShell
        color: "green"
        readonly property real longestDimension: units.gu(71)
        readonly property real shortestDimension: units.gu(40)
        readonly property bool landscape: rotation === 90 || rotation === 270
        x: (shortestDimension - width) / 2
        y: (longestDimension - height) / 2
        width: landscape ? longestDimension : shortestDimension
        height: landscape ? shortestDimension : longestDimension

        Text {
            text: "Shell"
            color: "black"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            font.pixelSize: 200
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Dialogs {
            id: dialogs
            anchors.fill: parent
            unitySessionService: fakeUnitySession
            closeAllApps: function() {}
        }
    }

    Rectangle {
        color: "white"
        x: fakeShell.shortestDimension
        width: root.width - x
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Button { text: "Power dialog"; onClicked: { testCase.showPowerDialog(); } }
            Button { text: "Logout Requested"; onClicked: { fakeUnitySession.logoutRequested(); } }
            Button { text: "Shutdown Requested"; onClicked: { fakeUnitySession.shutdownRequested(); } }
            Button { text: "Reboot Requested"; onClicked: { fakeUnitySession.rebootRequested(); } }
            Label { text: "Rotation:" }
            Button { text: "0"; onClicked: {fakeShell.rotation = 0;} }
            Button { text: "90"; onClicked: {fakeShell.rotation = 90;} }
            Button { text: "180"; onClicked: {fakeShell.rotation = 180;} }
            Button { text: "270"; onClicked: {fakeShell.rotation = 270;} }
        }
    }

    UnityTestCase {
        id: testCase
        name: "Dialogs"
        when: windowShown

        function showPowerDialog() {
            var dialogsPrivate = findInvisibleChild(dialogs, "dialogsPrivate");
            dialogsPrivate.showPowerDialog();
        }
    }
}
