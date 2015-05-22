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

import QtQuick 2.3
import IntegratedLightDM 0.1 as LightDM

QtObject {
    property bool active: LightDM.Greeter.active
    property bool authenticated: LightDM.Greeter.authenticated
    property bool promptless: LightDM.Greeter.promptless
    property real userCount: LightDM.Users.count

    property var theGreeter: LightDM.Greeter
    property var infographicModel: LightDM.Infographic
    property var userModel: LightDM.Users

    function authenticate(user) {
        LightDM.Greeter.authenticate(user);
    }

    function getUser(uid) {
        return LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
    }

    function infographicReadyForDataChange() {
        LightDM.Infographic.readyForDataChange();
    }

    function respond(response) {
        LightDM.Greeter.respond(response);
    }

    function showGreeter() {
        LightDM.Greeter.showGreeter();
    }

    function startSessionSync() {
        return LightDM.Greeter.startSessionSync();
    }
}
