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

import QtQuick 2.0

StateGroup {
    id: root

    readonly property int useNativeOrientation: -1

    property int primaryOrientation: useNativeOrientation

    property int supportedOrientations: Qt.PortraitOrientation
                                      | Qt.InvertedPortraitOrientation
                                      | Qt.LandscapeOrientation
                                      | Qt.InvertedLandscapeOrientation

    // Supported values so far:
    // "phone", "tablet" or "desktop"
    property string category: "phone"

    property int ignoredMice: 0


    property alias name: root.state

    states: [
        State {
            name: "mako"
            PropertyChanges {
                target: root
                supportedOrientations: Qt.PortraitOrientation
                                     | Qt.LandscapeOrientation
                                     | Qt.InvertedLandscapeOrientation
            }
        },
        State {
            name: "krillin"
            PropertyChanges {
                target: root
                supportedOrientations: Qt.PortraitOrientation
                                     | Qt.LandscapeOrientation
                                     | Qt.InvertedLandscapeOrientation
            }
        },
        State {
            name: "arale"
            PropertyChanges {
                target: root
                supportedOrientations: Qt.PortraitOrientation
                                     | Qt.LandscapeOrientation
                                     | Qt.InvertedLandscapeOrientation
                ignoredMice: 1
            }
        },
        State {
            name: "manta"
            PropertyChanges {
                target: root
                category: "tablet"
            }
        },
        State {
            name: "flo"
            PropertyChanges {
                target: root
                primaryOrientation: Qt.InvertedLandscapeOrientation
                category: "tablet"
            }
        },
        State {
            name: "desktop"
            PropertyChanges {
                target: root
                category: "desktop"
                supportedOrientations: root.useNativeOrientation
            }
        }
    ]

}
