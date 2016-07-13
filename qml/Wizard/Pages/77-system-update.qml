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
import ".." as LocalComponents

LocalComponents.Page {
    id: reportingPage
    objectName: "systemUpdatePage"

    title: i18n.tr("Update Device")
    forwardButtonSourceComponent: forwardButton

    skip: !SystemImage.updateDownloaded // skip the page when the system update is not ready to install

    Column {
        id: column
        anchors {
            fill: content
            leftMargin: leftMargin
            rightMargin: rightMargin
            topMargin: customMargin
        }
        spacing: units.gu(3)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            font.weight: Font.Light
            color: textColor
            wrapMode: Text.Wrap
            text: i18n.tr("There is a system update available and ready to install. Afterwards, the device will automatically restart.")
        }

        GridLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            rows: 3
            columns: 2
            rowSpacing: units.gu(1)
            columnSpacing: units.gu(2)

            UbuntuShape {
                Layout.rowSpan: 3
                aspect: UbuntuShape.Flat
                backgroundColor: theme.palette.normal.base
                width: units.gu(8)
                height: width
                sourceScale: Qt.vector2d(0.5,0.5)
                source: Image {
                    source: Qt.resolvedUrl("/usr/share/icons/suru/apps/scalable/ubuntu-logo-symbolic.svg")
                }
            }

            Label {
                Layout.fillWidth: true
                color: textColor
                font.weight: Font.Normal
                text: i18n.tr("Ubuntu system")
            }

            Label {
                font.weight: Font.Light
                color: textColor
                text: i18n.tr("Version %1").arg(SystemImage.availableVersion)
            }

            Label {
                font.weight: Font.Light
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

        Button {
            anchors.left: parent.left
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            text: i18n.tr("Install and restart now")
            onClicked: {
                // TODO mark the wizard to skip until the finished page for the next boot
                SystemImage.applyUpdate();
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
