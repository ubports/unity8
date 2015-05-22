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

    // TODO: Conditionally load RealLightDMImpl if shellMode dictates it
    source: "IntegratedLightDMImpl.qml"

    QtObject {
        id: d

        property bool valid: loader.item !== null
    }

    property bool active: d.valid ? item.active : null
    property bool authenticated: d.valid ? item.authenticated : null
    property bool promptless: d.valid ? item.promptless : null
    property real userCount: d.valid ? item.userCount : null

    property var theGreeter: d.valid ? item.theGreeter : null
    property var infographicModel: d.valid ? item.infographicModel : null
    property var userModel: d.valid ? item.userModel : null

    function authenticate(user) {
        if (d.valid) {
            item.authenticate(user);
        }
    }

    function getUser(uid) {
        if (d.valid) {
            return item.getUser(uid);
        }
    }

    function infographicReadyForDataChange() {
        if (d.valid) {
            return item.infographicReadyForDataChange();
        }
    }

    function respond(response) {
        if (d.valid) {
            item.respond(response);
        }
    }

    function showGreeter() {
        if (d.valid) {
            item.showGreeter();
        }
    }

    function startSessionSync() {
        if (d.valid) {
            item.startSessionSync();
        }
    }
}

