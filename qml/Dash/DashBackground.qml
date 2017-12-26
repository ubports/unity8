/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

import QtQuick 2.4
import AccountsService 0.1
import GSettings 1.0

Rectangle {
    GSettings {
        id: settings
        schema.id: "com.ubuntu.touch.system-settings"
    }

    color: settings.dashBackground ? "black" : "white"

    Image {
        visible: settings.dashBackground
        source: AccountsService.backgroundFile
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: settings.backgroundOpacity
    }
}
