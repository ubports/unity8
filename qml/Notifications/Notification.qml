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
    property color color: theme.palette.normal.background
    property bool fullscreen: notification.notification && typeof notification.notification.fullscreen != "undefined" ?
                                  notification.notification.fullscreen : false // fullscreen prop only exists in the mock
    property int maxHeight
    property int margins: units.gu(1)

    readonly property real defaultOpacity: 1.0
    property bool hasMouse
    property url background: ""

    objectName: "background"
    implicitHeight: type !== Notification.PlaceHolder ? (fullscreen ? maxHeight : outterColumn.height + shapedBack.anchors.topMargin + margins * 2) : 0

    // FIXME: non-zero initially because of LP: #1354406 workaround, we want this to start at 0 upon creation eventually
    opacity: defaultOpacity - Math.abs(x / notification.width)

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    readonly property bool expanded: type === Notification.SnapDecision &&                   // expand only snap decisions, if...
                                     (fullscreen ||                                          // - it's a fullscreen one
                                      ListView.view.currentIndex === index ||                // - it's the one the user clicked on
                                      (ListView.view.currentIndex === -1 && index == 0)      // - the first one after the user closed the previous one
                                      )

    NotificationAudio {
        id: sound
        objectName: "sound"
        source: hints["suppress-sound"] !== "true" && hints["sound-file"] !== undefined ? hints["sound-file"] : ""
    }

    Component.onCompleted: {
        if (type === Notification.PlaceHolder) {
            return;
        }

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

    Component.onDestruction: {
        if (type === Notification.PlaceHolder) {
            return;
        }

        if (type === Notification.SnapDecision) {
            Powerd.setStatus(Powerd.Off, Powerd.SnapDecision);
        } else if (type !== Notification.Confirmation) {
            Powerd.setStatus(Powerd.Off, Powerd.Notification);
        }
    }

    function closeNotification() {
        if (index === ListView.view.currentIndex) { // reset to get the 1st snap decision expanded
            ListView.view.currentIndex = -1;
        }

        // perform the "reject" action
        notification.notification.invokeAction(notification.actions.data(1, ActionModel.RoleActionId));

        notification.notification.close();
    }

    Behavior on x {
        UbuntuNumberAnimation { easing.type: Easing.OutBounce }
    }

    onHintsChanged: {
        if (type === Notification.Confirmation && opacity == defaultOpacity && hints["suppress-sound"] !== "true" && sound.source !== "") {
            sound.play();
        }
    }

    onFullscreenChanged: {
        if (fullscreen) {
            notification.notification.urgency = Notification.Critical;
        }
        if (index == 0) {
            ListView.view.topmostIsFullscreen = fullscreen;
        }
    }

    Behavior on implicitHeight {
        enabled: !fullscreen
        UbuntuNumberAnimation {
            duration: UbuntuAnimation.SnapDuration
        }
    }

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
        objectName: "shapedBack"

        visible: !fullscreen
        anchors {
            fill: parent
            leftMargin: notification.margins
            rightMargin: notification.margins
            topMargin: index == 0 ? notification.margins : 0
        }
        backgroundColor: parent.color
        radius: "small"
        aspect: UbuntuShape.Flat
    }

    Rectangle {
        id: nonShapedBack

        visible: fullscreen
        anchors.fill: parent
        color: parent.color
    }

    onXChanged: {
        if (Math.abs(notification.x) > 0.75 * notification.width) {
            closeNotification();
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

            drag.target: !fullscreen ? notification : undefined
            drag.axis: Drag.XAxis
            drag.minimumX: -notification.width
            drag.maximumX: notification.width
            hoverEnabled: true

            onClicked: {
                if (notification.type === Notification.Interactive) {
                    notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
                } else {
                    notification.ListView.view.currentIndex = index;
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

        NotificationButton {
            objectName: "closeButton"
            width: units.gu(2)
            height: width
            radius: width / 2
            visible: hasMouse && (containsMouse || interactiveArea.containsMouse)
            iconName: "close"
            outline: false
            hoverEnabled: true
            color: theme.palette.normal.negative
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: notification.parent.state === "narrow" ? notification.margins / 2 : 0
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: notification.parent.state === "narrow" ? notification.margins / 2 : 0

            onClicked: closeNotification();
        }

        Column {
            id: outterColumn
            objectName: "outterColumn"

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: !fullscreen ? notification.margins : 0
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
                    width: secondaryIcon.visible ? parent.width - x - units.gu(3) : parent.width - x
                    anchors.verticalCenter: (icon.visible && !bodyLabel.visible) ? icon.verticalCenter : undefined
                    spacing: units.gu(.4)

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
                        lineHeight: 1.1
                    }
                }

                Image {
                    id: secondaryIcon

                    objectName: "secondaryIcon"
                    width: units.gu(2)
                    height: width
                    visible: status === Image.Ready
                    fillMode: Image.PreserveAspectCrop
                }
            }

            ListItem.ThinDivider {
                visible: type === Notification.SnapDecision && notification.expanded
            }

            Icon {
                name: "toolkit_chevron-down_3gu"
                visible: type === Notification.SnapDecision && !notification.expanded
                width: units.gu(2)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                color: theme.palette.normal.base
            }

            ShapedIcon {
                id: centeredIcon
                objectName: "centeredIcon"
                width: units.gu(4)
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
                showProgressPercentage: false
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(1)
            }

            Column {
                id: dialogColumn
                objectName: "dialogListView"
                spacing: notification.margins

                visible: count > 0 && (notification.expanded || notification.fullscreen)

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

                visible: notification.type === Notification.SnapDecision && oneOverTwoRepeaterTop.count === 3 && notification.expanded

                Repeater {
                    id: oneOverTwoRepeaterTop

                    model: notification.actions
                    delegate: Loader {
                        id: oneOverTwoLoaderTop

                        property string actionId: id
                        property string actionLabel: label

                        Component {
                            id: oneOverTwoButtonTop

                            NotificationButton {
                                objectName: "notify_oot_button" + index
                                width: oneOverTwoCase.width
                                text: oneOverTwoLoaderTop.actionLabel
                                outline: notification.hints["x-canonical-private-affirmative-tint"] !== "true"
                                color: notification.hints["x-canonical-private-affirmative-tint"] === "true" ? theme.palette.normal.positive
                                                                                                             : theme.palette.normal.foreground
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

                                NotificationButton {
                                    objectName: "notify_oot_button" + index
                                    width: oneOverTwoCase.width / 2 - spacing / 2
                                    text: oneOverTwoLoaderBottom.actionLabel
                                    outline: notification.hints["x-canonical-private-rejection-tint"] !== "true"
                                    color: index == 1 && notification.hints["x-canonical-private-rejection-tint"] === "true" ? theme.palette.normal.negative
                                                                                                                             : theme.palette.normal.foreground
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
                visible: notification.type === Notification.SnapDecision && actionRepeater.count > 0 && !oneOverTwoCase.visible && notification.expanded
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

                            NotificationButton {
                                objectName: "notify_button" + index
                                width: buttonRow.width / 2 - spacing / 2
                                text: loader.actionLabel
                                outline: (index == 0 && notification.hints["x-canonical-private-affirmative-tint"] !== "true") ||
                                         (index == 1 && notification.hints["x-canonical-private-rejection-tint"] !== "true")
                                color: {
                                    var result = theme.palette.normal.foreground;
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

                visible: notification.type === Notification.SnapDecision && actionRepeater.count > 3 && !oneOverTwoCase.visible && notification.expanded
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
