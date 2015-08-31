/*
 * Copyright (C) 2015 Canonical, Ltd.
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

/**
 * Lightweight wrapper that allows for loading integrated/real LightDM
 * plugin
 */

import QtQuick 2.3

Loader {
    id: loader

    property var greeter: d.valid ? loader.item.greeter : null
    property var infographic: d.valid ? loader.item.infographic : null
    property var users: d.valid ? loader.item.users : null
    property var userRoles: d.valid ? loader.item.userRoles : null

    // TODO: Conditionally load RealLightDMImpl if shellMode dictates it
    source: "./IntegratedLightDMImpl.qml"

    QtObject {
        id: d

        property bool valid: loader.item !== null
    }

}
