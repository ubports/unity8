/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Row {
    id: root

    property alias backVisible: backImageItem.visible
    property alias foregroundColor: backImage.color
    property alias textEnabled: textItem.enabled
    property alias text: textLabel.text

    readonly property alias backButtonWidth: backImageItem.width

    signal backClicked()
    signal textClicked()

    ListItem.Standard {
        id: backImageItem
        objectName: "backButton"
        height: parent.height
        width: height
        showDivider: false

        Icon {
            id: backImage
            anchors.centerIn: parent
            name: "back"
            height: units.gu(2)
            width: height
        }

        onClicked: root.backClicked();
    }

    ListItem.Standard {
        id: textItem
        height: parent.height
        showDivider: false

        Label {
            id: textLabel
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
                leftMargin: backImageItem.visible ? 0 : units.gu(2)
                rightMargin: units.gu(2)
            }
            font.bold: true
            color: root.foregroundColor
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideMiddle
        }

        onClicked: root.textClicked();
    }
}
