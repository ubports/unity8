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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import QMenuModel 0.1 as QMenuModel
import Unity.Indicators 0.1 as Indicators

Item {
    id: indicatorItem

    // FIXME : should be disabled until bus available when we have desktop indicators
    // for now, disable when we dont habe the correct profile.
    enabled: menuObjectPaths.hasOwnProperty(device)

    //const
    property string title
    property string busName
    property string actionsObjectPath
    property var menuObjectPaths: undefined
    readonly property string device: "phone"
    property string rootMenuType: "com.canonical.indicator.root"
    property bool active: false

    property string deviceMenuObjectPath: menuObjectPaths.hasOwnProperty(device) ? menuObjectPaths[device] : ""

    property alias menuModel: cachedModel.model

    CachedUnityMenuModel {
        id: cachedModel
        busName: active ? indicatorItem.busName : ""
        actionsObjectPath: active ? indicatorItem.actionsObjectPath : ""
        menuObjectPath: active ? indicatorItem.deviceMenuObjectPath : ""
    }
}
