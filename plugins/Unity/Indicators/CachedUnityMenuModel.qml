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
import QMenuModel 0.1
import Unity.Indicators 0.1 as Indicators

// Make sure we don't duplicate models.
Item {
    id: cachedModel
    property string busName
    property string actionsObjectPath
    property string menuObjectPath
    readonly property bool ready: busName!=="" && actionsObjectPath!=="" && menuObjectPath!==""

    property UnityMenuModel model: {
        if (!ready) return null;

        var newModel = Indicators.UnityMenuModelCache.model(menuObjectPath);
        if (!newModel) {
            newModel = modelComponent.createObject(null,
                                                   {
                                                       "busName": cachedModel.busName,
                                                       "menuObjectPath": cachedModel.menuObjectPath,
                                                       "actions": { "indicator": cachedModel.actionsObjectPath },
                                                   });
            Indicators.UnityMenuModelCache.registerModel(newModel.menuObjectPath, newModel);
        }
        return newModel;
    }

    Component {
        id: modelComponent
        UnityMenuModel {}
    }
}
