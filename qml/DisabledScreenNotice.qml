/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Session 0.1
import QtQuick.Window 2.2
import "Components"

Item {
    id: root

    // For testing
    property var screen: Screen
    property var orientationLock: OrientationLock

    property bool oskEnabled: false

    property alias deviceConfiguration: _deviceConfiguration
    DeviceConfiguration {
        id: _deviceConfiguration
        name: applicationArguments.deviceName
    }

    Item {
        id: contentContainer
        objectName: "contentContainer"
        anchors.centerIn: parent
        height: rotation == 90 || rotation == 270 ? parent.width : parent.height
        width: rotation == 90 || rotation == 270 ? parent.height : parent.width

        property int savedOrientation: deviceConfiguration.primaryOrientation == deviceConfiguration.useNativeOrientation
                                       ? (root.width > root.height ? Qt.LandscapeOrientation : Qt.PortraitOrientation)
                                       : deviceConfiguration.primaryOrientation

        rotation: {
            var usedOrientation = root.screen.orientation;

            if (root.orientationLock.enabled) {
                usedOrientation = savedOrientation;
            }

            savedOrientation = usedOrientation;

            switch (usedOrientation) {
            case Qt.PortraitOrientation:
                return 0;
            case Qt.LandscapeOrientation:
                return 270;
            case Qt.InvertedPortraitOrientation:
                return 180;
            case Qt.InvertedLandscapeOrientation:
                return 90;
            }

            return 0;
        }
        transformOrigin: Item.Center

        Rectangle {
            anchors.fill: parent
            color: UbuntuColors.jet
        }

        VirtualTouchPad {
            objectName: "virtualTouchPad"
            anchors.fill: parent
            oskEnabled: root.oskEnabled
        }
    }
}
