import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators

Object {
    Connections {
        target: SurfaceManager
        onSurfaceCreated: {
            var fakeMenuPath = "/" + surface.persistentId.replace(/\W+/g, "");

            ApplicationMenuRegistry.RegisterSurfaceMenu(surface.persistentId, fakeMenuPath, fakeMenuPath, ":1");
            Indicators.UnityMenuModelCache.setCachedModelData(fakeMenuPath, generateTestData(5, 3, 3, "menu"));
        }
        onSurfaceDestroyed: {
            ApplicationMenuRegistry.UnregisterSurfaceMenu(persistentSurfaceId, "/app");
        }
    }

    function generateTestData(length, depth, separatorInterval, prefix) {
        var data = [];

        if (prefix === undefined) prefix = "menu"

        for (var i = 0; i < length; i++) {

            var menuCode = String.fromCharCode(i+65);

            var isSeparator = separatorInterval > 0 && ((i+1) % separatorInterval == 0);
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
            if (!isSeparator && depth > 1) {
                var submenu = generateTestData(length, depth-1, separatorInterval, prefix + menuCode + ".");
                row["submenu"] = submenu;
            }
            data[i] = row;
        }
        return data;
    }
}
