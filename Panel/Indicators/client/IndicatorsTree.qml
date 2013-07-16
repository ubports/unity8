/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dededkind@canonical.com
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators
import QMenuModel 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page
    anchors.fill: parent

    property alias busType: menuModel.busType
    property alias busName: menuModel.busName
    property string actionsObjectPath
    property var menuObjectPaths: undefined
    readonly property string device: "phone"

    property string deviceMenuObjectPath: menuObjectPaths.hasOwnProperty(device) ? menuObjectPaths[device] : ""

    function start() {
        menuModel.start();
    }

    QDBusMenuModel {
        id: menuModel
        objectPath: page.deviceMenuObjectPath
    }

    Indicators.ModelPrinter {
        id: printer
        model: menuModel

        onSourceChanged: page.refresh()
    }

    function refresh() {
        all_data.text = printer.getString();
    }

    Flickable {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: button.top
        }
        contentHeight: all_data.height
        clip:true
        Text {
            id: all_data
            color: "white"
        }
    }

    ListItem.Standard {
        id: button
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        text: ""
        control: Button {
            text: "Refresh"
            onClicked: page.refresh()
        }
    }
}
