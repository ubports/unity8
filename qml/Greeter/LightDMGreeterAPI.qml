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
 *  integrated LightDM or real LightDM depending on shell mode
 */
import QtQuick 2.3

Loader {
    source: "IntegratedLightDMImpl.qml"
    property bool valid: item !== null

    property bool active: item.active
    property bool authenticated: item.authenticated
    property bool promptless: item.promptless
    property real userCount: item.userCount

    property var theGreeter: item.theGreeter
    property var infographicModel: item.infographicModel
    property var userModel: item.userModel

    function authenticate(user) {
        if (valid) item.authenticate(user);
    }

    function getUser(uid) {
        if (valid) item.getUser(uid);
    }

    function infographicReadyForDataChange() {
        if (valid) return item.infographicReadyForDataChange();
    }

    function respond(response) {
        if (valid) item.respond(response);
    }

    function showGreeter() {
        if (valid) item.showGreeter();
    }

    function startSessionSync() {
        if (valid) item.startSessionSync();
    }
}

