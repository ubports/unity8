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

import QtQuick 2.3
import Ubuntu.Components 1.1
import Wizard 0.1
import "../Components"

Showable {
    // The background wallpaper to use
    property string background

    ////

    id: root

    hideAnimation: StandardAnimation { property: "opacity"; to: 0 }

    onRequiredChanged: {
        if (!required) {
            System.wizardEnabled = false;
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        active: System.wizardEnabled
        sourceComponent: Pages {
            anchors.fill: parent
            background: root.background
            onQuit: root.hide()
        }
    }
}
