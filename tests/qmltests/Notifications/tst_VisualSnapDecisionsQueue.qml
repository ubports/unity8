/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import ".."
import "../../../qml/Notifications"
import Ubuntu.Components 1.3
import Unity.Test 0.1
import Unity.Notifications 1.0

Row {
    id: rootRow

    Component {
        id: mockNotification

        QtObject {
            function invokeAction(actionId) {
                mockModel.actionInvoked(actionId)
            }

            function close() {
                console.log("Close notification");
            }
        }
    }

    ListModel {
        id: mockModel

        signal actionInvoked(string actionId)

        function getRaw(id) {
            return mockNotification.createObject(mockModel)
        }
    }

    function addSomeSnapDecisionNotifications() {
        var n = [{
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-button-tint": "true"},
            summary: "Incoming call",
            body: "Frank Zappa\n+44 (0)7736 027340",
            icon: "../../tests/graphics/avatars/funky.png",
            secondaryIcon: "../../tests/graphics/applicationIcons/dialer-app.png",
            actions: [{ id: "pickup_id", label: "Pick up"},
                      { id: "decline_1_id", label: "Decline"},
                      { id: "decline_2_id", label: "Can't talk now, what's up?"},
                      { id: "decline_3_id", label: "I call you back."},
                      { id: "decline_4_id", label: "Send custom message..."}]
        },
        {
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-button-tint": "true",
                    "x-canonical-non-shaped-icon": "true"},
            summary: "Incoming file",
            body: "Frank would like to send you the file: essay.pdf.",
            icon: "image://theme/search",
            actions: [{ id: "accept_id", label: "Accept"},
                      { id: "reject_id", label: "Reject"}]
        },
        {
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-button-tint": "true",
                    "x-canonical-non-shaped-icon": "true"},
            summary: "Authentication error",
            body: "Please authorise Ubuntu to access your Google account.",
            icon: "image://theme/search",
            actions: [{ id: "settings_id", label: "Settings..."},
                      { id: "cancel_id", label: "Cancel"}]
        },
        {
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-button-tint": "true",
                    "x-canonical-non-shaped-icon": "true"},
            summary: "Morning alarm",
            body: "It's 6:30... time to get up!",
            icon: "image://theme/search",
            actions: [{ id: "ok_reply", label: "Ok"},
                      { id: "snooze_id", label: "Snooze"}]
        },
        {
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-button-tint": "true"},
            summary: "Jenny Sample",
            body: "Hey there! Have you been watching the latest episode of that TV-show I told you about last week?",
            icon: "../../tests/graphics/avatars/amanda.png",
            secondaryIcon: "../../tests/graphics/applicationIcons/messages-app.png",
            actions: [{ id: "reply_id", label: "Reply"},
                      { id: "ignore_id", label: "Ignore"}]
        }]

        mockModel.append(n)
    }

    function clearNotifications() {
        mockModel.clear();
    }

    function removeTopMostNotification() {
        if (mockModel.count > 0) {
            mockModel.remove(0);
        }
    }

    Rectangle {
        id: notificationsRect

        width: units.gu(40)
        height: units.gu(71)

        MouseArea{
            id: clickThroughCatcher

            anchors.fill: parent
        }

        Notifications {
            id: notifications

            margin: units.gu(1)

            anchors.fill: parent
            model: mockModel
        }
    }

    Rectangle {
        id: interactiveControls

        width: units.gu(30)
        height: units.gu(81)
        color: "grey"

        Column {
            spacing: units.gu(1)
            anchors.fill: parent
            anchors.margins: units.gu(1)

            Button {
                width: parent.width
                text: "add some snap-decisions"
                onClicked: addSomeSnapDecisionNotifications()
            }

            Button {
                width: parent.width
                text: "remove top-most notification"
                onClicked: removeTopMostNotification()
            }

            Button {
                width: parent.width
                text: "clear model"
                onClicked: clearNotifications()
            }

            MouseTouchEmulationCheckbox {
                id: mouseEmulation
                checked: false
            }
        }
    }

    UnityTestCase {
        id: root
        name: "VisualQueueTest"
        when: windowShown

        function test_VisualSnapDecisionsQueue() {
            // populate model with some mock notifications
            addSomeSnapDecisionNotifications();

            // make sure the view is properly updated before going on
            notifications.forceLayout();
            waitForRendering(notifications);

            var snap_decision = [findChild(notifications, "notification0"),
                                 findChild(notifications, "notification1"),
                                 findChild(notifications, "notification2"),
                                 findChild(notifications, "notification3"),
                                 findChild(notifications, "notification4")]

            for (var index = 0; index < snap_decision.length; index++) {
                verify(snap_decision[index] !== undefined, index + ". snap-decision wasn't found");
            }

            // check initial states once all five snap-decisions were appended to the model
            compare(snap_decision[0].expanded, true, "state of first snap-decision is not expanded");
            for (var index = 1; index < snap_decision.length; index++) {
                compare(snap_decision[index].expanded, false, "state of "+ index + ".snap-decision is not contracted");
            }

            // click/tap on each snap-decision and verify only one is in expanded-state at any time
            for (var index = 0; index < snap_decision.length; index++) {
                mouseClick(snap_decision[index])
                for (var kindex = 0; kindex < snap_decision.length; kindex++) {
                    if (kindex == index) {
                        compare(snap_decision[kindex].expanded, true, "state of "+ kindex + ".snap-decision is not expanded");
                    } else {
                        compare(snap_decision[kindex].expanded, false, "state of "+ kindex + ".snap-decision is not contracted");
                    }
                }
            }

            // remove top-most and verify one of the remaining ones is still getting expanded

            waitForRendering(notifications);
            // make first snap-decision expand
            mouseClick(snap_decision[0]);

            for (var index = 1; index < snap_decision.length; index++) {
                removeTopMostNotification();
                compare(snap_decision[index].expanded, true, "state of " + index + ". snap-decision is not expanded");
            }
        }
    }
}
