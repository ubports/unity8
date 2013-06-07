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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import QMenuModel 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import IndicatorsClient 0.1 as IndicatorsClient

Item {
    id: indicatorItem

    //const
    property string title
    property string device: "desktop"
    property int busType
    property string busName
    property string actionsObjectPath
    property var menuObjectPaths : undefined

    property string deviceMenuObjectPath : menuObjectPaths.hasOwnProperty(device) ? menuObjectPaths[device] : ""

    onDeviceMenuObjectPathChanged: console.log("\n\n" + deviceMenuObjectPath + "\n\n");

    signal actionGroupUpdated()
    signal modelUpdated()

    property var actionGroup : QDBusActionGroup {
        busType: indicatorItem.busType
        busName: indicatorItem.busName
        objectPath: indicatorItem.actionsObjectPath

        onActionAppear: indicatorItem.actionGroupUpdated();
    }

    property var proxyModel : IndicatorsClient.FlatMenuProxyModel {
        busType: indicatorItem.busType
        busName: indicatorItem.busName
        objectPath: indicatorItem.deviceMenuObjectPath

        onStatusChanged: indicatorItem.modelUpdated();
        onRowsInserted: indicatorItem.modelUpdated();
        onRowsRemoved: indicatorItem.modelUpdated();
        onDataChanged: indicatorItem.modelUpdated();
    }
}
