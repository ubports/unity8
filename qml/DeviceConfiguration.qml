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

QtObject {
    id: root

    readonly property int useNativeOrientation: -1

    // The only writable property in the API
    // all other properties are set according to the device name
    property alias name: priv.state

    readonly property alias primaryOrientation: priv.primaryOrientation
    readonly property alias supportedOrientations: priv.supportedOrientations
    readonly property alias landscapeOrientation: priv.landscapeOrientation
    readonly property alias invertedLandscapeOrientation: priv.invertedLandscapeOrientation
    readonly property alias portraitOrientation: priv.portraitOrientation
    readonly property alias invertedPortraitOrientation: priv.invertedPortraitOrientation

    readonly property alias category: priv.category

    readonly property alias ignoredMice: priv.ignoredMice

    readonly property var priv: StateGroup {
        id: priv

        property int primaryOrientation: root.useNativeOrientation

        property int supportedOrientations: Qt.PortraitOrientation
                                          | Qt.InvertedPortraitOrientation
                                          | Qt.LandscapeOrientation
                                          | Qt.InvertedLandscapeOrientation

        property int landscapeOrientation: Qt.LandscapeOrientation
        property int invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
        property int portraitOrientation: Qt.PortraitOrientation
        property int invertedPortraitOrientation: Qt.InvertedPortraitOrientation

        // Supported values so far:
        // "phone", "tablet" or "desktop"
        property string category: "phone"

        property int ignoredMice: 0

        states: [
            State {
                name: "mako"
                PropertyChanges {
                    target: priv
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                }
            },
            State {
                name: "krillin"
                PropertyChanges {
                    target: priv
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                }
            },
            State {
                name: "arale"
                PropertyChanges {
                    target: priv
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    ignoredMice: 1
                }
            },
            State {
                name: "manta"
                PropertyChanges {
                    target: priv
                    category: "tablet"
                }
            },
            State {
                name: "flo"
                PropertyChanges {
                    target: priv
                    landscapeOrientation: Qt.InvertedLandscapeOrientation
                    invertedLandscapeOrientation: Qt.LandscapeOrientation
                    primaryOrientation: Qt.InvertedLandscapeOrientation
                    category: "tablet"
                }
            },
            State {
                name: "desktop"
                PropertyChanges {
                    target: priv
                    category: "desktop"
                    supportedOrientations: root.useNativeOrientation
                }
            }
        ]
    }
}
