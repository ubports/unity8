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
import QMenuModel 0.1

Item {
    id: root
    objectName: "volumeControl"
    visible: false
    property int volume

    QDBusActionGroup {
        id: actionGroup
        busType: 1
        busName: "com.canonical.settings.sound"
        objectPath: "/com/canonical/settings/sound"

        property variant actionObject: action("volume")
        property variant serverVolume: actionObject.valid ? actionObject.state: 0
    }

    Binding {
        target: root
        property: "volume"
        value: actionGroup.serverVolume * 100
    }

    onVolumeChanged: {
        if (actionGroup.serverVolume != volume) {
            var targetVolume = Math.min(1, Math.max(0, volume / 100));
            actionGroup.actionObject.updateState(targetVolume);
        }
    }

    function volumeUp() {
        actionGroup.actionObject.updateState(Math.min(1, volume/100 + 0.10));
    }

    function volumeDown() {
        actionGroup.actionObject.updateState(Math.max(0, volume/100 - 0.10));
    }

    Component.onCompleted: actionGroup.start()
}
