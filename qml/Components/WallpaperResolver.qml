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

import QtQuick 2.4
import AccountsService 0.1
import GSettings 1.0
import Ubuntu.Components 1.3

/*
    Defines the background URL based on several factors, such as:
        - default, fallback, background
        - Background set in AccountSettings, if any
        - Background set in GSettings, if any
 */
QtObject {
    // Users should set their UI width here.
    property real width

    property url defaultBackground: Qt.resolvedUrl(width >= units.gu(60) ? "../graphics/tablet_background.jpg"
                                                                         : "../graphics/phone_background.jpg")

    // That's the property users of this component are going to consume.
    readonly property url background: asImageTester.status == Image.Ready ? asImageTester.source
                                    : gsImageTester.status == Image.Ready ? gsImageTester.source : defaultBackground

    // This is a dummy image to detect if the custom AS set wallpaper loads successfully.
    property var _asImageTester: Image {
        id: asImageTester
        source: AccountsService.backgroundFile != undefined && AccountsService.backgroundFile.length > 0 ? AccountsService.backgroundFile : ""
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
    }

    // This is a dummy image to detect if the custom GSettings set wallpaper loads successfully.
    property var _gsImageTester: Image {
        id: gsImageTester
        source: backgroundSettings.pictureUri && backgroundSettings.pictureUri.length > 0 ? backgroundSettings.pictureUri : ""
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
    }

    property var _gsettings: GSettings {
        id: backgroundSettings
        schema.id: "org.gnome.desktop.background"
    }
}
