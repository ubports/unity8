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
 *  Expose an API that allows interaction with the
 *  integrated LightDM or real LightDM depending on shell mode.
 *  This is a hack to essentially support conditional imports
 */

import QtQuick 2.3

Loader {
    id: loader
    property alias greeter: _greeter
    property alias infographic: _infographic
    property alias users: _users

    // TODO: Conditionally load RealLightDMImpl if shellMode dictates it
    source: "./IntegratedLightDMImpl.qml"

    QtObject {
        id: d

        property bool valid: loader.item !== null
    }

    QtObject {
        id: _greeter

        property bool active: d.valid ? loader.item.greeter.active : null
        property bool authenticated: d.valid ? loader.item.greeter.authenticated : null
        property bool promptless: d.valid ? loader.item.greeter.promptless : null
        property var singelton: d.valid ? loader.item.greeter.singelton : null

        function authenticate(user) {
            if (d.valid) {
                loader.item.greeter.authenticate(user);
            }
        }

        function respond(response) {
            if (d.valid) {
                loader.item.greeter.respond(response);
            }
        }

        function showGreeter() {
            if (d.valid) {
                loader.item.greeter.showGreeter();
            }
        }

        function startSessionSync() {
            if (d.valid) {
                return loader.item.greeter.startSessionSync();
            }
        }
    }

    QtObject {
        id: _infographic

        property var model: d.valid ? loader.item.infographic.model : null

        function readyForDataChange() {
            if (d.valid) {
                return loader.item.infographic.readyForDataChange();
            }
        }
    }

    QtObject {
        id: _users

        property real count: d.valid ? loader.item.users.count : null
        property var model: d.valid ? loader.item.users.model : null

        function data(uid) {
            return loader.item.users.data(uid);
        }
    }

}

