/*
 * Copyright (C) 2013, 2015 Canonical, Ltd.
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
    property color color
    property bool fullscreen: false
    property int maxHeight
    property int margins
    readonly property bool draggable: (type === Notification.SnapDecision && state === "contracted") || type === Notification.Interactive || type === Notification.Ephemeral
    readonly property bool darkOnBright: panel.indicators.shown || type === Notification.SnapDecision
    readonly property color red: "#fc4949"
    readonly property color green: "#3fb24f"
    readonly property color sdLightGrey: "#eaeaea"
    readonly property color sdDarkGrey: "#dddddd"
    readonly property color sdFontColor: "#5d5d5d"
    readonly property real contentSpacing: units.gu(2)
    readonly property bool canBeClosed: type === Notification.Ephemeral
    property bool hasMouse
    property url background: ""

    objectName: "background"
    implicitHeight: type !== Notification.PlaceHolder ? (fullscreen ? maxHeight : outterColumn.height - shapedBack.anchors.topMargin + contentSpacing * 2) : 0

    color: (type === Notification.Confirmation && notificationList.useModal && !greeter.shown) || darkOnBright ? sdLightGrey : Qt.rgba(0.132, 0.117, 0.109, 0.97)
    opacity: 1 - (x / notification.width) // FIXME: non-zero initially because of LP: #1354406 workaround, we want this to start at 0 upon creation eventually

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    state: {
        var result = "";

        if (type == Notification.SnapDecision) {
            if (ListView.view.currentIndex == index) {
                result = "expanded";
            } else {
                if (ListView.view.count > 2) {
                    if (ListView.view.currentIndex == -1 && index == 1) {
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
        if (type == Notification.SnapDecision) {
            Powerd.setStatus(Powerd.On, Powerd.SnapDecision);
        } else if (type != Notification.Confirmation) {
            Powerd.setStatus(Powerd.On, Powerd.Notification);
        }

        // FIXME: using onCompleted because of LP: #1354406 workaround, has to be onOpacityChanged really
        if (opacity == 1.0 && hints["suppress-sound"] !== "true" && sound.source !== "") {
            sound.play();
        }
    }

    Behavior on x {
        id: normalXBehavior

        enabled: draggable
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.FastDuration
            easing.type: Easing.OutBounce
        }
    }

    onHintsChanged: {
        if (type === Notification.Confirmation && opacity == 1.0 && hints["suppress-sound"] !== "true" && sound.source !== "") {
            sound.play();
        }
    }

    Behavior on height {
        id: normalHeightBehavior

        //enabled: menuItemFactory.progress == 1
        enabled: true
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.SnapDuration
        }
    }

    states:[
        State {
            name: "contracted"
            PropertyChanges {target: notification; height: units.gu(10)}
        },
        State {
            name: "expanded"
            PropertyChanges {target: notification; height: implicitHeight}
        }
    ]

    clip: fullscreen ? false : true

    visible: type != Notification.PlaceHolder

    UbuntuShape {
        id: shapedBack

        visible: !fullscreen
        anchors {
            fill: parent
            leftMargin: notification.margins
            rightMargin: notification.margins
            topMargin: type === Notification.Confirmation ? units.gu(.5) : 0
        }
        backgroundColor: parent.color
        opacity: parent.opacity
        radius: "medium"
        aspect: UbuntuShape.Flat
    }

    Rectangle {
        id: nonShapedBack

        visible: fullscreen
        anchors.fill: parent
        color: parent.color
        opacity: parent.opacity
    }

    onXChanged: {
        if (draggable && notification.x > 0.75 * notification.width) {
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
            drag.minimumX: 0
            drag.maximumX: notification.width

            onClicked: {
                if (notification.type == Notification.Interactive) {
                    notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
                } else if (hasMouse && canBeClosed) {
                    notification.notification.close()
                } else {
                    notificationList.currentIndex = index;
                }
            }
            onReleased: {
                if (notification.x < notification.width / 2) {
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
                margins: 0
                topMargin: fullscreen ? 0 : type === Notification.Confirmation ? units.gu(1) : units.gu(2)
            }

            spacing: type === Notification.Confirmation ? units.gu(1) : units.gu(2)

            Row {
                id: topRow

                spacing: contentSpacing
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: contentSpacing
                }

                ShapedIcon {
                    id: icon

                    objectName: "icon"
                    width: type == Notification.Ephemeral && !bodyLabel.visible ? units.gu(3) : units.gu(6)
                    height: width
                    shaped: notification.hints["x-canonical-non-shaped-icon"] == "true" ? false : true
                    visible: iconSource !== undefined && iconSource !== "" && type !== Notification.Confirmation
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
                        color: darkOnBright ? sdFontColor : theme.palette.normal.backgroundText
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
                        color: darkOnBright ? sdFontColor : theme.palette.normal.backgroundText
                        wrapMode: Text.Wrap
                        maximumLineCount: type == Notification.SnapDecision ? 12 : 2
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
                visible: type == Notification.SnapDecision
            }

            ShapedIcon {
                id: centeredIcon
                objectName: "centeredIcon"
                width: units.gu(5)
                height: width
                shaped: notification.hints["x-canonical-non-shaped-icon"] == "true" ? false : true
                fileSource: icon.fileSource
                visible: fileSource !== undefined && fileSource !== "" && type === Notification.Confirmation
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: valueLabel
                objectName: "valueLabel"
                text: body
                anchors.horizontalCenter: parent.horizontalCenter
                visible: type === Notification.Confirmation && body !== ""
                fontSize: "medium"
                color: darkOnBright ? sdFontColor : theme.palette.normal.backgroundText
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            UbuntuShape {
                id: valueIndicator
                objectName: "valueIndicator"
                visible: type === Notification.Confirmation
                property double value

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: contentSpacing
                }

                height: units.gu(1)
                backgroundColor: darkOnBright ? UbuntuColors.darkGrey : UbuntuColors.lightGrey
                aspect: UbuntuShape.Flat
                radius: "small"

                UbuntuShape {
                    id: innerBar
                    objectName: "innerBar"
                    width: valueIndicator.width * valueIndicator.value / 100
                    height: units.gu(1)
                    backgroundColor: notification.hints["x-canonical-value-bar-tint"] === "true" ? UbuntuColors.orange : darkOnBright ? UbuntuColors.lightGrey : "white"
                    aspect: UbuntuShape.Flat
                    radius: "small"
                }
            }

            Column {
                id: dialogColumn
                objectName: "dialogListView"
                spacing: units.gu(2)

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
                    margins: contentSpacing
                }

                spacing: contentSpacing

                visible: notification.type === Notification.SnapDecision && oneOverTwoRepeaterTop.count === 3

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
                                color: notification.hints["x-canonical-private-affirmative-tint"] == "true" ? green : sdDarkGrey
                                onClicked: notification.notification.invokeAction(oneOverTwoLoaderTop.actionId)
                            }
                        }
                        sourceComponent: index == 0 ? oneOverTwoButtonTop : undefined
                    }
                }

                Row {
                    spacing: contentSpacing

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
                                    width: oneOverTwoCase.width / 2 - spacing * 2
                                    text: oneOverTwoLoaderBottom.actionLabel
                                    color: index == 1 && notification.hints["x-canonical-private-rejection-tint"] == "true" ? red : sdDarkGrey
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
                    margins: contentSpacing
                }
                visible: notification.type === Notification.SnapDecision && actionRepeater.count > 0 && !oneOverTwoCase.visible
                spacing: contentSpacing
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
                                    var result = sdDarkGrey;
                                    if (index == 0 && notification.hints["x-canonical-private-affirmative-tint"] == "true") {
                                        result = green;
                                    }
                                    if (index == 1 && notification.hints["x-canonical-private-rejection-tint"] == "true") {
                                        result = red;
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
                    margins: contentSpacing
                }

                visible: notification.type == Notification.SnapDecision && actionRepeater.count > 3 && !oneOverTwoCase.visible
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
