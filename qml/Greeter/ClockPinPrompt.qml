/*
 * Copyright 2022 UBports Foundation
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

Item {
    id: root
    objectName: "ClockPinPrompt"

    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false //unused
    property string enteredText: ""

    property int previousNumber: -1
    property var currentCode: []
    property int maxnum: 10
    property int maxPinCodeDigits: 4 // hard limit of 4 for passcodes right now
    property bool isLandscape: width > height

    signal clicked()
    signal canceled()
    signal accepted(string response)

    onCurrentCodeChanged: {
        let tmpText = ""
        let tmpCode = ""
        for( let i = 0; i < maxPinCodeDigits; i++) {
            if (i < currentCode.length) {
                tmpText += '●'
                tmpCode += currentCode[i]
            } else {
                tmpText += '○'
            }
        }

        pinHint.text = tmpText
        root.enteredText = tmpCode

        if (root.enteredText.length >= maxPinCodeDigits) {
            root.accepted(root.enteredText);
        }
    }

    function addNumber (number, fromKeyboard) {
        let tmpCodes = currentCode
        tmpCodes.push(number)
        currentCode = tmpCodes
        // don't animate digits while with keyboard
        if (!fromKeyboard) {
            repeater.itemAt(number).animation.restart()
        }
        root.previousNumber = number
    }

    function removeOne() {
        let tmpCodes = currentCode
        const number = tmpCodes.pop()
        currentCode = tmpCodes
    }

    function reset() {
        currentCode = []
        loginError = false;
    }

    StyledItem {
        id: d

        readonly property color normal: theme.palette.normal.raisedText
        readonly property color selected: theme.palette.normal.raisedSecondaryText
        readonly property color disabled:theme.palette.disabled.raisedSecondaryText
    }

    TextField {
        id: pinHint

        anchors.horizontalCenter: parent.horizontalCenter
        width: units.gu(16)
        readOnly: true
        color: d.selected
        font {
            pixelSize: units.gu(3)
            letterSpacing: units.gu(1.75)
        }
        secondaryItem: Icon {
            name: "erase"
            objectName: "EraseBtn"
            height: units.gu(3)
            width: units.gu(3)
            color: enabled ? d.selected : d.disabled
            enabled: root.currentCode.length > 0
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: root.removeOne()
            }
        }

        inputMethodHints: Qt.ImhDigitsOnly

        Keys.onEscapePressed: {
            root.canceled();
            event.accepted = true;
        }

        Keys.onPressed: {
            if(event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                root.addNumber(event.text, true)
                event.accepted = true;
            }
        }

        Keys.onBackPressed: {
            root.removeOne()
        }

    }

    Rectangle {
        id: main
        objectName: "SelectArea"

        height: Math.min(parent.height, parent.width)
        width: parent.width
        anchors.bottom:parent.bottom
        // in portrait, let the clock being close the bottom
        anchors.bottomMargin: root.isLandscape ? -units.gu(4) : -units.gu(8)
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onPressed: root.state = "ENTRY_MODE"

            onPositionChanged: {
                if (pressed)
                    reEvaluate()
            }

            function reEvaluate() {
                var child = main.childAt(mouseX, mouseY)

                if (child !== null && child.number !== undefined) {
                    var number = child.number
                    if (number > -1 && ( root.previousNumber === -1 || number !== root.previousNumber)) {
                        root.addNumber(number)
                    }
                } else {
                    // outside
                    root.previousNumber = -1
                }
            }
        }

        Rectangle {
            id: center

            objectName: "CenterCircle"
            height: main.height / 3
            width: height
            radius: height / 2
            property int radiusSquared: radius * radius
            property alias locker: centerImg.source
            anchors.centerIn: parent
            color: "transparent"
            property int number: -1

                Icon {
                id: centerImg
                source: "image://theme/lock"
                anchors.centerIn: parent
                width: units.gu(4)
                height: width
                color: d.disabled
                onSourceChanged: imgAnim.start()
            }
            SequentialAnimation {
                                id: imgAnim
                                NumberAnimation { target: centerImg; property: "opacity"; from: 0; to: 1; duration: 1000 }
                            }
        }

        // dots
        Repeater {
            id: repeater

            objectName: "dotRepeater"
            model: root.maxnum

            Rectangle {
                id: selectionRect
                height: bigR / 2.2
                width: height
                radius: height / 2
                color: "transparent"
                property int number: index
                property alias dot: point
                property alias animation: anim

                property int bigR: root.state === "ENTRY_MODE" ? main.height / 3 : 0
                property int offsetRadius: radius
                x: (main.width / 2) + bigR * Math.sin(2 * Math.PI * index / root.maxnum) - offsetRadius
                y: (main.height / 2) - bigR * Math.cos(2 * Math.PI * index / root.maxnum) - offsetRadius

                    Text {
                        id: point
                        font.pixelSize: main.height / 10
                        anchors.centerIn: parent
                        color: d.disabled
                        text: index
                        opacity: root.state === "ENTRY_MODE" ? 1 : 0
                        property bool selected: false

                        Behavior on opacity {
                            UbuntuNumberAnimation{ duration: 500 }
                        }
                    }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        root.addNumber(index)
                        mouse.accepted = false
                    }
                }

                Behavior on bigR {
                    UbuntuNumberAnimation { duration: 500 }
                }

                SequentialAnimation {
                    id: anim
                    ParallelAnimation {
                        PropertyAnimation {
                            target: point
                            property: "color"
                            to: d.selected
                            duration: 100
                        }
                        PropertyAnimation {
                            target: selectionRect
                            property: "color"
                            to: Qt.rgba(d.selected.r, d.selected.g, d.selected.b, 0.3)
                            duration: 100
                        }
                    }
                    ParallelAnimation {
                        PropertyAnimation {
                            target: point
                            property: "color"
                            to: d.disabled
                            duration: 400
                        }
                        PropertyAnimation {
                            target: selectionRect
                            property: "color"
                            to: "transparent"
                            duration: 400
                        }
                    }
                }
            }
        }
    }

    states: [
        State{
            name: "ENTRY_MODE"
            StateChangeScript {
                script: root.reset();
            }
        },
        State{
            name: "WRONG_PASSWORD"
            when: root.loginError
            PropertyChanges {
                target: center
                locker: "image://theme/dialog-warning-symbolic"
            }
        }
    ]

    transitions: Transition {
        from: "WRONG_PASSWORD"; to: "ENTRY_MODE";
        PropertyAction { target: center; property: "locker"; value: "image://theme/dialog-warning-symbolic" }
        PauseAnimation { duration: 1000 }
    }

    onActiveFocusChanged: {
        if (!activeFocus && !pinHint.activeFocus) {
            root.state = ""
        } else {
            root.state = "ENTRY_MODE"
            pinHint.forceActiveFocus()
        }
    }
}
