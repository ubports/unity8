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

// Make sure we don't duplicate models.
Item {
    id: cachedModel
    property string busName: ""
    property string actionsObjectPath: ""
    property string menuObjectPath: ""

    readonly property bool ready: busName!=="" && actionsObjectPath!=="" && menuObjectPath!==""

    property QtObject model: {
        if (!ready) {
            return null;
        }

        var component = Indicators.UnityMenuModelCache.model(menuObjectPath);
        if (!component) {
            component = modelComponent.createObject(cachedModel);
            return component;
        }
        return component;
    }

    Component {
        id: modelComponent

        QMenuModel.UnityMenuModel {
            id: unityModel
            busName: cachedModel.busName
            actions: { "indicator": cachedModel.actionsObjectPath }
            menuObjectPath: cachedModel.menuObjectPath

            Component.onCompleted: {
                Indicators.UnityMenuModelCache.registerModel(cachedModel.menuObjectPath, unityModel);
            }
        }
    }
}
