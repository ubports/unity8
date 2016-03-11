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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Wizard 0.1
import "../Components"

Showable {
    id: root

    // This is a bool instead of an alias because Loader classes like to emit
    // changed signals for 'active' during startup even if they aren't actually
    // changing values. Having it cached as a proper Qml bool property prevents
    // unnecessary 'changed' emissions and provides consuming classes the
    // expected behavior of no emission on startup.
    readonly property bool active: loader.active

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
        source: "Pages.qml"

        Connections {
            target: loader.item
            onQuit: root.hide()
        }
    }
}
