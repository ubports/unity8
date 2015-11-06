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

import QtQuick 2.4
import Ubuntu.Telephony 0.1 as Telephony
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "../Components"

Item {
    id: callHint

    property bool greeterShown: false

    readonly property bool active: {
        var application = ApplicationManager.findApplication("dialer-app");

        if (callManager.callIndicatorVisible) {
            // at the moment, callIndicatorVisible is only "valid" if dialer is in focus.
            if (application && ApplicationManager.focusedApplicationId === "dialer-app") {
                // Don't show if application is still starting; might get a fleeting true/false.
                return application.state !== ApplicationInfoInterface.Starting;
            }
        }
        if (greeterShown || ApplicationManager.focusedApplicationId !== "dialer-app") {
            if (application) {
                // Don't show if application is still starting; might get a fleeting true/false.
                return application.state !== ApplicationInfoInterface.Starting && callManager.hasCalls;
            }
            return callManager.hasCalls;
        }
        return false;
    }
    readonly property QtObject contactWatcher: _contactWatcher
    property int labelSwitchInterval: 6000
    implicitWidth: row.x + row.width

    Component.onCompleted: {
        telepathyHelper.registerChannelObserver("unity8");
    }

    function showLiveCall() {
        Qt.openUrlExternally("dialer:///?view=liveCall");
    }

    Component {
        id: contactColumn

        Column {
            id: column
            objectName: "contactColumn"

            anchors.left: parent.left

            Component.onCompleted: {
                if (index === 0) {
                    labelPathView.column1 = column;
                } else {
                    labelPathView.column2 = column;
                }
            }

            Label {
                height: callHint.height
                verticalAlignment: Text.AlignVCenter
                text: i18n.tr("Tap to return to call...");
            }

            Label {
                objectName: "contactLabel"
                height: callHint.height
                verticalAlignment: Text.AlignVCenter
                width: Math.max(contentWidth, 1)

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
        }
    }

    Row {
        id: row
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
        }
        spacing: units.gu(1)

        Label {
            id: time
            objectName: "timeLabel"

            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: {
                var m = Math.floor(d.callTime/60);
                var ss = d.callTime % 60;
                if (ss >= 10) {
                    return m + ":" + ss;
                } else {
                    return m + ":0" + ss;
                }
            }
        }

        PathView {
            id: labelPathView
            objectName: "labelPathView"

            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: column1 && column2 ? Math.max(column1.width, column1.width) : 0
            clip: true

            property Column column1
            property Column column2
            property int columnHeight: column1 ? column1.height : 0

            delegate: contactColumn
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
                    duration: labelSwitchInterval/8
                    velocity: 0.75
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Timer {
        id: alternateLabelTimer
        running: callHint.active
        interval: labelPathView.offset % 1.0 !== 0 ? labelSwitchInterval : labelSwitchInterval/4
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
        property int callTime: activeCall ? activeCall.elapsedTime : 0
    }
}
