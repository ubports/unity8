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
import QtTest 1.0
import Unity.Test 0.1
import "../../qml"

Item {
    id: root
    width: units.gu(40)
    height: units.gu(70)

    DeviceConfiguration {
        id: deviceConfiguration
    }

    UnityTestCase {
        id: testCase
        name: "DeviceConfiguration"
        when: windowShown

        function test_defaults() {
            compare(deviceConfiguration.name, "generic");
            compare(deviceConfiguration.category, "desktop");
            compare(deviceConfiguration.primaryOrientation, Qt.LandscapeOrientation)
            compare(deviceConfiguration.landscapeOrientation, Qt.LandscapeOrientation)
            compare(deviceConfiguration.portraitOrientation, Qt.PortraitOrientation)
            compare(deviceConfiguration.invertedLandscapeOrientation, Qt.InvertedLandscapeOrientation)
            compare(deviceConfiguration.invertedPortraitOrientation, Qt.InvertedPortraitOrientation)
            compare(deviceConfiguration.supportedOrientations, Qt.PortraitOrientation
                    | Qt.InvertedPortraitOrientation
                    | Qt.LandscapeOrientation
                    | Qt.InvertedLandscapeOrientation)
        }

        function test_nameOverride() {
            deviceConfiguration.overrideName = "flo";
            compare(deviceConfiguration.name, "flo");
            compare(deviceConfiguration.category, "tablet");
            compare(deviceConfiguration.primaryOrientation, Qt.InvertedLandscapeOrientation)
            compare(deviceConfiguration.landscapeOrientation, Qt.InvertedLandscapeOrientation)
            compare(deviceConfiguration.portraitOrientation, Qt.PortraitOrientation)
            compare(deviceConfiguration.invertedLandscapeOrientation, Qt.LandscapeOrientation)
            compare(deviceConfiguration.invertedPortraitOrientation, Qt.InvertedPortraitOrientation)
            compare(deviceConfiguration.supportedOrientations, Qt.PortraitOrientation
                    | Qt.InvertedPortraitOrientation
                    | Qt.LandscapeOrientation
                    | Qt.InvertedLandscapeOrientation)

            // Also try reseting override
            deviceConfiguration.overrideName = false;
            compare(deviceConfiguration.name, "generic");
            compare(deviceConfiguration.category, "desktop");
        }
    }
}
