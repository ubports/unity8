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
import GlobalShortcut 1.0
import AccountsService 0.1

Rectangle {
    id: root

    color: "#060606"

    // Controls to be set from outside
    property bool altTabPressed
    property url background
    property bool beingResized
    property int dragAreaWidth
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
    property int mainAppWindowOrientationAngle
    property bool orientationChangesEnabled
    property int supportedOrientations: Qt.PortraitOrientation
                                      | Qt.LandscapeOrientation
                                      | Qt.InvertedPortraitOrientation
                                      | Qt.InvertedLandscapeOrientation

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

    // keymap switching, shared between stages
    GlobalShortcut {
        shortcut: Qt.MetaModifier|Qt.Key_Space
        onTriggered: keymapPriv.nextKeymap()
        active: keymapPriv.keymapCount > 1
    }

    GlobalShortcut {
        shortcut: Qt.MetaModifier|Qt.ShiftModifier|Qt.Key_Space
        onTriggered: keymapPriv.previousKeymap()
        active: keymapPriv.keymapCount > 1
    }

    QtObject {
        id: keymapPriv

        readonly property var keymaps: AccountsService.keymaps
        readonly property int keymapCount: keymaps.length
        readonly property int activeKeymapIndex: mainAppWindow ? keymaps.indexOf(mainAppWindow.activeKeymap) : 0 // the one that the window currently has
        property int currentKeymapIndex: 0  // the new one that we're setting
        onCurrentKeymapIndexChanged: switchToKeymap();

        function nextKeymap() {
            var nextIndex = 0;

            if (activeKeymapIndex !== -1 && activeKeymapIndex < keymapCount - 1) {
                nextIndex = activeKeymapIndex + 1;
            }
            print("!!! next keymap:", currentKeymapIndex, "->", nextIndex);
            currentKeymapIndex = nextIndex;
        }

        function previousKeymap() {
            var prevIndex = keymapCount - 1;

            if (activeKeymapIndex > 0) {
                prevIndex = activeKeymapIndex - 1;
            }
            print("!!! prev keymap:", currentKeymapIndex, "->", prevIndex);
            currentKeymapIndex = prevIndex;
        }

        function switchToKeymap() {
            if (mainAppWindow) {
                mainAppWindow.switchToKeymap(keymaps[currentKeymapIndex]);
            }
        }
    }

    onMainAppWindowChanged: {
        keymapPriv.switchToKeymap()
    }
}
