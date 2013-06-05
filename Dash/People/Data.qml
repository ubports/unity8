/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Dee 3.0

DeeVariantText {
    property string uri
    property string name
    property url avatar
    property var emails: ListModel {}
    property var phones: ListModel {}
    property string presenceStatus
    property string presenceMessage
    property url remoteSourceIcon
    property string remotePost
    property bool favorite
    property bool recent
    property url statusIcon
    property string status: remotePost ? remotePost : presenceMessage
    property url recentIcon
    property string recentTime

    statusIcon: switch(presenceStatus) {
        case "offline": "graphics/icon_offline.png"; break
        // FIXME random for now, as we don't get actual presence data on the phone
        case "":
            var r = Math.random();
            if (r >= 0.7) "graphics/icon_online.png"
            else if (r >= 0.4) "graphics/icon_offline.png"
            else "graphics/icon_unknown.png"
            break;
        default: "graphics/icon_online.png"
    }

    onValueChanged: {
        for (var i in value) switch (value[i][0]) {
            case "presence-message": presenceMessage = value[i][1]; break
            case "presence-status": presenceStatus = value[i][1]; break
            case "remote-source-icon": remoteSourceIcon = value[i][1]; break
            case "remote-post": remotePost = value[i][1]; break
            case "recent-icon": recentIcon = value[i][1]; break
            case "recent-time": recentTime = value[i][1]; break
            case "phone": phones.append({"type": generateType(), "number": value[i][1]}); break
            case "email": emails.append({"type": generateType(), "address": value[i][1]}); break
        }
    }

    // FIXME: random for now, as we don't have multiple phone numbers in the backend yet
    function generateType() {
        var phoneType = "";
        var r = Math.random();
        if (r >= 0.7) phoneType = "Private";
        else if (r >= 0.4) phoneType = "Mobile";
        else phoneType = "Work";
        return phoneType;
    }
}
