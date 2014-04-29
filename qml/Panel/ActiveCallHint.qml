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

Rectangle {
    id: callHint

    readonly property bool active: callManager.hasCalls && ApplicationManager.focusedApplicationId !== "dialer-app"

    Component.onCompleted: {
        telepathyHelper.registerChannelObserver("unity8");
    }

    color: Qt.rgba(0,0.8,0,1)
    clip: true

    MouseArea {
        anchors.fill: parent
        onClicked: {
            ApplicationManager.requestFocusApplication("dialer-app");
        }
    }

    Column {
        id: column

        anchors {
            left: parent.left
            leftMargin:units.gu(1)
            right: time.left
        }
        y: 0
        Behavior on y { StandardAnimation { duration: 400 } }

        Label {
            id: label1
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
            id: label2
            anchors {
                left: parent.left
                right: parent.right
            }
            height: callHint.height
            verticalAlignment: Text.AlignVCenter
            text: i18n.tr("Tap to return to call...");
        }
    }

    Label {
        id: time
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
        id: contactWatcher
        phoneNumber: d.activeCall ? d.activeCall.phoneNumber : ""
    }

    Timer {
        running: callHint.active
        interval: 4000
        repeat: true

        property int iteration: 0

        onRunningChanged: iteration = 0; // bit longer for the first one.

        onTriggered: {
            // every 4 seconds.
            if (iteration % 2 == 0) {
                column.y = -label1.height;
            } else {
                column.y = 0;
            }
            iteration++;
        }
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
