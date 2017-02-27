/*
* Copyright (C) 2017 Canonical, Ltd.
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

import "../../qml/ApplicationMenus"
import "../../qml/Panel"
import "../../qml/Components/PanelState"

import QMenuModel 0.1
import Unity.Indicators 0.1 as Indicators

Item {
    width: units.gu(180)
    height: units.gu(120)

    UnityMenuModel {
        id: menuModel
        busName: contextBusName
        menuObjectPath: "/com/ubuntu/Menu/0"
        actions: { "unity": "/com/ubuntu/Menu/0" }
    }

    Panel {
        id: panel

        height: parent.height
        width: parent.width / 2
        minimizedPanelHeight: units.gu(6)

        mode: "windowed"

        applicationMenus {
            model: menuModel
        }

        Rectangle {
            color: "green"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            Label {
                id: label
                anchors.centerIn: parent
                text: "Click here to open touch menu manually"
            }
            width: label.width + units.gu(2)
            height: label.height + units.gu(2)
            MouseArea {
                anchors.fill: parent
                onClicked: panel.applicationMenus.show();
            }
            visible: !panel.applicationMenus.shown
        }
    }

    Rectangle {
        color: "blue"
        height: parent.height
        width: parent.width / 2
        x: width

        MenuBar {
            id: menuBar
            height: units.gu(3)
            width: parent.width
            enableKeyFilter: true
            unityMenuModel: menuModel
        }
    }

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruDark";
        PanelState.title = "Drag here to open touch menu";
    }
}
