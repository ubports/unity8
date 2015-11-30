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

pragma Singleton
import QtQuick 2.4
import GSettings 1.0

QtObject {
    id: root

    // The only public property
    readonly property real pushThreshold:
            d.minPushThreshold + ((d.maxPushThreshold - d.minPushThreshold) * (1.0 - d.sensitivity))

    onPushThresholdChanged: {
        // Avoid calling d.printSettings() directly as it would spam the console during initialization
        d.printSettingsTimer.start();
    }

    property QtObject priv: QtObject {
        id: d

        property Timer printSettingsTimer: Timer {
            interval: 1
            onTriggered: printSettings();
        }
        function printSettings() {
            console.log("EdgeBarrierSettings: min="+(minPushThreshold/units.gu(1))+"gu("+minPushThreshold+"px)"
            +", max="+(maxPushThreshold/units.gu(1))+"gu("+maxPushThreshold+"px)"
            +", sensitivity="+sensitivity
            +", threshold="+(pushThreshold/units.gu(1))+"gu("+pushThreshold+"px)"
            );
        }

        property real defaultMinPushThreshold: units.gu(2)
        property real minPushThreshold: gsettings.edgeBarrierMinPush ? units.gu(gsettings.edgeBarrierMinPush) : defaultMinPushThreshold
        property real maxPushThreshold: {
            if (gsettings.edgeBarrierMaxPush && units.gu(gsettings.edgeBarrierMaxPush) > minPushThreshold) {
                return units.gu(gsettings.edgeBarrierMaxPush);
            } else if (minPushThreshold == defaultMinPushThreshold) {
                return units.gu(60);
            } else {
                return minPushThreshold * 10.0;
            }
        }
        // Value range is [0.0, 1.0]
        readonly property real sensitivity: gsettings.edgeBarrierSensitivity
            ? Math.min(Math.max(0, gsettings.edgeBarrierSensitivity), 100) / 100
            : 0.35

        property var gsettings: GSettings { schema.id: "com.canonical.Unity8" }
    }
}
