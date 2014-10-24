/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import QtTest 1.0
import ".."
import "../../../qml/Notifications"
import Ubuntu.Components 0.1
import Unity.Test 0.1
import Unity.Notifications 1.0
import QtMultimedia 5.0

Item {
    width: notificationsRect.width + interactiveControls.width
    height: notificationsRect.height

    Row {
        id: rootRow

        Component {
            id: mockNotification

            QtObject {
                function invokeAction(actionId) {
                    mockModel.actionInvoked(actionId)
                }
            }
        }

        ListModel {
            id: mockModel
            dynamicRoles: true

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
                summary: "Tom Ato",
                body: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
                icon: "../graphics/avatars/funky.png",
                secondaryIcon: "../graphics/applicationIcons/facebook.png",
                actions: [{ id: "ok_id", label: "Ok"},
                          { id: "cancel_id", label: "Cancel"},
                          { id: "notreally_id", label: "Not really"},
                          { id: "noway_id", label: "messages:No way"},
                    { id: "nada_id", label: "messages:Nada"}]
            }

            mockModel.append(n)
        }

        function add2over1SnapDecisionNotification() {
            var n = {
                type: Notification.SnapDecision,
                hints: {"x-canonical-private-affirmative-tint": "true"},
                summary: "Theatre at Ferria Stadium",
                body: "at Ferria Stadium in Bilbao, Spain\n07578545317",
                icon: "",
                secondaryIcon: "",
                actions: [{ id: "ok_id", label: "Ok"},
                          { id: "snooze_id", label: "Snooze"},
                          { id: "view_id", label: "View"}]
            }

            mockModel.append(n)
        }

        function addEphemeralNotification() {
            var n = {
                type: Notification.Ephemeral,
                summary: "Cole Raby",
                body: "I did not expect it to be that late.",
                icon: "../graphics/avatars/amanda.png",
                secondaryIcon: "../graphics/applicationIcons/facebook.png",
                actions: []
            }

            mockModel.append(n)
        }

        function addEphemeralNonShapedIconNotification() {
            var n = {
                type: Notification.Ephemeral,
                hints: {"x-canonical-non-shaped-icon": "true"},
                summary: "Contacts",
                body: "Synchronised contacts-database with cloud-storage.",
                icon: "../graphics/applicationIcons/contacts-app.png",
                secondaryIcon: "",
                actions: []
            }

            mockModel.append(n)
        }

        function addEphemeralIconSummaryNotification() {
            var n = {
                type: Notification.Ephemeral,
                summary: "Photo upload completed",
                body: "",
                icon: "",
                secondaryIcon: "../graphics/applicationIcons/facebook.png",
                actions: []
            }

            mockModel.append(n)
        }

        function addInteractiveNotification() {
            var n = {
                type: Notification.Interactive,
                summary: "Interactive notification",
                body: "This is a notification that can be clicked",
                icon: "../graphics/avatars/anna_olsson.png",
                secondaryIcon: "",
                actions: [{ id: "reply_id", label: "Dummy"}],
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
                    text: "add a snap-decision"
                    onClicked: rootRow.addSnapDecisionNotification()
                }

                Button {
                    width: parent.width
                    text: "add a 2over1 snap-decision"
                    onClicked: rootRow.add2over1SnapDecisionNotification()
                }

                Button {
                    width: parent.width
                    text: "add an ephemeral"
                    onClicked: rootRow.addEphemeralNotification()
                }

                Button {
                    width: parent.width
                    text: "add an non-shaped-icon-summary-body"
                    onClicked: rootRow.addEphemeralNonShapedIconNotification()
                }

                Button {
                    width: parent.width
                    text: "add an icon-summary"
                    onClicked: rootRow.addEphemeralIconSummaryNotification()
                }

                Button {
                    width: parent.width
                    text: "add an interactive"
                    onClicked: rootRow.addInteractiveNotification()
                }

                Button {
                    width: parent.width
                    text: "remove 1st notification"
                    onClicked: rootRow.remove1stNotification()
                }

                Button {
                    width: parent.width
                    text: "clear model"
                    onClicked: rootRow.clearNotifications()
                }
            }
        }

        ActionModel {
            id: myActionModel
        }

        UnityTestCase {
            id: root
            name: "NotificationRendererTest"
            when: windowShown

            function test_NotificationRenderer_data() {
                return [
                {
                    tag: "Snap Decision with secondary icon and button-tint",
                    type: Notification.SnapDecision,
                    hints: {"x-canonical-private-affirmative-tint": "true"},
                    summary: "Tom Ato",
                    body: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
                    icon: "../graphics/avatars/funky.png",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    actions: [{ id: "ok_id", label: "Ok"},
                              { id: "cancel_id", label: "Cancel"},
                              { id: "notreally_id", label: "Not really"},
                              { id: "noway_id", label: "messages:No way"},
                              { id: "nada_id", label: "messages:Nada"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    shapedIcon: true,
                    nonShapedIcon: false,
                    secondaryIconVisible: true,
                    buttonRowVisible: true,
                    buttonTinted: true,
                    hasSound: false
                },
                {
                    tag: "2-over-1 Snap Decision with button-tint",
                    type: Notification.SnapDecision,
                    hints: {"x-canonical-private-affirmative-tint": "true"},
                    summary: "Theatre at Ferria Stadium",
                    body: "at Ferria Stadium in Bilbao, Spain\n07578545317",
                    icon: "",
                    secondaryIcon: "",
                    actions: [{ id: "ok_id", label: "Ok"},
                              { id: "snooze_id", label: "Snooze"},
                              { id: "view_id", label: "View"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: false,
                    shapedIcon: false,
                    nonShapedIcon: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: true,
                    hasSound: false
                },
                {
                    tag: "Ephemeral notification - icon-summary layout",
                    type: Notification.Ephemeral,
                    hints: {"x-canonical-private-affirmative-tint": "false"},
                    summary: "Photo upload completed",
                    body: "",
                    icon: "",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: false,
                    iconVisible: false,
                    shapedIcon: false,
                    nonShapedIcon: false,
                    secondaryIconVisible: true,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false
                },
                {
                    tag: "Ephemeral notification - check suppression of secondary icon for icon-summary layout",
                    type: Notification.Ephemeral,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg",
                            "suppress-sound": "true"},
                    summary: "New comment successfully published",
                    body: "",
                    icon: "",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: false,
                    interactiveAreaEnabled: false,
                    iconVisible: false,
                    shapedIcon: false,
                    nonShapedIcon: false,
                    secondaryIconVisible: true,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false
                },
                {
                    tag: "Interactive notification",
                    type: Notification.Interactive,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Interactive notification",
                    body: "This is a notification that can be clicked",
                    icon: "../graphics/avatars/amanda.png",
                    secondaryIcon: "",
                    actions: [{ id: "reply_id", label: "Dummy"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    shapedIcon: true,
                    nonShapedIcon: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: true
                },
                {
                    tag: "Snap Decision without secondary icon and no button-tint",
                    type: Notification.SnapDecision,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Bro Coly",
                    body: "At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
                    icon: "../graphics/avatars/anna_olsson.png",
                    secondaryIcon: "",
                    actions: [{ id: "accept_id", label: "Accept"},
                              { id: "reject_id", label: "Reject"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    shapedIcon: true,
                    nonShapedIcon: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: true,
                    buttonTinted: false,
                    hasSound: true
                },
                {
                    tag: "Ephemeral notification",
                    type: Notification.Ephemeral,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Cole Raby",
                    body: "I did not expect it to be that late.",
                    icon: "../graphics/avatars/funky.png",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    shapedIcon: true,
                    nonShapedIcon: false,
                    secondaryIconVisible: true,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: true
                },
                {
                    tag: "Ephemeral notification with non-shaped icon",
                    type: Notification.Ephemeral,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "x-canonical-non-shaped-icon": "true"},
                    summary: "Contacts",
                    body: "Synchronised contacts-database with cloud-storage.",
                    icon: "../graphics/applicationIcons/contacts-app.png",
                    secondaryIcon: "",
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    shapedIcon: false,
                    nonShapedIcon: true,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
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
                compare(shapedIcon.visible, data.shapedIcon, "shaped-icon visibility is incorrect")
                compare(nonShapedIcon.visible, data.nonShapedIcon, "non-shaped-icon visibility is incorrect")

                // test input does not fall through
                mouseClick(notification, notification.width / 2, notification.height / 2)
                if(data.type == Notification.Interactive) {
                    actionSpy.wait()
                    compare(actionSpy.signalArguments[0][0], data.actions[0]["id"], "got wrong id for interactive action")
                }
                compare(clickThroughSpy.count, 0, "click on notification fell through")

                compare(secondaryIcon.visible, data.secondaryIconVisible, "secondary-icon visibility is incorrect")
                compare(summaryLabel.visible, data.summaryVisible, "summary-text visibility is incorrect")
                compare(bodyLabel.visible, data.bodyVisible, "body-text visibility is incorrect")
                compare(buttonRow.visible, data.buttonRowVisible, "button visibility is incorrect")

                var audioItem = findInvisibleChild(notification, "sound")
                compare(audioItem.playbackState, data.hasSound ? Audio.PlayingState : Audio.StoppedState, "Audio has wrong state")

                if(data.buttonRowVisible) {
                    var buttonCancel = findChild(buttonRow, "notify_button1")
                    var buttonAccept = findChild(buttonRow, "notify_button0")

                    // only test the left/cancel-button if two actions have been passed in
                    if (data.actions.length == 2) {
                        tryCompareFunction(function() { mouseClick(buttonCancel, buttonCancel.width / 2, buttonCancel.height / 2); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.actions[1]["id"], "got wrong id for negative action")
                        actionSpy.clear()
                    }

                    // check the tinting of the positive/right button
                    verify(buttonAccept.color === data.buttonTinted ? "#3fb24f" : "#dddddd", "button has the wrong color-tint")

                    // click the positive/right button
                    tryCompareFunction(function() { mouseClick(buttonAccept, buttonAccept.width / 2, buttonAccept.height / 2); return actionSpy.signalArguments.length > 0; }, true);
                    compare(actionSpy.signalArguments[0][0], data.actions[0]["id"], "got wrong id positive action")
                    actionSpy.clear()
                    waitForRendering (notification)

                    // check if there's a ComboButton created due to more actions being passed
                    if (data.actions.length > 2) {
                        var comboButton = findChild(notification, "notify_button2")
                        tryCompareFunction(function() { return comboButton.expanded == false; }, true);

                        // click to expand
                        tryCompareFunction(function() { mouseClick(comboButton, comboButton.width - comboButton.__styleInstance.dropDownWidth / 2, comboButton.height / 2); return comboButton.expanded == true; }, true);

                        // try clicking on choices in expanded comboList
                        var choiceButton1 = findChild(notification, "notify_button3")
                        tryCompareFunction(function() { mouseClick(choiceButton1, choiceButton1.width / 2, choiceButton1.height / 2); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.actions[3]["id"], "got wrong id choice action 1")
                        actionSpy.clear()

                        var choiceButton2 = findChild(notification, "notify_button4")
                        tryCompareFunction(function() { mouseClick(choiceButton2, choiceButton2.width / 2, choiceButton2.height / 2); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.actions[4]["id"], "got wrong id choice action 2")
                        actionSpy.clear()

                        // click to collapse
                        //tryCompareFunction(function() { mouseClick(comboButton, comboButton.width - comboButton.__styleInstance.dropDownWidth / 2, comboButton.height / 2); return comboButton.expanded == false; }, true);
                    } else {
                        mouseClick(buttonCancel, buttonCancel.width / 2, buttonCancel.height / 2)
                        compare(actionSpy.signalArguments[0][0], data.actions[1]["id"], "got wrong id for negative action")
                    }
                }
            }
        }
    }
}
