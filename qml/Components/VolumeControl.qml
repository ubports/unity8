/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import QMenuModel 0.1 as QMenuModel
import GlobalShortcut 1.0

Item {
    id: root
    objectName: "volumeControl"
    visible: false

    // TODO Work around http://pad.lv/1293478 until qmenumodel knows to cast
    readonly property int stepUp: 1
    readonly property int stepDown: -1

    property var indicators // passed from Shell.qml

    GlobalShortcut {
        id: muteShortcut
        shortcut: Qt.Key_VolumeMute
        onTriggered: toggleMute()
    }

    QMenuModel.QDBusActionGroup {
        id: actionGroup
        busType: QMenuModel.DBus.SessionBus
        busName: "com.canonical.indicator.sound"
        objectPath: "/com/canonical/indicator/sound"

        property variant actionObject: action("volume")
        property variant muteActionObject: indicators.indicatorsModel.profile === "desktop" ? action("mute") : action("silent-mode")
    }

    function volumeUp() {
        actionGroup.actionObject.activate(stepUp);
    }

    function volumeDown() {
        actionGroup.actionObject.activate(stepDown);
    }

    function toggleMute() {
        actionGroup.muteActionObject.activate();
    }

    Component.onCompleted: {
        actionGroup.start();
    }
}
