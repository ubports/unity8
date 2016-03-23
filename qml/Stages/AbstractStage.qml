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
import Ubuntu.Components 1.3
import GSettings 1.0

Rectangle {
    id: root

    color: "#060606"

    // Controls to be set from outside
    property bool altTabPressed
    property url background
    property bool beingResized
    property int dragAreaWidth
    property real dragProgress // How far left the stage has been dragged, used externally by tutorial code
    property bool interactive
    property real inverseProgress // This is the progress for left edge drags, in pixels.
    property bool keepDashRunning: true
    property real maximizedAppTopMargin
    property real nativeHeight
    property real nativeWidth
    property QtObject orientations
    property int shellOrientation
    property int shellOrientationAngle
    property bool spreadEnabled: true // If false, animations and right edge will be disabled
    property bool suspended
     // A Stage should paint a wallpaper etc over its full size but not use the margins for window placement
    property int leftMargin: 0

    // To be read from outside
    property var mainApp: null
    property var mainAppWindow: null
    property int mainAppWindowOrientationAngle: 0
    property bool orientationChangesEnabled
    property int supportedOrientations: Qt.PortraitOrientation
                                      | Qt.LandscapeOrientation
                                      | Qt.InvertedPortraitOrientation
                                      | Qt.InvertedLandscapeOrientation

    signal stageAboutToBeUnloaded

    // Shared code for use in stage implementations
    GSettings {
        id: lifecycleExceptions
        schema.id: "com.canonical.qtmir"
    }

    function isExemptFromLifecycle(appId) {
        var shortAppId = appId.split('_')[0];
        for (var i = 0; i < lifecycleExceptions.lifecycleExemptAppids.length; i++) {
            if (shortAppId === lifecycleExceptions.lifecycleExemptAppids[i]) {
                return true;
            }
        }
        return false;
    }
}
