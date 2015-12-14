/*
 * Copyright 2015 Canonical Ltd.
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
import QtTest 1.0
import "../../../qml/Components"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(70)
    color: "lightgrey"

    ListModel {
        id: fakeModel
        ListElement { icon: "../../tests/graphics/applicationIcons/facebook.png"; name: "Facebook" }
        ListElement { icon: "../../tests/graphics/applicationIcons/gmail.png"; name: "Mail" }
    }

    function openWarning() {
        return PopupUtils.open(Qt.resolvedUrl("../../../qml/Components/ModeSwitchWarningDialog.qml"), root, { model: fakeModel });
    }

    Button {
        anchors.centerIn: parent
        text: "trigger warning"
        onClicked: {
            openWarning();
        }
    }

    SignalSpy {
        id: spy
        signalName: "forceClose"
    }

    UT.UnityTestCase {
        name: "ModeSwitchWarning"
        when: windowShown

        function test_labelChangesOnClick() {
            var popup = openWarning();
            var reconnectLabel = findChild(popup, "reconnectLabel");
            tryCompare(reconnectLabel, "text", reconnectLabel.notClickedText)
            mouseClick(reconnectLabel, reconnectLabel.width / 2, reconnectLabel.height / 2)
            tryCompare(reconnectLabel, "text", reconnectLabel.clickedText)
        }

        function test_closeButtonEmitsSignal() {
            var popup = openWarning();
            spy.target = popup;
            spy.clear();
            var closeButton = findChild(popup, "forceCloseButton");
            mouseClick(closeButton, closeButton.width / 2, closeButton.height / 2)
            tryCompare(spy, "count", 1)

        }
    }
}
