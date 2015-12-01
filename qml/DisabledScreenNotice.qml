/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "Components"

Image {
    id: root

    property bool infoNoteDisplayed: true

    WallpaperResolver {
        width: root.width
        id: wallpaperResolver
    }

    source: wallpaperResolver.background


    VirtualTouchPad {
        anchors.fill: parent
    }

    MouseArea {
        objectName: "infoNoticeMouseArea"
        anchors.fill: parent
        opacity: infoNoteDisplayed ? 1 : 0
        visible: opacity > 0
        enabled: visible
        Behavior on opacity {
            UbuntuNumberAnimation { }
        }

        onClicked: root.infoNoteDisplayed = false;

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.4
        }

        Label {
            id: text
            anchors.centerIn: parent
            width: parent.width - units.gu(8)
            text: i18n.tr("Your device is now connected to an external display. Use this screen as a touch pad to interact with the mouse.")
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSize: "x-large"
            wrapMode: Text.Wrap
        }
    }

    InputMethod {
        id: inputMethod
        objectName: "inputMethod"
        anchors.fill: parent
    }
}
