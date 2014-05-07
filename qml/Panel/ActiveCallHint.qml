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

import QtQuick 2.0
import Ubuntu.Telephony 0.1 as Telephony
import Ubuntu.Components 0.1
import Unity.Application 0.1
import "../Components"

Item {
    id: callHint

    property bool active: callManager.hasCalls && ApplicationManager.focusedApplicationId !== "dialer-app"
    readonly property QtObject contactWatcher: _contactWatcher
    property int alternateLabelInterval: 4000
    property color color: Qt.rgba(0.1, 0.6, 0.1, 1.0)
    property color colorFlash: Qt.lighter(color)

    Component.onCompleted: {
        telepathyHelper.registerChannelObserver("unity8");
    }

    function activate() {
        ApplicationManager.requestFocusApplication("dialer-app");
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: callHint.color

        states: [
            State {
                name: "fade-down"
            },
            State {
                name: "fade-up"
                PropertyChanges { target: background; color: callHint.colorFlash }
            }
        ]
        state: "fade-down"

        transitions: [
            Transition {
                to: "fade-up";
                ColorAnimation { duration: 260; easing.type: Easing.InQuart }
            },
            Transition {
                to: "fade-down";
                ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        ]

        Timer {
            running: callHint.active && color != colorFlash
            interval: background.state == "fade-down" ? 3000 : 400
            repeat: true
            onTriggered: {
                if (background.state == "fade-down") {
                    background.state = "fade-up";
                } else {
                    background.state = "fade-down";
                }
            }
        }
    }

    Component {
        id: contactColumnRow

        Column {
            id: column
            objectName: "contactColumn"

            anchors {
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height

            Component.onCompleted: {
                if (index === 0) {
                    labelPathView.column1 = column;
                } else {
                    labelPathView.column2 = column;
                }
            }

            Label {
                id: contactLabel
                objectName: "contactLabel"

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: callHint.height
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!d.activeCall) {
                        return "";
                    } else if (d.activeCall.isConference) {
                        return i18n.tr("Conference");
                    } else {
                        return contactWatcher.alias !== "" ? contactWatcher.alias : contactWatcher.phoneNumber;
                    }
                }
            }

            Label {
                id: returnLabel

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: callHint.height
                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("Tap to return to call...");
            }
        }
    }

    PathView {
        id: labelPathView
        objectName: "labelPathView"

        anchors {
            top: parent.top
            left: parent.left
            leftMargin:units.gu(1)
            right: time.left
        }
        height: columnHeight > callHint.height ? callHint.height : columnHeight
        clip: true

        property Column column1
        property Column column2
        property int columnHeight: column1 ? column1.height : 0

        delegate: contactColumnRow
        model: 2
        offset: 0
        interactive: false

        path: Path {
            startY: -labelPathView.columnHeight / 2
            PathLine {
                y: labelPathView.columnHeight * 1.5
            }
        }

        Behavior on offset {
            id: offsetBehaviour
            SmoothedAnimation {
                id: offsetAnimation
                // ensure we go faster than the label switch
                duration: alternateLabelInterval / 2
                velocity: 0.75
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Fade in text
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: background.color }
            GradientStop { position: 0.25; color: Qt.rgba(background.color.r, background.color.g, background.color.b, 0.0) }
            GradientStop { position: 0.75; color: Qt.rgba(background.color.r, background.color.g, background.color.b, 0.0) }
            GradientStop { position: 1.0; color: background.color }
        }
    }

    Timer {
        running: callHint.active
        interval: alternateLabelInterval
        repeat: true

        onRunningChanged: {
            if (running) {
                offsetBehaviour.enabled = false;
                labelPathView.offset = 0;
                offsetBehaviour.enabled = true;
            }
        }

        onTriggered: {
            labelPathView.offset = labelPathView.offset + 0.5;
        }
    }

    Label {
        id: time
        objectName: "timeLabel"

        anchors {
            right: parent.right
            rightMargin:units.gu(1)
            top: parent.top
        }
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        text: {
            if (!d.activeCall) {
                return "0:00";
            }
            var m = Math.round(d.activeCall.elapsedTime/60);
            var ss = d.activeCall.elapsedTime % 60;
            if (ss >= 10) {
                return m + ":" + ss;
            } else {
                return m + ":0" + ss;
            }
        }
    }

    Telephony.ContactWatcher {
        id: _contactWatcher
        objectName: "contactWatcher"
        phoneNumber: d.activeCall ? d.activeCall.phoneNumber : ""
    }

    QtObject {
        id: d

        property QtObject activeCall: {
            if (callManager.foregroundCall) {
                return callManager.foregroundCall;
            }
            return callManager.backgroundCall;
        }
    }
}
