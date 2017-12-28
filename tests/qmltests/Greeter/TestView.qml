/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "../Components"

Item {
    objectName: "testView"

    property real dragHandleLeftMargin
    property real launcherOffset
    property int currentIndex
    property int delayMinutes
    property real backgroundTopMargin
    property url background
    property bool hasCustomBackground
    property bool locked
    property bool alphanumeric
    property var userModel
    property var infographicModel
    property bool waiting
    readonly property bool fullyShown: _fullyShown
    readonly property bool required: _required
    readonly property bool animating: _animating

    property bool _fullyShown: true
    property bool _required: true
    property bool _animating: true

    signal selected(int index)
    signal responded(string response)
    signal tease()
    signal emergencyCall()

    signal _hideCalled()
    signal _showFakePasswordCalled()
    signal _notifyAuthenticationFailedCalled()
    signal _showErrorMessageCalled(string msg)
    signal _forceShowCalled()
    signal _tryToUnlockCalled(bool toTheRight)

    function hide() {
        _hideCalled();
        _required = false;
        _fullyShown = false;
    }

    function showFakePassword() {
        _showFakePasswordCalled();
    }

    function notifyAuthenticationFailed() {
        _notifyAuthenticationFailedCalled();
    }

    function showErrorMessage(msg) {
        _showErrorMessageCalled(msg);
    }

    function forceShow() {
        _forceShowCalled();
    }

    function tryToUnlock(toTheRight) {
        _tryToUnlockCalled(toTheRight);
        return true;
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        Label {
            text: "Fake view, nothing to see here"
            color: "white"
            anchors.centerIn: parent
        }
    }
}
