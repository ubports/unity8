/*
 * Copyright 2015-2016 Canonical Ltd.
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
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtTest 1.0
import ".."
import "../../../qml/Notifications"
import Ubuntu.Components 1.3
import Unity.Test 0.1
import Unity.Notifications 1.0
import QtMultimedia 5.0

Item {
    id: foobar

    width: notificationsRect.width + interactiveControls.width
    height: notificationsRect.height
    property int index: 0

    Row {
        id: rootRow

        NotificationModel {
            id: mockModel
        }

        function add2over1SnapDecisionNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.SnapDecision,
                                                            "hints": {"x-canonical-private-affirmative-tint": "true"},
                                                            "summary": "Theatre at Ferria Stadium",
                                                            "body": "at Ferria Stadium in Bilbao, Spain\n07578545317",
                                                            "icon": "",
                                                            "secondaryIcon": "",
                                                            "rawActions": ["ok_id",     "Ok",
                                                                           "snooze_id", "Snooze",
                                                                           "view_id",   "View"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function addEphemeralNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Ephemeral,
                                                            "hints": {},
                                                            "summary": "Cole Raby",
                                                            "body": "I did not expect it to be <b>that</b> late.",
                                                            "icon": "../../tests/graphics/avatars/amanda.png",
                                                            "secondaryIcon": "../../tests/graphics/applicationIcons/facebook.png",
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function addEphemeralNonShapedIconNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Ephemeral,
                                                            "hints": {"x-canonical-non-shaped-icon": "true"},
                                                            "summary": "Contacts",
                                                            "body": "Synchronised contacts-database &amp; cloud-storage.",
                                                            "icon": "../../tests/graphics/applicationIcons/contacts-app.png",
                                                            "secondaryIcon": "",
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function addEphemeralIconSummaryNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Ephemeral,
                                                            "hints": {"x-canonical-non-shaped-icon": "false"},
                                                            "summary": "Photo upload completed",
                                                            "body": "",
                                                            "icon": "../../tests/graphics/applicationIcons/facebook.png",
                                                            "secondaryIcon": "",
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function addInteractiveNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Interactive,
                                                            "hints": {},
                                                            "summary": "Interactive notification",
                                                            "body": "This is a notification that can be clicked",
                                                            "icon": "../../tests/graphics/avatars/anna_olsson.png",
                                                            "secondaryIcon": "",
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function addConfirmationNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Confirmation,
                                                            "hints": {"x-canonical-non-shaped-icon": "true"},
                                                            "summary": "Confirmation notification",
                                                            "body": "",
                                                            "icon": "image://theme/audio-volume-medium",
                                                            "secondaryIcon": "",
                                                            "value": 50,
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function add2ndConfirmationNotification() {
            var component = Qt.createComponent("Notification.qml")
            var n = component.createObject("notification", {"nid": index++,
                                                            "type": Notification.Confirmation,
                                                            "hints": {"x-canonical-non-shaped-icon": "true",
                                                                      "x-canonical-value-bar-tint": "true"},
                                                            "summary": "Confirmation notification",
                                                            "body": "High Volume",
                                                            "icon": "image://theme/audio-volume-high",
                                                            "secondaryIcon": "",
                                                            "value": 85,
                                                            "rawActions": ["reply_id", "Dummy"]})
            n.completed.connect(mockModel.onCompleted)
            mockModel.append(n)
        }

        function clearNotifications() {
            while(mockModel.count > 0) {
                remove1stNotification();
            }
        }

        function remove1stNotification() {
            mockModel.removeFirst();
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
                hasMouse: fakeMouseCB.checked
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
                    text: "add a non-shaped-icon-summary-body"
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

                RowLayout {
                    Layout.fillWidth: true
                    CheckBox {
                        id: fakeMouseCB
                    }
                    Label {
                        text: "With fake mouse"
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

            property list<Notification> nlist: [
                Notification {
                    nid: 1
                    type: Notification.Ephemeral
                    summary: "Photo upload completed"
                    body: ""
                    icon: "../../tests/graphics/applicationIcons/facebook.png"
                    secondaryIcon: ""
                    value: 0
                    rawActions: []
                },
                Notification {
                    nid: 2
                    type: Notification.Ephemeral
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg",
                            "suppress-sound": "true"}
                    summary: "New comment successfully published"
                    body: ""
                    icon: ""
                    secondaryIcon: "../../tests/graphics/applicationIcons/facebook.png"
                    value: 0
                    rawActions: []
                },
                Notification {
                    nid: 3
                    type: Notification.Interactive
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"}
                    summary: "Interactive notification"
                    body: "This is a notification that can be clicked"
                    icon: "../../tests/graphics/avatars/amanda.png"
                    secondaryIcon: ""
                    value: 0
                    rawActions: ["reply_id", "Dummy"]
                },
                Notification {
                    nid: 4
                    type: Notification.SnapDecision
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"}
                    summary: "Bro Coly"
                    body: "At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
                    icon: "../../tests/graphics/avatars/anna_olsson.png"
                    secondaryIcon: ""
                    value: 0
                    rawActions: ["accept_id", "Accept",
                                 "reject_id", "Reject"]
                },
                Notification {
                    nid: 5
                    type: Notification.Ephemeral
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "sound-file": "dummy.ogg"}
                    summary: "Cole Raby"
                    body: "I did not expect it to be that late."
                    icon: "../../tests/graphics/avatars/funky.png"
                    secondaryIcon: "../../tests/graphics/applicationIcons/facebook.png"
                    value: 0
                    rawActions: []
                },
                Notification {
                    nid: 6
                    type: Notification.Ephemeral
                    hints: {"x-canonical-private-affirmative-tint": "false",
                            "x-canonical-non-shaped-icon": "true"}
                    summary: "Contacts"
                    body: "Synchronised contacts-database with cloud-storage."
                    icon: "image://theme/contacts-app"
                    secondaryIcon: ""
                    value: 0
                    rawActions: []
                },
                Notification {
                    nid: 7
                    type: Notification.Confirmation
                    hints: {"x-canonical-non-shaped-icon": "true"}
                    summary: ""
                    body: ""
                    icon: "image://theme/audio-volume-medium"
                    secondaryIcon: ""
                    value: 50
                    rawActions: []
                },
                Notification {
                    nid: 8
                    type: Notification.Confirmation
                    hints: {"x-canonical-non-shaped-icon": "true",
                            "x-canonical-value-bar-tint" : "true"}
                    summary: ""
                    body: "High Volume"
                    icon: "image://theme/audio-volume-high"
                    secondaryIcon: ""
                    value: 85
                    rawActions: []
                },
                Notification {
                    nid: 9
                    type: Notification.SnapDecision
                    hints: {"x-canonical-private-affirmative-tint": "true"}
                    summary: "Theatre at Ferria Stadium"
                    body: "at Ferria Stadium in Bilbao, Spain\n07578545317"
                    icon: ""
                    secondaryIcon: ""
                    value: 0
                    rawActions: ["ok_id",     "Ok",
                                 "snooze_id", "Snooze",
                                 "view_id",   "View"]
                }
            ]

            function test_NotificationRenderer_data() {
                return [
                {
                    tag: "Ephemeral notification - icon-summary layout",
                    n: nlist[0],
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
                    n: nlist[1],
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
                    n: nlist[2],
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
                    n: nlist[3],
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
                    n: nlist[4],
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
                    n: nlist[5],
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
                    n: nlist[6],
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
                    n: nlist[7],
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
                },
                {
                    tag: "2-over-1 Snap Decision with button-tint",
                    n: nlist[8],
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

            function init() {
                while (mockModel.count > 0) {
                    mockModel.remove(0);
                }
            }

            function cleanup() {
                clickThroughSpy.clear()
                actionSpy.clear()
            }

            function test_NotificationRenderer(data) {
                // make sure the clicks on mocked notifications can be checked against by "actionSpy" (mimicking the NotificationServer component)
                data.n.actionInvoked.connect(mockModel.actionInvoked)

                // hook up notification's completed-signal with model's onCompleted-slot, so that remove() (model) happens on close() (notification)
                data.n.completed.connect(mockModel.onCompleted)

                // populate model with some mock notifications
                mockModel.append(data.n)

                // make sure the view is properly updated before going on
                notifications.forceLayout();
                waitForRendering(notifications);

                var notification = findChild(notifications, "notification" + (mockModel.count - 1))
                waitForRendering(notification);
                verify(notification, "notification wasn't found");
                tryCompare(notification, "height", notification.implicitHeight);

                var icon = findChild(notification, "icon")
                var centeredIcon = findChild(notification, "centeredIcon")
                var interactiveArea = findChild(notification, "interactiveArea")
                var secondaryIcon = findChild(notification, "secondaryIcon")
                var summaryLabel = findChild(notification, "summaryLabel")
                var bodyLabel = findChild(notification, "bodyLabel")
                var buttonRow = findChild(notification, "buttonRow")
                var valueIndicator = findChild(notification, "valueIndicator")
                var valueLabel = findChild(notification, "valueLabel")

                compare(icon.visible, data.iconVisible, "avatar-icon visibility is incorrect")
                if (icon.visible) {
                    compare(icon.shaped, data.shaped, "shaped-status is incorrect")
                }
                compare(centeredIcon.visible, data.centeredIconVisible, "centered-icon visibility is incorrect")
                if (centeredIcon.visible) {
                    compare(centeredIcon.shaped, data.shaped, "shaped-status is incorrect")
                }
                compare(valueIndicator.visible, data.valueVisible, "value-indicator visibility is incorrect")
                compare(valueLabel.visible, data.valueLabelVisible, "value-label visibility is incorrect")

                // test input does not fall through
                mouseClick(notification)
                if(data.n.type === Notification.Interactive) {
                    actionSpy.wait()
                    compare(actionSpy.signalArguments[0][0], data.n.actions.data(0, ActionModel.RoleActionId), "got wrong id for interactive action")
                }
                compare(clickThroughSpy.count, 0, "click on notification fell through")

                compare(secondaryIcon.visible, data.secondaryIconVisible, "secondary-icon visibility is incorrect")
                compare(summaryLabel.visible, data.summaryVisible, "summary-text visibility is incorrect")
                compare(bodyLabel.visible, data.bodyVisible, "body-text visibility is incorrect")
                compare(buttonRow.visible, data.buttonRowVisible, "button visibility is incorrect")

                // After clicking the state of notifications can change so let's wait
                // for their height animations to finish before continuing
                for (var i = 0; i < mockModel.count; ++i) {
                    var n = findChild(notifications, "notification" + i)
                    if (n.type === Notification.PlaceHolder)
                        continue;
                    waitForRendering(n);
                    var outterColumn = findChild(n, "outterColumn");
                    var shapedBack = findChild(n, "shapedBack");
                    tryCompare(n, "height", outterColumn.height + n.margins * 2 + shapedBack.anchors.topMargin);
                }

                if (data.hasSound) {
                    var audioItem = findInvisibleChild(notification, "sound")
                    compare(audioItem.playbackState, data.hasSound ? Audio.PlayingState : Audio.StoppedState, "Audio has wrong state")
                }

                if(data.buttonRowVisible) {
                    var buttonCancel = findChild(buttonRow, "notify_button1")
                    var buttonAccept = findChild(buttonRow, "notify_button0")

                    // only test the left/cancel-button if two actions have been passed in
                    if (data.n.actions.count === 2) {
                        tryCompareFunction(function() { mouseClick(buttonCancel); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.n.actions.data(1, ActionModel.RoleActionId), "got wrong id for negative action")
                        actionSpy.clear()
                    }

                    // check the tinting of the positive/right button
                    verify(buttonAccept.color === data.buttonTinted ? "#3fb24f" : "#dddddd", "button has the wrong color-tint")

                    // click the positive/right button
                    tryCompareFunction(function() { mouseClick(buttonAccept); return actionSpy.signalArguments.length > 0; }, true);
                    compare(actionSpy.signalArguments[0][0], data.n.actions.data(0, ActionModel.RoleActionId), "got wrong id positive action")
                    actionSpy.clear()

                    // check if there's a ComboButton created due to more actions being passed
                    if (data.n.actions.count > 3) {
                        var comboButton = findChild(notification, "notify_button2")
                        tryCompareFunction(function() { return comboButton.expanded === false; }, true);

                        // click to expand
                        tryCompareFunction(function() { mouseClick(comboButton, comboButton.width / 2, comboButton.height / 2); return comboButton.expanded; }, true);

                        // try clicking on choices in expanded comboList
                        var choiceButton1 = findChild(notification, "notify_button3")
                        tryCompareFunction(function() { mouseClick(choiceButton1); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.n.actions.data(3, ActionModel.RoleActionId), "got wrong id choice action 1")
                        actionSpy.clear()

                        var choiceButton2 = findChild(notification, "notify_button4")
                        tryCompareFunction(function() { mouseClick(choiceButton2); return actionSpy.signalArguments.length > 0; }, true);
                        compare(actionSpy.signalArguments[0][0], data.n.actions.data(4, ActionModel.RoleActionId), "got wrong id choice action 2")
                        actionSpy.clear()

                        // click to collapse
                        tryCompareFunction(function() { mouseClick(comboButton, comboButton.width / 2, comboButton.height / 2); return !comboButton.expanded; }, true);
                    } else {
                        mouseClick(buttonCancel)
                        compare(actionSpy.signalArguments[0][0], data.n.actions.data(1, ActionModel.RoleActionId), "got wrong id for negative action")
                    }
                }

                // swipe-to-dismiss check
                waitForRendering(notification)
                var before = mockModel.count
                var dragStart = notification.width * 0.25;
                var dragEnd = notification.width;
                var dragY = notification.height / 2;
                touchFlick(notification, dragStart, dragY, dragEnd, dragY)
                waitForRendering(notification)
                tryCompare(mockModel, "count", before - 1)
            }

            function test_closeButton_data() { // reuse the data
                notifications.hasMouse = true;
                return test_NotificationRenderer_data();
            }

            function test_closeButton(data) {
                // hook up notification's completed-signal with model's onCompleted-slot, so that remove() (model) happens on close() (notification)
                data.n.completed.connect(mockModel.onCompleted)

                // populate model with some mock notifications
                mockModel.append(data.n)

                // make sure the view is properly updated before going on
                notifications.forceLayout();
                waitForRendering(notifications);

                var notification = findChild(notifications, "notification" + (mockModel.count - 1))
                waitForRendering(notification);
                verify(!!notification, "notification wasn't found");

                // close button check
                mouseMove(notification, notification.width/2, notification.height/2);
                var closeButton = findChild(notification, "closeButton");
                tryCompare(closeButton, "visible", true);
                var before = mockModel.count;
                mouseClick(closeButton);
                waitForRendering(notification);

                // closing the notification, the model count should be one less
                tryCompare(mockModel, "count", before - 1)
            }

            function expansionLogic_data() {
                return [{
                            tag: "Snap Decision without secondary icon and no button-tint",
                            n: nlist[3],
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
                            tag: "2-over-1 Snap Decision with button-tint",
                            n: nlist[8],
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
                            tag: "Snap Decision without secondary icon and no button-tint",
                            n: nlist[3],
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
                        }
                        ]
            }

            function test_expansionLogic() {
                var data = expansionLogic_data();

                // fill the model
                data.forEach(function(notification) {
                    mockModel.append(notification.n);
                    notification.n.completed.connect(mockModel.onCompleted)
                })

                // make sure the view is properly updated before going on
                notifications.forceLayout();
                waitForRendering(notifications);

                // first one should be expanded by default
                var notification1 = findChild(notifications, "notification0")
                verify(!!notification1, "notification wasn't found");
                waitForRendering(notification1);
                verify(notification1.expanded);

                // click the 2nd one, verify it's now expanded
                var notification2 = findChild(notifications, "notification1")
                verify(!!notification2, "notification wasn't found");
                waitForRendering(notification2);
                mouseClick(notification2);
                verify(notification2.expanded);
                verify(!notification1.expanded);

                // now close the 2nd one, verify 1st is again expanded, 2nd is gone
                var dragStart = notification2.width * 0.25;
                var dragEnd = notification2.width;
                var dragY = notification2.height / 2;
                touchFlick(notification2, dragStart, dragY, dragEnd, dragY);
                waitForRendering(notifications);
                tryCompareFunction(function() { return notification1.expanded; }, true);
                tryCompareFunction(function() { return notification2.expanded; }, undefined);
            }

            function cleanupTestCase() {
                notifications.hasMouse = false;
            }
        }
    }
}
