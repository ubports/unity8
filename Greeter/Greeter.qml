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
import Ubuntu.Components 0.1
import LightDM 0.1 as LightDM
import "../Components"

Showable {
    id: greeter
    enabled: shown
    created: greeterContentLoader.status == Loader.Ready && greeterContentLoader.item.ready

    property alias model: greeterContentLoader.model
    property bool locked: shown && multiUser && !greeterContentLoader.promptless

    readonly property bool narrowMode: !multiUser && width <= units.gu(60)
    readonly property bool multiUser: LightDM.Users.count > 1

    readonly property bool leftTeaserPressed: greeterContentLoader.status == Loader.Ready &&
                                              greeterContentLoader.item.leftTeaserPressed
    readonly property bool rightTeaserPressed: greeterContentLoader.status == Loader.Ready &&
                                               greeterContentLoader.item.rightTeaserPressed

    signal selected(int uid)
    signal unlocked(int uid)

    onRightTeaserPressedChanged: {
        if (rightTeaserPressed) {
            teasingTimer.start();
        }
    }

    Loader {
        id: greeterContentLoader
        objectName: "greeterContentLoader"
        anchors.fill: parent
        property var model: LightDM.Users
        property int currentIndex: 0
        property bool promptless: item ? item.promptless : false
        property var infographicModel: LightDM.Infographic

        source: required ? "GreeterContent.qml" : ""


        Connections {
            target: greeterContentLoader.item

            onSelected: greeter.selected(uid);
            onUnlocked: greeter.unlocked(uid);
        }
    }

    Timer {
        id: teasingTimer
        interval: 200
    }

    states: [
        State {
            name: "teasing"
            when: greeter.rightTeaserPressed || teasingTimer.running
            PropertyChanges {
                target: greeter
                x: -units.gu(2)
            }
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation {
                target: greeter
                property: "x"
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
    ]
}
