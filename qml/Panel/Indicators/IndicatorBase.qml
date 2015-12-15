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

import QtQuick 2.4
import Unity.Indicators 0.1

Item {
    id: indicatorItem

    //const
    property string identifier
    property string busName
    property string actionsObjectPath
    property string menuObjectPath
    property string rootMenuType: "com.canonical.indicator.root"

    property alias menuModel: cachedModel.model
    property alias rootActionState: rootAction

    SharedUnityMenuModel {
        id: cachedModel
        busName: indicatorItem.busName
        actions: { "indicator": indicatorItem.actionsObjectPath }
        menuObjectPath: indicatorItem.menuObjectPath
    }

    ModelActionRootState {
        id: rootAction
        menu: menuModel ? menuModel : null
    }
}
