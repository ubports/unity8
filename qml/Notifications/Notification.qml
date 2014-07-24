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

    objectName: "background"
    implicitHeight: type !== Notification.PlaceHolder ? (fullscreen ? maxHeight : contentColumn.height + contentColumn.spacing * 2) : 0

    color: type == Notification.SnapDecision ? "#eaeaea" : Qt.rgba(0.132, 0.117, 0.109, 0.97)
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
            PropertyChanges {target: notification; height: units.gu(8)}
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
            id: contentColumn
            objectName: "contentColumn"

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: fullscreen ? 0 : spacing
            }

            spacing: units.gu(1)

            Row {
                id: topRow

                spacing: contentColumn.spacing
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ShapedIcon {
                    id: icon

                    objectName: "icon"
                    width: units.gu(6)
                    height: units.gu(6)
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
                        font.bold: true
                        color: type == Notification.SnapDecision ? "#5d5d5d" :Theme.palette.selected.backgroundText
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
                        color: type == Notification.SnapDecision ? "#5d5d5d" : Theme.palette.selected.backgroundText
                        opacity: type == Notification.SnapDecision ? 1.0 : 0.6
                        wrapMode: Text.WordWrap
                        maximumLineCount: 10
                        elide: Text.ElideRight
                    }
                }

                /*Rectangle {
                    width: units.gu(3)
                    height: units.gu(3)
                    color: "#ff0000"
                }*/
                Image {
                    id: secondaryIcon

                    objectName: "secondaryIcon"
                    width: units.gu(3)
                    height: units.gu(3)
                    visible: source !== undefined && source != ""
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

            Row {
                id: buttonRow

                objectName: "buttonRow"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                visible: notification.type == Notification.SnapDecision && actionRepeater.count > 0
                spacing: units.gu(1)
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
                                objectName: "button" + index
                                width: buttonRow.width / 2 - spacing
                                text: loader.actionLabel
                                color: {
                                    if (index == 0 && notification.hints["x-canonical-private-affirmative-tint"] == "true") {
                                        return green;
                                    }
                                    if (index == 1 && notification.hints["x-canonical-private-rejection-tint"] == "true") {
                                        return red;
                                    }
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

                objectName: "button2"
                width: parent.width
                visible: notification.type == Notification.SnapDecision && actionRepeater.count > 3
                color: "#dddddd"
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
                                comboButton.text = comboRepeater.itemAt(2).actionLabel
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

                                        objectName: "button" + index
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
                                            color: "#5d5d5d"
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
                                            color: "#5d5d5d"
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
