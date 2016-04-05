/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import Powerd 0.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Notifications 1.0
import QMenuModel 0.1
import Utils 0.1
import "../Components"

StyledItem {
    id: notification

    property alias iconSource: icon.fileSource
    property alias secondaryIconSource: secondaryIcon.source
    property alias summary: summaryLabel.text
    property alias body: bodyLabel.text
    property alias value: valueIndicator.value
    property var actions
    property var notificationId
    property var type
    property var hints
    property var notification
    property color color: theme.palette.normal.overlay
    property bool fullscreen: false
    property int maxHeight
    property int margins: units.gu(1)
    readonly property bool draggable: (type === Notification.SnapDecision && state === "contracted") ||
                                      type === Notification.Interactive ||
                                      type === Notification.Ephemeral
    readonly property bool canBeClosed: type === Notification.Ephemeral
    readonly property real defaultOpacity: 0.95
    property bool hasMouse
    property url background: ""

    objectName: "background"
    implicitHeight: type !== Notification.PlaceHolder ? (fullscreen ? maxHeight : outterColumn.height + margins * 2) : 0

    // FIXME: non-zero initially because of LP: #1354406 workaround, we want this to start at 0 upon creation eventually
    opacity: defaultOpacity - Math.abs(x / notification.width)

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    state: {
        var result = "";

        if (type === Notification.SnapDecision) {
            if (ListView.view.currentIndex === index) {
                result = "expanded";
            } else {
                if (ListView.view.count > 2) {
                    if (ListView.view.currentIndex === -1 && index == 1) {
                        result = "expanded";
                    } else {
                        result = "contracted";
                    }
                } else {
                    result = "expanded";
                }
            }
        }

        return result;
    }

    NotificationAudio {
        id: sound
        objectName: "sound"
        source: hints["suppress-sound"] !== "true" && hints["sound-file"] !== undefined ? hints["sound-file"] : ""
    }

    Component.onCompleted: {
        // Turn on screen as needed (Powerd.Notification means the screen
        // stays on for a shorter amount of time)
        if (type === Notification.SnapDecision) {
            Powerd.setStatus(Powerd.On, Powerd.SnapDecision);
        } else if (type !== Notification.Confirmation) {
            Powerd.setStatus(Powerd.On, Powerd.Notification);
        }

        // FIXME: using onCompleted because of LP: #1354406 workaround, has to be onOpacityChanged really
        if (opacity == defaultOpacity && hints["suppress-sound"] !== "true" && sound.source !== "") {
            sound.play();
        }
    }

    Behavior on x {
        enabled: draggable
        UbuntuNumberAnimation { easing.type: Easing.OutBounce }
    }

    onHintsChanged: {
        if (type === Notification.Confirmation && opacity == defaultOpacity && hints["suppress-sound"] !== "true" && sound.source !== "") {
            sound.play();
        }
    }

    Behavior on height {
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.SnapDuration
        }
    }

    states:[
        State {
            name: "contracted"
            PropertyChanges {target: notification; height: topRow.childrenRect.height + notification.margins * 2}
        },
        State {
            name: "expanded"
            PropertyChanges {target: notification; height: implicitHeight}
        }
    ]

    visible: type !== Notification.PlaceHolder

    BorderImage {
        anchors {
            fill: contents
            margins: shapedBack.visible ? -units.gu(1) : -units.gu(1.5)
        }
        source: "../Stages/graphics/dropshadow2gu.sci"
        opacity: notification.opacity * 0.5
        enabled: !fullscreen
    }

    UbuntuShape {
        id: shapedBack

        visible: !fullscreen
        anchors {
            fill: parent
        }
        backgroundColor: parent.color
        radius: "medium"
        aspect: UbuntuShape.Flat
    }

    Rectangle {
        id: nonShapedBack

        visible: fullscreen
        anchors.fill: parent
        color: parent.color
    }

    onXChanged: {
        if (draggable && Math.abs(notification.x) > 0.75 * notification.width) {
            notification.notification.close()
        }
    }

    Item {
        id: contents
        anchors.fill: fullscreen ? nonShapedBack : shapedBack

        UnityMenuModelPaths {
            id: paths

            source: hints["x-canonical-private-menu-model"]

            busNameHint: "busName"
            actionsHint: "actions"
            menuObjectPathHint: "menuPath"
        }

        UnityMenuModel {
            id: unityMenuModel

            property string lastNameOwner: ""

            busName: paths.busName
            actions: paths.actions
            menuObjectPath: paths.menuObjectPath
            onNameOwnerChanged: {
                if (lastNameOwner !== "" && nameOwner === "" && notification.notification !== undefined) {
                    notification.notification.close()
                }
                lastNameOwner = nameOwner
            }
        }

        MouseArea {
            id: interactiveArea

            anchors.fill: parent
            objectName: "interactiveArea"

            drag.target: draggable ? notification : undefined
            drag.axis: Drag.XAxis
            drag.minimumX: -notification.width
            drag.maximumX: notification.width

            onClicked: {
                if (notification.type === Notification.Interactive) {
                    notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
                } else if (hasMouse && canBeClosed) {
                    notification.notification.close()
                } else {
                    notificationList.currentIndex = index;
                }
            }
            onReleased: {
                if (Math.abs(notification.x) < notification.width / 2) {
                    notification.x = 0
                } else {
                    notification.x = notification.width
                }
            }
        }

        Column {
            id: outterColumn

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: notification.margins
            }

            spacing: notification.margins

            Row {
                id: topRow

                spacing: notification.margins
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ShapedIcon {
                    id: icon

                    objectName: "icon"
                    width: units.gu(6)
                    height: width
                    shaped: notification.hints["x-canonical-non-shaped-icon"] !== "true"
                    visible: iconSource !== "" && type !== Notification.Confirmation
                }

                Column {
                    id: labelColumn
                    width: secondaryIcon.visible ? parent.width - x - units.gu(4.5) : parent.width - x

                    anchors.verticalCenter: (icon.visible && !bodyLabel.visible) ? icon.verticalCenter : undefined

                    Label {
                        id: summaryLabel

                        objectName: "summaryLabel"
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        visible: type !== Notification.Confirmation
                        fontSize: "medium"
                        font.weight: Font.Light
                        color: theme.palette.normal.backgroundSecondaryText
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Label {
                        id: bodyLabel

                        objectName: "bodyLabel"
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        visible: body != "" && type !== Notification.Confirmation
                        fontSize: "small"
                        font.weight: Font.Light
                        color: theme.palette.normal.backgroundTertiaryText
                        wrapMode: Text.Wrap
                        maximumLineCount: type === Notification.SnapDecision ? 12 : 2
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }

                Image {
                    id: secondaryIcon

                    objectName: "secondaryIcon"
                    width: units.gu(3)
                    height: units.gu(3)
                    visible: status === Image.Ready
                    fillMode: Image.PreserveAspectCrop
                }
            }

            ListItem.ThinDivider {
                visible: type === Notification.SnapDecision && notification.state !== "contracted"
            }

            ShapedIcon {
                id: centeredIcon
                objectName: "centeredIcon"
                width: units.gu(6)
                height: width
                shaped: notification.hints["x-canonical-non-shaped-icon"] !== "true"
                fileSource: icon.fileSource
                visible: fileSource !== "" && type === Notification.Confirmation
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: valueLabel
                objectName: "valueLabel"
                text: body
                anchors.horizontalCenter: parent.horizontalCenter
                visible: type === Notification.Confirmation && body !== ""
                fontSize: "medium"
                font.weight: Font.Light
                color: theme.palette.normal.backgroundSecondaryText
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            ProgressBar {
                id: valueIndicator
                objectName: "valueIndicator"
                visible: type === Notification.Confirmation
                minimumValue: 0
                maximumValue: 100
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(2)
            }

            Column {
                id: dialogColumn
                objectName: "dialogListView"
                spacing: notification.margins

                visible: count > 0

                anchors {
                    left: parent.left
                    right: parent.right
                    top: fullscreen ? parent.top : undefined
                    bottom: fullscreen ? parent.bottom : undefined
                }

                Repeater {
                    model: unityMenuModel

                    NotificationMenuItemFactory {
                        id: menuItemFactory

                        anchors {
                            left: dialogColumn.left
                            right: dialogColumn.right
                        }

                        menuModel: unityMenuModel
                        menuData: model
                        menuIndex: index
                        maxHeight: notification.maxHeight
                        background: notification.background

                        onLoaded: {
                            notification.fullscreen = Qt.binding(function() { return fullscreen; });
                        }
                        onAccepted: {
                            notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
                        }
                    }
                }
            }

            Column {
                id: oneOverTwoCase

                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: notification.margins

                visible: notification.type === Notification.SnapDecision && oneOverTwoRepeaterTop.count === 3 && notification.state === "expanded"

                Repeater {
                    id: oneOverTwoRepeaterTop

                    model: notification.actions
                    delegate: Loader {
                        id: oneOverTwoLoaderTop

                        property string actionId: id
                        property string actionLabel: label

                        Component {
                            id: oneOverTwoButtonTop

                            Button {
                                objectName: "notify_oot_button" + index
                                width: oneOverTwoCase.width
                                text: oneOverTwoLoaderTop.actionLabel
                                color: notification.hints["x-canonical-private-affirmative-tint"] === "true" ? theme.palette.normal.positive
                                                                                                             : theme.palette.normal.baseText
                                onClicked: notification.notification.invokeAction(oneOverTwoLoaderTop.actionId)
                            }
                        }
                        sourceComponent: index == 0 ? oneOverTwoButtonTop : undefined
                    }
                }

                Row {
                    spacing: notification.margins

                    Repeater {
                        id: oneOverTwoRepeaterBottom

                        model: notification.actions
                        delegate: Loader {
                            id: oneOverTwoLoaderBottom

                            property string actionId: id
                            property string actionLabel: label

                            Component {
                                id: oneOverTwoButtonBottom

                                Button {
                                    objectName: "notify_oot_button" + index
                                    width: oneOverTwoCase.width / 2 - spacing / 2
                                    text: oneOverTwoLoaderBottom.actionLabel
                                    color: index == 1 && notification.hints["x-canonical-private-rejection-tint"] === "true" ? theme.palette.normal.negative
                                                                                                                             : theme.palette.normal.baseText
                                    onClicked: notification.notification.invokeAction(oneOverTwoLoaderBottom.actionId)
                                }
                            }
                            sourceComponent: (index == 1 || index == 2) ? oneOverTwoButtonBottom : undefined
                        }
                    }
                }
            }

            Row {
                id: buttonRow

                objectName: "buttonRow"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                visible: notification.type === Notification.SnapDecision && actionRepeater.count > 0 && !oneOverTwoCase.visible && notification.state === "expanded"
                spacing: notification.margins
                layoutDirection: Qt.RightToLeft

                Loader {
                    id: notifySwipeButtonLoader
                    active: notification.hints["x-canonical-snap-decisions-swipe"] === "true"

                    sourceComponent: SwipeToAct  {
                        objectName: "notify_swipe_button"
                        width: buttonRow.width
                        leftIconName: "call-end"
                        rightIconName: "call-start"
                        clickToAct: notification.hasMouse
                        onRightTriggered: {
                            notification.notification.invokeAction(notification.actions.data(0, ActionModel.RoleActionId))
                        }

                        onLeftTriggered: {
                            notification.notification.invokeAction(notification.actions.data(1, ActionModel.RoleActionId))
                        }
                    }
                }

                Repeater {
                    id: actionRepeater
                    model: notification.actions
                    delegate: Loader {
                        id: loader

                        property string actionId: id
                        property string actionLabel: label
                        active: !notifySwipeButtonLoader.active

                        Component {
                            id: actionButton

                            Button {
                                objectName: "notify_button" + index
                                width: buttonRow.width / 2 - spacing * 2
                                text: loader.actionLabel
                                color: {
                                    var result = theme.palette.normal.baseText;
                                    if (index == 0 && notification.hints["x-canonical-private-affirmative-tint"] === "true") {
                                        result = theme.palette.normal.positive;
                                    }
                                    if (index == 1 && notification.hints["x-canonical-private-rejection-tint"] === "true") {
                                        result = theme.palette.normal.negative;
                                    }
                                    return result;
                                }
                                onClicked: notification.notification.invokeAction(loader.actionId)
                            }
                        }
                        sourceComponent: (index == 0 || index == 1) ? actionButton : undefined
                    }
                }
            }

            OptionToggle {
                id: optionToggle
                objectName: "notify_button2"
                width: parent.width
                anchors {
                    left: parent.left
                    right: parent.right
                }

                visible: notification.type === Notification.SnapDecision && actionRepeater.count > 3 && !oneOverTwoCase.visible && notification.state === "expanded"
                model: notification.actions
                expanded: false
                startIndex: 2
                onTriggered: {
                    notification.notification.invokeAction(id)
                }
            }
        }
    }
}
