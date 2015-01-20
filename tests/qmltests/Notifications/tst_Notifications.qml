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

import QtQuick 2.0
import QtTest 1.0
import ".."
import "../../../qml/Notifications"
import Ubuntu.Components 0.1
import Unity.Test 0.1
import Unity.Notifications 1.0
import QtMultimedia 5.0

Item {
    id: foobar

    width: notificationsRect.width + interactiveControls.width
    height: notificationsRect.height

    property list<Notification> mockList: [
        Notification {
            id: n0
            nid: 0
            type: Notification.PlaceHolder
            summary: ""
            body: ""
            icon: ""
            secondaryIcon: ""
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n0.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n1
            nid: 1
            type: Notification.SnapDecision
            hints: {"x-canonical-private-affirmative-tint": "true"}
            summary: "Theatre at Ferria Stadium"
            body: "at Ferria Stadium in Bilbao, Spain\n07578545317"
            icon: ""
            secondaryIcon: ""
            rawActions: ["ok_id", "Ok",
                         "snooze_id",  "Snooze",
                         "view_id", "View"]
            Component.onCompleted: {
                n1.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n2
            nid: 2
            type: Notification.Ephemeral
            summary: "Cole Raby"
            body: "I did not expect it to be that late."
            icon: "../graphics/avatars/amanda.png"
            secondaryIcon: "../graphics/applicationIcons/facebook.png"
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n2.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n3
            nid: 3
            type: Notification.Ephemeral
            hints: {"x-canonical-non-shaped-icon": "true"}
            summary: "Contacts"
            body: "Synchronised contacts-database with cloud-storage."
            icon: "../graphics/applicationIcons/contacts-app.png"
            secondaryIcon: ""
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n3.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n4
            nid: 4
            type: Notification.Ephemeral
            hints: {"x-canonical-non-shaped-icon": "false"}
            summary: "Photo upload completed"
            body: ""
            icon: "../graphics/applicationIcons/facebook.png"
            secondaryIcon: ""
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n4.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n5
            nid: 5
            type: Notification.Interactive
            summary: "Interactive notification"
            body: "This is a notification that can be clicked"
            icon: "../graphics/avatars/anna_olsson.png"
            secondaryIcon: ""
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n5.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n6
            nid: 6
            type: Notification.Confirmation
            hints: {"x-canonical-non-shaped-icon": "true"}
            summary: "Confirmation notification"
            body: ""
            icon: "image://theme/audio-volume-medium"
            secondaryIcon: ""
            value: 50
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n6.completed.connect(mockModel.remove)
            }
        },
        Notification {
            id: n7
            nid: 7
            type: Notification.Confirmation
            hints: {"x-canonical-non-shaped-icon": "true",
                    "x-canonical-value-bar-tint": "true"}
            summary: "Confirmation notification"
            body: "High Volume"
            icon: "image://theme/audio-volume-high"
            secondaryIcon: ""
            value: 85
            rawActions: ["reply_id", "Dummy"]
            Component.onCompleted: {
                n7.completed.connect(mockModel.remove)
            }
        }
    ]

    Row {
        id: rootRow

        NotificationModel {
            id: mockModel

            signal actionInvoked(string actionId)

            // add the default/PlaceHolder notification to the model
            Component.onCompleted: {
                append(mockList[0])
            }
        }

        function add2over1SnapDecisionNotification() {
            mockModel.append(mockList[1])
        }

        function addEphemeralNotification() {
            mockModel.append(mockList[2])
        }

        function addEphemeralNonShapedIconNotification() {
            mockModel.append(mockList[3])
        }

        function addEphemeralIconSummaryNotification() {
            mockModel.append(mockList[4])
        }

        function addInteractiveNotification() {
            mockModel.append(mockList[5])
        }

        function addConfirmationNotification() {
            mockModel.append(mockList[6])
        }

        function add2ndConfirmationNotification() {
            mockModel.append(mockList[7])
        }

        function clearNotifications() {
            while(mockModel.count > 1) {
                //remove1stNotification()
            }
        }

        function remove1stNotification() {
            if (mockModel.count > 1) {
                //mockModel.remove(1)
            }
        }

        Rectangle {
            id: notificationsRect

            width: units.gu(40)
            height: units.gu(115)

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
            height: units.gu(115)
            color: "grey"

            Column {
                spacing: units.gu(1)
                anchors.fill: parent
                anchors.margins: units.gu(1)

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
                    text: "add a confirmation"
                    onClicked: rootRow.addConfirmationNotification()
                }

                Button {
                    width: parent.width
                    text: "add a 2nd confirmation"
                    onClicked: rootRow.add2ndConfirmationNotification()
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

        UnityTestCase {
            id: root
            name: "NotificationRendererTest"
            when: windowShown

            function test_NotificationRenderer_data() {
                return [
                {
                    tag: "2-over-1 Snap Decision with button-tint",
                    type: Notification.SnapDecision,
                    nid: 2,
                    hints: {"x-canonical-private-affirmative-tint": "true"},
                    summary: "Theatre at Ferria Stadium",
                    body: "at Ferria Stadium in Bilbao, Spain\n07578545317",
                    icon: "",
                    secondaryIcon: "",
                    value: 0,
                    actions: [{ id: "ok_id", label: "Ok"},
                              { id: "snooze_id", label: "Snooze"},
                              { id: "view_id", label: "View"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: false,
                    centeredIconVisible: false,
                    shaped: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: true,
                    hasSound: false,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Ephemeral notification - icon-summary layout",
                    type: Notification.Ephemeral,
                    nid: 3,
                    hints: {},
                    summary: "Photo upload completed",
                    body: "",
                    icon: "../graphics/applicationIcons/facebook.png",
                    secondaryIcon: "",
                    value: 0,
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: false,
                    iconVisible: true,
                    centeredIconVisible: false,
                    shaped: true,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Ephemeral notification - check suppression of secondary icon for icon-summary layout",
                    type: Notification.Ephemeral,
                    nid: 4,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg",
                            "suppress-sound": "true"},
                    summary: "New comment successfully published",
                    body: "",
                    icon: "",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    value: 0,
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: false,
                    interactiveAreaEnabled: false,
                    iconVisible: false,
                    centeredIconVisible: false,
                    shaped: false,
                    secondaryIconVisible: true,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Interactive notification",
                    type: Notification.Interactive,
                    nid: 5,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Interactive notification",
                    body: "This is a notification that can be clicked",
                    icon: "../graphics/avatars/amanda.png",
                    secondaryIcon: "",
                    value: 0,
                    actions: [{ id: "reply_id", label: "Dummy"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    centeredIconVisible: false,
                    shaped: true,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: true,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Snap Decision without secondary icon and no button-tint",
                    type: Notification.SnapDecision,
                    nid: 6,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Bro Coly",
                    body: "At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
                    icon: "../graphics/avatars/anna_olsson.png",
                    secondaryIcon: "",
                    value: 0,
                    actions: [{ id: "accept_id", label: "Accept"},
                              { id: "reject_id", label: "Reject"}],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    centeredIconVisible: false,
                    shaped: true,
                    secondaryIconVisible: false,
                    buttonRowVisible: true,
                    buttonTinted: false,
                    hasSound: true,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Ephemeral notification",
                    type: Notification.Ephemeral,
                    nid: 7,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"},
                    summary: "Cole Raby",
                    body: "I did not expect it to be that late.",
                    icon: "../graphics/avatars/funky.png",
                    secondaryIcon: "../graphics/applicationIcons/facebook.png",
                    value: 0,
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    centeredIconVisible: false,
                    shaped: true,
                    secondaryIconVisible: true,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: true,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Ephemeral notification with non-shaped icon",
                    type: Notification.Ephemeral,
                    nid: 8,
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "x-canonical-non-shaped-icon": "true"},
                    summary: "Contacts",
                    body: "Synchronised contacts-database with cloud-storage.",
                    icon: "image://theme/contacts-app",
                    secondaryIcon: "",
                    value: 0,
                    actions: [],
                    summaryVisible: true,
                    bodyVisible: true,
                    iconVisible: true,
                    centeredIconVisible: false,
                    shaped: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false,
                    valueVisible: false,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Confirmation notification with value",
                    type: Notification.Confirmation,
                    nid: 9,
                    hints: {"x-canonical-non-shaped-icon": "true"},
                    summary: "",
                    body: "",
                    icon: "image://theme/audio-volume-medium",
                    secondaryIcon: "",
                    value: 50,
                    actions: [],
                    summaryVisible: false,
                    bodyVisible: false,
                    iconVisible: false,
                    centeredIconVisible: true,
                    shaped: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false,
                    valueVisible: true,
                    valueLabelVisible: false,
                    valueTinted: false
                },
                {
                    tag: "Confirmation notification with value, label and tint",
                    type: Notification.Confirmation,
                    nid: 10,
                    hints: {"x-canonical-non-shaped-icon": "true",
                            "x-canonical-value-bar-tint" : "true"},
                    summary: "",
                    body: "High Volume",
                    icon: "image://theme/audio-volume-high",
                    secondaryIcon: "",
                    value: 85,
                    actions: [],
                    summaryVisible: false,
                    bodyVisible: false,
                    iconVisible: false,
                    centeredIconVisible: true,
                    shaped: false,
                    secondaryIconVisible: false,
                    buttonRowVisible: false,
                    buttonTinted: false,
                    hasSound: false,
                    valueVisible: true,
                    valueLabelVisible: true,
                    valueTinted: true
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
                var centeredIcon = findChild(notification, "centeredIcon")
                var interactiveArea = findChild(notification, "interactiveArea")
                var secondaryIcon = findChild(notification, "secondaryIcon")
                var summaryLabel = findChild(notification, "summaryLabel")
                var bodyLabel = findChild(notification, "bodyLabel")
                var buttonRow = findChild(notification, "buttonRow")
                var valueIndicator = findChild(notification, "valueIndicator")
                var valueLabel = findChild(notification, "valueLabel")
                var innerBar = findChild(notification, "innerBar")

                compare(icon.visible, data.iconVisible, "avatar-icon visibility is incorrect")
                if (icon.visible) {
                    compare(icon.shaped, data.shaped, "shaped-status is incorrect")
                }
                compare(centeredIcon.visible, data.centeredIconVisible, "centered-icon visibility is incorrect")
                if (centeredIcon.visible) {
                    compare(centeredIcon.shaped, data.shaped, "shaped-status is incorrect")
                }
                compare(valueIndicator.visible, data.valueVisible, "value-indicator visibility is incorrect")
                if (valueIndicator.visible) {
                    verify(innerBar.color === data.valueTinted ? UbuntuColors.orange : "white", "value-bar has the wrong color-tint")
                }
                compare(valueLabel.visible, data.valueLabelVisible, "value-label visibility is incorrect")

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

                // swipe-to-dismiss check
                var before = mockModel.count
                var dragStart = notification.width * 0.25;
                var dragEnd = notification.width;
                var dragY = notification.height / 2;
                touchFlick(notification, dragStart, dragY, dragEnd, dragY)
                waitForRendering(notification)
                if (data.type !== Notification.SnapDecision && notification.state !== "expanded") {
                    tryCompare(mockModel, "count", before - 1)
                } else {
                    tryCompare(mockModel, "count", before)
                }
            }
        }
    }
}
