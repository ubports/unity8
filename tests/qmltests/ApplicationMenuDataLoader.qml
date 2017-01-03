import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators

Object {

    property var surfaceManager: null

    Connections {
        target: surfaceManager
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

        if (prefix === undefined) prefix = "menu"

        for (var i = 0; i < length; i++) {

            var menuCode = String.fromCharCode(i+65);

            var isSeparator = !root && separatorInterval > 0 && ((i+1) % separatorInterval == 0);
            var row = {
                "rowData": {                // 1
                    "label": prefix + "&" + menuCode,
                    "sensitive": true,
                    "isSeparator": isSeparator,
                    "icon": "",
                    "ext": {},
                    "action": prefix + menuCode,
                    "actionState": {},
                    "isCheck": false,
                    "isRadio": false,
                    "isToggled": false,
                    "shortcut": ""
                }
            }
            var isSubmenu = root === undefined || root === true || (submenuInterval > 0 && ((i+1) % submenuInterval == 0));
            if (isSubmenu && !isSeparator && depth > 1) {
                row["submenu"] = generateTestData(length, depth-1, submenuInterval, separatorInterval, prefix + menuCode + ".", false);
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
