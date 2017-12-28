/*
 * Copyright 2017 Canonical Ltd.
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
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators

Object {

    property alias surfaceManager: sMgrHandler.target

    Connections {
        id: sMgrHandler
        target: null
        onSurfaceCreated: {
            var fakeMenuPath = "/" + surface.persistentId.replace(/\W+/g, "");

            ApplicationMenuRegistry.RegisterSurfaceMenu(surface.persistentId, fakeMenuPath, fakeMenuPath, ":1");
            Indicators.UnityMenuModelCache.setCachedModelData(fakeMenuPath, generateTestData(4, 3, 2, 3, "menu"));
        }
        onSurfaceDestroyed: {
            ApplicationMenuRegistry.UnregisterSurfaceMenu(persistentSurfaceId, "/app");
        }
    }

    function generateTestData(length, depth, submenuInterval, separatorInterval, prefix, root) {
        var data = [];
        if (root === undefined) root = true;

        for (var i = 0; i < length; i++) {

            var menuName = prefix;
            if (menuName === undefined) {
                var chars = Math.random() * 20;
                menuName = "";
                for (var x = 0; x < chars; x++) {
                    menuName += String.fromCharCode((Math.random() * 26) + 65);
                }
            }

            var menuCode = String.fromCharCode(i+65);

            var isSeparator = !root && separatorInterval > 0 && ((i+1) % separatorInterval == 0);
            var row = {
                "rowData": {                // 1
                    "label": menuName + "&" + menuCode,
                    "sensitive": true,
                    "isSeparator": isSeparator,
                    "icon": "",
                    "ext": {},
                    "action": menuName + menuCode,
                    "actionState": {},
                    "isCheck": false,
                    "isRadio": false,
                    "isToggled": false,
                    "shortcut": ""
                }
            }
            var isSubmenu = root === undefined || root === true || (submenuInterval > 0 && ((i+1) % submenuInterval == 0));
            if (isSubmenu && !isSeparator && depth > 1) {
                row["submenu"] = generateTestData(length, depth-1, submenuInterval, separatorInterval,prefix, false);
            }
            data[i] = row;
        }
        return data;
    }

    // Test Data
    property var singleCheckable: [{
            "rowData": {                // 1
                "label": "checkable1",
                "sensitive": true,
                "isSeparator": false,
                "icon": "",
                "ext": {},
                "action": "checkable1",
                "actionState": {},
                "isCheck": true,
                "isRadio": false,
                "isToggled": false,
                "shortcut": "Alt+F"
            }
        }]
}
