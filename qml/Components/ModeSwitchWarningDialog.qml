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
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3

ShellDialog {
    id: root
    objectName: "modeSwitchWarningDialog"

    property alias model: appRepeater.model

    signal forceClose();

    Label {
        text: i18n.tr("Apps may have unsaved data:")
        fontSize: "large"
        color: "#5D5D5D"
    }

    Repeater {
        id: appRepeater
        RowLayout {
            spacing: units.gu(2)
            Image {
                Layout.preferredHeight: units.gu(2)
                Layout.preferredWidth: units.gu(2)
                source: model.icon
                sourceSize.width: width
                sourceSize.height: height
            }
            Label {
                Layout.fillWidth: true
                text: model.name
                color: "#888888"
            }
        }
    }

    Label {
        text: i18n.tr("Re-dock, save your work and close these apps to continue.")
        wrapMode: Text.WordWrap
        color: "#888888"
    }

    Label {
        text: i18n.tr("Or force close now (unsaved data will be lost).")
        wrapMode: Text.WordWrap
        color: "#888888"
    }

    ThinDivider {}

    RowLayout {
        Label {
            objectName: "reconnectLabel"
            Layout.fillWidth: true
            property bool clicked: false
            property string notClickedText: i18n.tr("OK, I will reconnect")
            property string clickedText: i18n.tr("Reconnect now!")
            text: clicked ? clickedText : notClickedText
            color: "#333333"

            MouseArea {
                anchors.fill: parent
                onClicked: parent.clicked = true;
            }
        }

        Button {
            objectName: "forceCloseButton"
            text: i18n.tr("Close all")
            color: UbuntuColors.red
            onClicked: {
                root.forceClose();
            }
        }
    }
}
