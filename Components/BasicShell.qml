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

import GSettings 1.0
import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
import "../Components/Math.js" as MathLocal

FocusScope {
    id: shell

    // this is only here to select the width / height of the window if not running fullscreen
    property bool tablet: false
    width: tablet ? units.gu(160) : applicationArguments.hasGeometry() ? applicationArguments.width() : units.gu(40)
    height: tablet ? units.gu(100) : applicationArguments.hasGeometry() ? applicationArguments.height() : units.gu(71)

    property real edgeSize: units.gu(2)
    property url defaultBackground: shell.width >= units.gu(60) ? "../graphics/tablet_background.jpg" : "../graphics/phone_background.jpg"
    property url background

    GSettings {
        id: backgroundSettings
        schema.id: "org.gnome.desktop.background"
    }
    property url gSettingsPicture: backgroundSettings.pictureUri != undefined && backgroundSettings.pictureUri.length > 0 ? backgroundSettings.pictureUri : shell.defaultBackground
    onGSettingsPictureChanged: {
        shell.background = gSettingsPicture
    }

    // This is a dummy image that is needed to determine if the picture url
    // in backgroundSettings points to a valid picture file.
    // We can't do this with the real background image because setting a
    // new source in onStatusChanged triggers a binding loop detection
    // inside Image, which causes it not to render even though a valid source
    // would be set. We don't mind about this image staying black and just
    // use it for verification to populate the source for the real
    // background image.
    Image {
        source: shell.background
        height: 0
        width: 0
        sourceSize.height: 0
        sourceSize.width: 0
        onStatusChanged: {
            if (status == Image.Error && source != shell.defaultBackground) {
                shell.background = defaultBackground
            }
        }
    }

    VolumeControl {
        id: volumeControl
    }

    Keys.onVolumeUpPressed: volumeControl.volumeUp()
    Keys.onVolumeDownPressed: volumeControl.volumeDown()

    focus: true
}
