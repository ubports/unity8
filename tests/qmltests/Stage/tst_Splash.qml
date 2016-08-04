/*
 * Copyright 2014 Canonical Ltd.
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
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Stages"
import Ubuntu.Components 1.3
import Unity.Application 0.1

Rectangle {
    color: "black"
    id: root
    width: units.gu(70)
    height: units.gu(70)

    Component.onCompleted: {
        root.fakeApplication = ApplicationManager.add("gallery-app");
        root.fakeApplication.manualSurfaceCreation = true;
        root.fakeApplication.setState(ApplicationInfoInterface.Starting);
    }
    property QtObject fakeApplication

    Component {
        id: splashComponent
        Splash {
            anchors.fill: parent
            title: "Splash Title"
            showHeader: showHeaderCheckbox.checked
            icon: fakeApplication ? fakeApplication.icon : ""
            imageSource: imageSourceCheckbox.checked ? "../UnityLogo.png" : ""
            backgroundColor: backgroundColorCheckbox.checked ? "darkorange" : "#00000000"
            headerColor: headerColorCheckbox.checked ? "mediumseagreen" : "#00000000"
            footerColor: footerColorCheckbox.checked ? "teal" : "#00000000"
        }
    }
    Loader {
        id: splashLoader
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: units.gu(40)
        sourceComponent: splashComponent
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: splashLoader.right
            right: parent.right
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)

            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: showHeaderCheckbox; checked: false; }
                Label { text: "showHeader"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: imageSourceCheckbox; checked: false; }
                Label { text: "imageSource"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: backgroundColorCheckbox; checked: false; }
                Label { text: "custom backgroundColor"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: headerColorCheckbox; checked: false; }
                Label { text: "custom headerColor"; anchors.verticalCenter: parent.verticalCenter }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: footerColorCheckbox; checked: false; }
                Label { text: "custom footerColor"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "Splash"
        when: windowShown

        function cleanup() {
            // reload our test subject to get it in a fresh state once again
            splashLoader.active = false;
            surfaceCheckbox.checked = false;
            splashLoader.active = true;
        }

        // No automated tests so far. Used only for manual testing at the moment.
    }
}
