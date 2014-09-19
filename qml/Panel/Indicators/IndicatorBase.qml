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
import Unity.Indicators 0.1

Item {
    id: indicatorItem

    enabled: menuObjectPath != ""

    //const
    property string busName
    property string actionsObjectPath
    property string menuObjectPath
    property string rootMenuType: "com.canonical.indicator.root"

    property string deviceMenuObjectPath: menuObjectPath

    property alias menuModel: cachedModel.model
    property alias rootActionState: rootAction

    CachedUnityMenuModel {
        id: cachedModel
        busName: indicatorItem.busName
        actionsObjectPath: indicatorItem.actionsObjectPath
        menuObjectPath: indicatorItem.deviceMenuObjectPath
    }

    RootActionState {
        id: rootAction
        menu: menuModel ? menuModel : null
        onUpdated: {
            indicatorItem.rootActionStateChanged()
        }
    }
}
