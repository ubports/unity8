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
import Ubuntu.Components 1.3
import "Components"

Image {
    id: root

    WallpaperResolver {
        width: root.width
        id: wallpaperResolver
    }

    source: wallpaperResolver.background

    UbuntuShape {
        anchors.fill: text
        anchors.margins: -units.gu(2)
        backgroundColor: "black"
        opacity: 0.4
    }

    Label {
        id: text
        anchors.centerIn: parent
        width: parent.width / 2
        text: i18n.tr("Your device is now connected to an external display.")
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSize: "x-large"
        wrapMode: Text.Wrap
    }
}
