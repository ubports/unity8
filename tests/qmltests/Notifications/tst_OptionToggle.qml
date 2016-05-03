/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Mirco Mueller <mirco.mueller@canonical.com>
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
                console.log("Action invoked", actionId);
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

        // add the default/PlaceHolder notification to the model
        Component.onCompleted: {
            var n = {
                type: Notification.PlaceHolder,
                hints: {},
                summary: "",
                body: "",
                icon: "",
                secondaryIcon: "",
                actions: []
            }

            append(n)
        }
    }

    function addSnapDecisionNotification() {
        var n = {
            type: Notification.SnapDecision,
            hints: {"x-canonical-private-affirmative-tint": "true"},
            summary: "Incoming call",
            body: "Frank Zappa\n+44 (0)7736 027340",
            icon: "../../tests/graphics/avatars/funky.png",
            secondaryIcon: "image://theme/incoming-call",
            actions: [{ id: "ok_id", label: "Ok"},
                      { id: "cancel_id", label: "Cancel"},
                      { id: "dummy_id", label: "Quick reply"},
                      { id: "late_id", label: "messages:I'm running late. I'm on my way."},
                      { id: "later_id", label: "messages:I'm busy at the moment. I'll call later."}]
        }

        mockModel.append(n)
    }

    function clearNotifications() {
        mockModel.clear()
    }

    function remove1stNotification() {
        if (mockModel.count > 0)
            mockModel.remove(0)
    }

    Rectangle {
        id: notificationsRect

        width: units.gu(40)
        height: units.gu(81)
        color: theme.palette.normal.background

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
                text: "add a snap-decision"
                onClicked: addSnapDecisionNotification()
            }

            Button {
                width: parent.width
                text: "remove 1st notification"
                onClicked: remove1stNotification()
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
        name: "NotificationRendererTest"
        when: windowShown

        function test_NotificationRenderer_data() {
            return [
            {
                tag: "Snap Decision with secondary icon, button-tint and OptionToggle",
                type: Notification.SnapDecision,
                hints: {"x-canonical-private-affirmative-tint": "true"},
                summary: "Incoming call",
                body: "Frank Zappa\n+44 (0)7736 027340",
                icon: "../../tests/graphics/avatars/funky.png",
                secondaryIcon: "image://theme/incoming-call",
                actions: [{ id: "ok_id", label: "Ok"},
                          { id: "cancel_id", label: "Cancel"},
                          { id: "dummy_id", label: "Quick reply"},
                          { id: "late_id", label: "messages:I'm running late. I'm on my way."},
                          { id: "later_id", label: "messages:I'm busy at the moment. I'll call later."}],
                summaryVisible: true,
                bodyVisible: true,
                iconVisible: true,
                shaped: true,
                secondaryIconVisible: true,
                buttonRowVisible: true,
                buttonTinted: true,
                hasSound: false
            }
            ]
        }

        SignalSpy {
            id: clickThroughSpy

            target: clickThroughCatcher
            signalName: "clicked"
        }

        SignalSpy {
            id: actionSpy

            target: mockModel
            signalName: "actionInvoked"
        }

        function cleanup() {
            clickThroughSpy.clear()
            actionSpy.clear()
        }

        function test_NotificationRenderer(data) {
            // populate model with some mock notifications
            mockModel.append(data)

            // make sure the view is properly updated before going on
            notifications.forceLayout();
            waitForRendering(notifications);

            var notification = findChild(notifications, "notification" + (mockModel.count - 1))
            verify(notification !== undefined, "notification wasn't found");

            waitForRendering(notification);

            var icon = findChild(notification, "icon")
            var shapedIcon = findChild(notification, "shapedIcon")
            var nonShapedIcon = findChild(notification, "nonShapedIcon")
            var interactiveArea = findChild(notification, "interactiveArea")
            var secondaryIcon = findChild(notification, "secondaryIcon")
            var summaryLabel = findChild(notification, "summaryLabel")
            var bodyLabel = findChild(notification, "bodyLabel")
            var buttonRow = findChild(notification, "buttonRow")

            compare(icon.visible, data.iconVisible, "avatar-icon visibility is incorrect")
            if (icon.visible) {
                compare(icon.shaped, data.shaped, "shaped-status is incorrect")
            }

            // test input does not fall through
            mouseClick(notification, units.gu(2), units.gu(2))
            if(data.type == Notification.Interactive) {
                actionSpy.wait()
                compare(actionSpy.signalArguments[0][0], data.actions[0]["id"], "got wrong id for interactive action")
            }
            compare(clickThroughSpy.count, 0, "click on notification fell through")

            compare(secondaryIcon.visible, data.secondaryIconVisible, "secondary-icon visibility is incorrect")
            compare(summaryLabel.visible, data.summaryVisible, "summary-text visibility is incorrect")
            compare(bodyLabel.visible, data.bodyVisible, "body-text visibility is incorrect")
            compare(buttonRow.visible, data.buttonRowVisible, "button visibility is incorrect")

            if (data.hasSound) {
                var audioItem = findInvisibleChild(notification, "sound")
                compare(audioItem.playbackState, data.hasSound ? Audio.PlayingState : Audio.StoppedState, "Audio has wrong state")
            }

            if(data.buttonRowVisible) {
                var buttonCancel = findChild(buttonRow, "notify_button1")
                var buttonAccept = findChild(buttonRow, "notify_button0")

                // only test the left/cancel-button if two actions have been passed in
                if (data.actions.length == 2) {
                    tryCompareFunction(function() { mouseClick(buttonCancel); return actionSpy.signalArguments.length > 0; }, true);
                    compare(actionSpy.signalArguments[0][0], data.actions[1]["id"], "got wrong id for negative action")
                    actionSpy.clear()
                }

                // check the tinting of the positive/right button
                verify(buttonAccept.color === data.buttonTinted ? "#3fb24f" : "#dddddd", "button has the wrong color-tint")

                // click the positive/right button
                tryCompareFunction(function() { mouseClick(buttonAccept); return actionSpy.signalArguments.length > 0; }, true);
                compare(actionSpy.signalArguments[0][0], data.actions[0]["id"], "got wrong id positive action")
                actionSpy.clear()
                waitForRendering(notification)

                // check if there's a OptionToggle created due to more actions being passed
                if (data.actions.length > 2) {
                    var optionToggle = findChild(notification, "notify_button2")
                    tryCompareFunction(function() { return optionToggle.expanded == false; }, true);

                    // click to expand
                    tryCompareFunction(function() { mouseClick(optionToggle); return optionToggle.expanded == true; }, true);

                    // try clicking on choices in expanded comboList
                    var choiceButton1 = findChild(notification, "notify_button3")
                    tryCompareFunction(function() { mouseClick(choiceButton1); return actionSpy.signalArguments.length > 0; }, true);
                    compare(actionSpy.signalArguments[0][0], data.actions[3]["id"], "got wrong id choice action 1")
                    actionSpy.clear()

                    var choiceButton2 = findChild(notification, "notify_button4")
                    tryCompareFunction(function() { mouseClick(choiceButton2); return actionSpy.signalArguments.length > 0; }, true);
                    compare(actionSpy.signalArguments[0][0], data.actions[4]["id"], "got wrong id choice action 2")
                    actionSpy.clear()
                } else {
                    mouseClick(buttonCancel)
                    compare(actionSpy.signalArguments[0][0], data.actions[1]["id"], "got wrong id for negative action")
                }
            }
        }
    }
}
