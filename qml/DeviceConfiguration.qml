/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import Utils 0.1

QtObject {
    id: root

    // This allows to override device name, used for convergence
    // to set screens to desktop "mode"
    property var overrideName: false

    readonly property int useNativeOrientation: -1

    readonly property alias name: priv.name;

    readonly property alias primaryOrientation: priv.primaryOrientation
    readonly property alias supportedOrientations: priv.supportedOrientations
    readonly property alias landscapeOrientation: priv.landscapeOrientation
    readonly property alias invertedLandscapeOrientation: priv.invertedLandscapeOrientation
    readonly property alias portraitOrientation: priv.portraitOrientation
    readonly property alias invertedPortraitOrientation: priv.invertedPortraitOrientation

    readonly property alias category: priv.category

    readonly property var deviceConfig: DeviceConfig {}

    readonly property var binding: Binding {
        target: priv
        property: "state"
        value: root.overrideName ? overrideName : deviceConfig.name
    }

    readonly property var priv: StateGroup {
        id: priv

        property int primaryOrientation: deviceConfig.primaryOrientation == Qt.PrimaryOrientation ?
                                             root.useNativeOrientation : deviceConfig.primaryOrientation

        property int supportedOrientations: deviceConfig.supportedOrientations

        property int landscapeOrientation: deviceConfig.landscapeOrientation
        property int invertedLandscapeOrientation: deviceConfig.invertedLandscapeOrientation
        property int portraitOrientation: deviceConfig.portraitOrientation
        property int invertedPortraitOrientation: deviceConfig.invertedPortraitOrientation
        property string category: deviceConfig.category
        property string name: deviceConfig.name
        property bool supportsMultiColorLed: deviceConfig.supportsMultiColorLed

        states: [
            State {
                name: "mako"
                PropertyChanges {
                    target: priv
                    primaryOrientation: root.useNativeOrientation
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    landscapeOrientation: Qt.LandscapeOrientation
                    invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    category: "phone"
                    name: "mako"
                }
            },
            State {
                name: "krillin"
                PropertyChanges {
                    target: priv
                    primaryOrientation: root.useNativeOrientation
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    landscapeOrientation: Qt.LandscapeOrientation
                    invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    category: "phone"
                    name: "krillin"
                }
            },
            State {
                name: "arale"
                PropertyChanges {
                    target: priv
                    primaryOrientation: root.useNativeOrientation
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.InvertedPortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    landscapeOrientation: Qt.LandscapeOrientation
                    invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    supportsMultiColorLed: false
                    category: "phone"
                    name: "arale"
                }
            },
            State {
                name: "manta"
                PropertyChanges {
                    target: priv
                    primaryOrientation: root.useNativeOrientation
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.InvertedPortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    landscapeOrientation: Qt.LandscapeOrientation
                    invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    category: "tablet"
                    name: "manta"
                }
            },
            State {
                name: "flo"
                PropertyChanges {
                    target: priv
                    primaryOrientation: Qt.InvertedLandscapeOrientation
                    supportedOrientations: Qt.PortraitOrientation
                                         | Qt.InvertedPortraitOrientation
                                         | Qt.LandscapeOrientation
                                         | Qt.InvertedLandscapeOrientation
                    landscapeOrientation: Qt.InvertedLandscapeOrientation
                    invertedLandscapeOrientation: Qt.LandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    category: "tablet"
                    name: "flo"
                }
            },
            State {
                name: "desktop"
                PropertyChanges {
                    target: priv
                    primaryOrientation: root.useNativeOrientation
                    supportedOrientations: root.useNativeOrientation
                    landscapeOrientation: Qt.LandscapeOrientation
                    invertedLandscapeOrientation: Qt.InvertedLandscapeOrientation
                    portraitOrientation: Qt.PortraitOrientation
                    invertedPortraitOrientation: Qt.InvertedPortraitOrientation
                    category: "desktop"
                    name: "desktop"
                }
            },
            State {
                name: "turbo"
                PropertyChanges {
                    target: priv
                    supportsMultiColorLed: false
                }
            }
        ]
    }
}
