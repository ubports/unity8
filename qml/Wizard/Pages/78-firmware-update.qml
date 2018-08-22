/*
 * Copyright (C) 2018 The UBports project
 *
 * Written by: Marius Gripsgard <marius@ubports.com>
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.Update 1.0
import Ubuntu.Connectivity 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    id: firmwareUpdatePage
    objectName: "firmwareUpdatePage"

    title: i18n.tr("Firmware Update")
    forwardButtonSourceComponent: forwardButton

    skip: !SystemImage.supportsFirmwareUpdate()

    property bool online: NetworkingStatus.online
    property bool hasUpdate: false
    property bool isUpdating: false
    property bool isChecking: true
    property var partitions: ""

    function check() {
        if (!SystemImage.supportsFirmwareUpdate()) {
            return;
        }
        firmwareUpdatePage.isChecking = true;
        SystemImage.checkForFirmwareUpdate();
    }

    function flash() {
        if (!SystemImage.supportsFirmwareUpdate()) {
            return pageStack.next();
        }
        firmwareUpdatePage.isUpdating = true;
        SystemImage.updateFirmware();
    }

    Connections {
        target: SystemImage
        onCheckForFirmwareUpdateDone: {
            var updateobj = JSON.parse(updateObj);
            if (Array.isArray(updateobj) && updateobj.length > 0) {
              for (var u in updateobj) {
                console.log(u);
                if (firmwareUpdatePage.partitions === "") {
                    firmwareUpdatePage.partitions += updateobj[u].file;
                } else {
                    firmwareUpdatePage.partitions += ", " + updateobj[u].file;
                }
              }
              firmwareUpdatePage.hasUpdate = true;
            }
            console.log(updateobj);
            firmwareUpdatePage.isChecking = false;
        }
        onUpdateFirmwareDone: {
            var updateobj = JSON.parse(updateObj);
            if (Array.isArray(updateobj) && updateobj.length === 0) {
              // This means success!
              firmwareUpdatePage.hasUpdate = false;
              firmwareUpdatePage.partitions = "";
              System.skipUntilFinishedPage();
              SystemImage.reboot();
              return;
            }
            console.log(updateobj);
            firmwareUpdatePage.isUpdating = false;
        }
    }

    Column {
        id: column
        anchors {
            fill: content
            leftMargin: firmwareUpdatePage.leftMargin
            rightMargin: firmwareUpdatePage.rightMargin
            topMargin: firmwareUpdatePage.customMargin
        }
        spacing: units.gu(3)
        opacity: spinner.visible ? 0.5 : 1
        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        Label {
            visible: !firmwareUpdatePage.isChecking
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.Light
            wrapMode: Text.Wrap
            textSize: Label.Medium
            text: firmwareUpdatePage.hasUpdate ? i18n.tr("There is a firmware update available!")
                                             : online ? i18n.tr("Firmware is up to date!")
                                             : i18n.tr("Please connect to the Internet to check for updates.")

        }

        GridLayout {
            rows: 3
            columns: 2
            rowSpacing: units.gu(1)
            columnSpacing: units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter
            visible: hasUpdate

            Icon {
                Layout.rowSpan: 3
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                width: units.gu(5)
                height: width
                name: "security-alert"
            }

            Label {
                font.weight: Font.Normal
                textSize: Label.Medium
                text: i18n.tr("Firmware Update")
            }

            Label {
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                fontSize: "small"
                text: firmwareUpdatePage.partitions
            }

            Label {
                font.weight: Font.Light
                fontSize: "small"
                text: i18n.tr("The device will automatically restart after installing is done.")
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            color: theme.palette.normal.foreground
            radius: units.dp(4)
            width: buttonLabel.paintedWidth + units.gu(3)
            height: buttonLabel.paintedHeight + units.gu(1.8)
            visible: hasUpdate

            Label {
                id: buttonLabel
                text: i18n.tr("Install and restart now")
                font.weight: Font.Light
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.centerIn: parent
            }

            AbstractButton {
                id: button
                objectName: "installButton"
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    firmwareUpdatePage.flash()
                }
            }

            transformOrigin: Item.Top
            scale: button.pressed ? 0.98 : 1.0
            Behavior on scale {
                ScaleAnimator {
                    duration: UbuntuAnimation.SnapDuration
                    easing.type: Easing.Linear
                }
            }
        }
    }

    Column {
      id: spinner
      anchors.centerIn: firmwareUpdatePage
      visible: firmwareUpdatePage.isChecking || firmwareUpdatePage.isUpdating
      spacing: units.gu(1)

        ActivityIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: parent.visible
        }

        Label {
            wrapMode: Text.Wrap
            width: firmwareUpdatePage.width - units.gu(3)
            fontSize: "small"
            text: i18n.tr("Downloading and Flashing firmware updates, this could take a few minutes...")
            visible: firmwareUpdatePage.isUpdating
        }

        Label {
            wrapMode: Text.Wrap
            fontSize: "small"
            text: i18n.tr("Checking for firmware update")
            visible: firmwareUpdatePage.isChecking
        }

        Component.onCompleted: {
        if (online) {
            firmwareUpdatePage.check();
        }
        else {
            firmwareUpdatePage.isChecking = false;
        }
        }
    }

    Connections {
        target: NetworkingStatus
        onOnlineChanged: {
            if (online) {
                firmwareUpdatePage.check();
            } else {
                firmwareUpdatePage.isChecking = false;
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: !firmwareUpdatePage.hasUpdate && !firmwareUpdatePage.spinner.visible
                  ? i18n.tr("Next") : i18n.tr("Skip");
            onClicked: pageStack.next();
        }
    }
}
