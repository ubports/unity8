/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import GSettings 1.0
import "../Components"

FocusScope {
    id: root
    implicitHeight: units.gu(5)
    focus: true

    property bool isPrompt
    property bool isAlphanumeric
    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    readonly property string enteredText: loader.item.enteredText
    property bool hasKeyboard: false
    property bool waitingToAccept: false

    signal clicked()
    signal canceled()
    signal accepted()

    GSettings {
        id: unity8Settings
        schema.id: "com.canonical.Unity8"
    }

    onEnteredTextChanged: if (waitingToAccept) root.accepted()

    function showFakePassword() {
        // Just a silly hack for looking like 4 pin numbers got entered, if
        // a fingerprint was used and we happen to be using a pin.  This was
        // a request from Design.
        if (isSecret) {
            loader.item.enteredText = "...."; // actual text doesn't matter
        }
    }

    Loader {
        id: loader
        objectName: "promptLoader"

        focus: true

        anchors.fill: parent

        Connections {
            target: loader.item
            onClicked: root.clicked()
            onCanceled: root.canceled()
            onAccepted: {
                if (response == enteredText)
                    root.accepted();
                else
                    waitingToAccept = true;
            }
        }

        Binding {
            target: loader.item
            property: "text"
            value: root.text
        }

        Binding {
            target: loader.item
            property: "isSecret"
            value: root.isSecret
        }

        Binding {
            target: loader.item
            property: "interactive"
            value: root.interactive
        }

        Binding {
            target: loader.item
            property: "loginError"
            value: root.loginError
        }

        Binding {
            target: loader.item
            property: "hasKeyboard"
            value: root.hasKeyboard
        }

        onLoaded: loader.item.focus = true
    }

    states: [
        State {
            name: "ButtonPrompt"
            when: !root.isPrompt
            PropertyChanges { target: loader; source: "ButtonPrompt.qml" }
        },
        State {
            name: "PinPrompt"
            when: root.isPrompt && !root.isAlphanumeric && root.isSecret
            PropertyChanges { target: loader; source: "PinPrompt.qml" }
        },
        State {
            name: "TextPrompt"
            when: root.isPrompt
            PropertyChanges { target: loader; source: "TextPrompt.qml" }
        }
    ]
}
