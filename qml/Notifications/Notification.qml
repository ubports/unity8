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
import QtMultimedia 5.0
import Ubuntu.Components 1.1
import Unity.Notifications 1.0
import QMenuModel 0.1
import Utils 0.1

import Ubuntu.Components.ListItems 0.1 as ListItem

Item {
    id: notification

    property alias iconSource: icon.fileSource
    property alias secondaryIconSource: secondaryIcon.source
    property alias summary: summaryLabel.text
    property alias body: bodyLabel.text
    property var actions
    property var notificationId
    property var type
    property var hints
    property var notification
    property color color
    property bool fullscreen: false
    property int maxHeight
    property int margins
    readonly property color red: "#fc4949"
    readonly property color green: "#3fb24f"
    readonly property color sdLightGrey: "#eaeaea"
    readonly property color sdDarkGrey: "#dddddd"
    readonly property color sdFontColor: "#5d5d5d"
    readonly property real contentSpacing: units.gu(2)

    objectName: "background"
    implicitHeight: type !== Notification.PlaceHolder ? (fullscreen ? maxHeight : outterColumn.height + contentSpacing * 2) : 0

    color: type == Notification.SnapDecision ? sdLightGrey : Qt.rgba(0.132, 0.117, 0.109, 0.97)
    opacity: 0

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

    Audio {
        id: sound
        objectName: "sound"
        source: hints["suppress-sound"] != "true" && hints["sound-file"] != undefined ? hints["sound-file"] : ""
    }

    onOpacityChanged: {
        if (opacity == 1.0 && hints["suppress-sound"] != "true" && sound.source) {
            sound.play();
        }
    }

    Behavior on height {
        id: normalHeightBehavior

        //enabled: menuItemFactory.progress == 1
        enabled: true
        SequentialAnimation {
            PauseAnimation {
                duration: UbuntuAnimation.SnapDuration
            }
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SnapDuration
            }
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
        }
        color: parent.color
        opacity: parent.opacity
        radius: "medium"
    }

    Rectangle {
        id: nonShapedBack

        visible: fullscreen
        anchors.fill: parent
        color: parent.color
        opacity: parent.opacity
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
                if (lastNameOwner != "" && nameOwner == "" && notification.notification != undefined) {
                    notification.notification.close()
                }
                lastNameOwner = nameOwner
            }
        }

        Behavior on implicitHeight {
            id: heightBehavior

            enabled: false
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SnapDuration
            }
        }

        // delay enabling height behavior until the add transition is complete
        onOpacityChanged: if (opacity == 1) heightBehavior.enabled = true

        MouseArea {
            id: interactiveArea

            anchors.fill: parent
            objectName: "interactiveArea"
            onClicked: {
                if (notification.type == Notification.Interactive) {
                    notification.notification.invokeAction(actionRepeater.itemAt(0).actionId)
                } else {
                    notificationList.currentIndex = index;
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
                topMargin: units.gu(2)
            }

            spacing: units.gu(2)

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
                    visible: iconSource !== undefined && iconSource != ""
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
                        fontSize: "medium"
                        color: type == Notification.SnapDecision ? sdFontColor : Theme.palette.selected.backgroundText
                        elide: Text.ElideRight
                    }

                    Label {
                        id: bodyLabel

                        objectName: "bodyLabel"
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        visible: body != ""
                        fontSize: "small"
                        color: type == Notification.SnapDecision ? sdFontColor : Theme.palette.selected.backgroundText
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
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

                        onLoaded: {
                            notification.fullscreen = Qt.binding(function() { return fullscreen; });
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

                visible: notification.type == Notification.SnapDecision && oneOverTwoRepeaterTop.count == 3

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
                            sourceComponent:  (index == 1 || index == 2) ? oneOverTwoButtonBottom : undefined
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
                visible: notification.type == Notification.SnapDecision && actionRepeater.count > 0 && !oneOverTwoCase.visible
                spacing: units.gu(2)
                layoutDirection: Qt.RightToLeft

                Repeater {
                    id: actionRepeater

                    model: notification.actions
                    delegate: Loader {
                        id: loader

                        property string actionId: id
                        property string actionLabel: label

                        Component {
                            id: actionButton

                            Button {
                                objectName: "notify_button" + index
                                width: buttonRow.width / 2 - spacing*2
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

            ComboButton {
                id: comboButton

                objectName: "notify_button2"
                width: parent.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: contentSpacing
                }

                visible: notification.type == Notification.SnapDecision && actionRepeater.count > 3 && !oneOverTwoCase.visible
                color: sdDarkGrey
                onClicked: notification.notification.invokeAction(comboRepeater.itemAt(2).actionId)
                expanded: false
                expandedHeight: (comboRepeater.count - 2) * units.gu(4) + units.gu(.5)
                comboList: Flickable {
                    // this has to be wrapped inside a flickable
                    // to work around a feature/bug? of the
                    // ComboButton SDK-element, making a regular
                    // unwrapped Column item flickable
                    // see LP: #1332590
                    interactive: false
                    Column {
                        Repeater {
                            id: comboRepeater

                            onVisibleChanged: {
                                comboButton.text = comboRepeater.count >= 3 ? comboRepeater.itemAt(2).actionLabel : ""
                            }

                            model: notification.actions
                            delegate: Loader {
                                id: comboLoader

                                asynchronous: true
                                visible: status == Loader.Ready
                                property string actionId: id
                                property string actionLabel: label
                                readonly property var splitLabel: actionLabel.match(/(^([-a-z0-9]+):)?(.*)$/)
                                Component {
                                    id: comboEntry

                                    MouseArea {
                                        id: comboInputArea

                                        objectName: "notify_button" + index
                                        width: comboButton.width
                                        height: comboIcon.height + units.gu(2)

                                        onClicked: {
                                            notification.notification.invokeAction(actionId)
                                        }

                                        ListItem.ThinDivider {
                                            visible: index > 3
                                        }

                                        Icon {
                                            id: comboIcon

                                            anchors {
                                                left: parent.left
                                                leftMargin: units.gu(.5)
                                                verticalCenter: parent.verticalCenter
                                            }
                                            width: units.gu(2)
                                            height: units.gu(2)
                                            color: sdFontColor
                                            name: splitLabel[2]
                                        }

                                        Label {
                                            id: comboLabel

                                            anchors {
                                                left: comboIcon.right
                                                leftMargin: units.gu(1)
                                                verticalCenter: comboIcon.verticalCenter
                                            }
                                            fontSize: "small"
                                            color: sdFontColor
                                            text: splitLabel[3]
                                        }
                                    }
                                }
                                sourceComponent: (index > 2) ? comboEntry : undefined
                            }
                        }
                    }
                }
            }
        }
    }
}
