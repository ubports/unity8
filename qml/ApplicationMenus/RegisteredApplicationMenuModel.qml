/*
 * Copyright 2016 Canonical Ltd.
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
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Indicators 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators

Object {
    property string persistentSurfaceId
    readonly property alias model: sharedAppModel.model

    Indicators.SharedUnityMenuModel {
        id: sharedAppModel
        property var menus: ApplicationMenuRegistry.getMenusForSurface(persistentSurfaceId)
        property var menuService: menus.length > 0 ? menus[0] : null

        busName: menuService ? menuService.service : ""
        menuObjectPath: menuService && menuService.menuPath ? menuService.menuPath : ""
        actions: menuService && menuService.actionPath ? { "unity": menuService.actionPath } : {}
    }

    onPersistentSurfaceIdChanged: update()

    function update() {
        sharedAppModel.menus = Qt.binding(function() { return ApplicationMenuRegistry.getMenusForSurface(persistentSurfaceId); });
    }

    Connections {
        target: ApplicationMenuRegistry
        onSurfaceMenuRegistered: {
            if (surfaceId === persistentSurfaceId) {
                update();
            }
        }
        onSurfaceMenuUnregistered: {
            if (surfaceId === persistentSurfaceId) {
                update();
            }
        }
    }
}
