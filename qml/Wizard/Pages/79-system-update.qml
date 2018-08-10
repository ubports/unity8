/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.SystemImage 0.1
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    id: systemUpdatePage
    objectName: "systemUpdatePage"

    title: i18n.tr("Update Device")
    forwardButtonSourceComponent: forwardButton

    skip: !SystemImage.updateDownloaded // skip the page when the system update is not ready to install

    Column {
        id: column
        anchors {
            fill: content
            leftMargin: systemUpdatePage.leftMargin
            rightMargin: systemUpdatePage.rightMargin
            topMargin: systemUpdatePage.customMargin
        }
        spacing: units.gu(3)
        opacity: spinner.running ? 0.5 : 1
        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            font.weight: Font.Light
            color: textColor
            wrapMode: Text.Wrap
            fontSize: "small"
            text: i18n.tr("There is a system update available and ready to install. Afterwards, the device will automatically restart.")
        }

        GridLayout {
            rows: 3
            columns: 2
            rowSpacing: units.gu(1)
            columnSpacing: units.gu(2)

            Image {
                Layout.rowSpan: 3
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                sourceSize: Qt.size(units.gu(3), units.gu(3))
                fillMode: Image.PreserveAspectFit
                source: "image://theme/distributor-logo"
            }

            Label {
                color: textColor
                font.weight: Font.Normal
                fontSize: "small"
                text: i18n.ctr("string identifying name of the update", "Ubuntu system")
            }

            Label {
                font.weight: Font.Light
                fontSize: "small"
                color: textColor
                text: i18n.ctr("version of the system update", "Version %1").arg(SystemImage.availableVersion)
            }

            Label {
                font.weight: Font.Light
                fontSize: "small"
                color: textColor
                text: SystemImage.updateSize
            }
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            font.weight: Font.Light
            color: textColor
            wrapMode: Text.Wrap
            fontSize: "small"
            text: i18n.tr("This could take a few minutes...")
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            color: theme.palette.normal.foreground
            radius: units.dp(4)
            width: buttonLabel.paintedWidth + units.gu(3)
            height: buttonLabel.paintedHeight + units.gu(1.8)

            Label {
                id: buttonLabel
                color: textColor
                text: i18n.tr("Install and restart now")
                font.weight: Font.Light
                anchors.centerIn: parent
            }

            AbstractButton {
                id: button
                objectName: "installButton"
                anchors.fill: parent
                onClicked: {
                    System.skipUntilFinishedPage();
                    SystemImage.applyUpdate();
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

    ActivityIndicator {
        id: spinner
        anchors.centerIn: systemUpdatePage
        running: SystemImage.updateApplying
        visible: running
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
