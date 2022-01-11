/*
 * Copyright (C) 2021 UBports Foundation
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
import Lomiri.Components 1.3
import Lomiri.SelfTest 0.1

import "../../../qml/Components"


Item {
    id: root
    width: 150
    height: 100

    property url defaultBackground: "../../data/lomiri/backgrounds/20x30.png"
    property real sourceSize: 0

    Component {
        id: wallpaperComponent
        Wallpaper {
            anchors.fill: parent
            source: root.defaultBackground
            sourceSize: root.sourceSize
        }
    }

    Component {
        id: unsetSourceSizeWallpaperComponent
        Wallpaper {
            anchors.fill: parent
            source: root.defaultBackground
        }
    }

    LomiriTestCase {
        id: testCase
        name: "Wallpaper"
        when: windowShown

        function init() {
            root.sourceSize = 0;
            root.defaultBackground = "../../data/lomiri/backgrounds/20x30.png";
        }

        // Ensures that the Wallpaper's sourceSize causes the image to be
        // scaled while matching its original aspect ratio.
        function test_wallpaperGetsSourceSize() {
            root.sourceSize = 10;
            var wallpaper = createTemporaryObject(wallpaperComponent, root);
            var image = findChild(wallpaper, "wallpaperImage");
            verify(image);
            tryCompare(image, "status", Image.Ready);
            tryCompare(image, "implicitWidth", 10.0);
            tryCompare(image, "implicitHeight", 15.0);
        }

        function test_warningOnSizeChange() {
            root.sourceSize = 1;
            var wallpaper = createTemporaryObject(wallpaperComponent, root);
            ignoreWarning(new RegExp(".*source size is changing.*"));
            root.sourceSize = 10;
        }

        // Ensures the Wallpaper's sourceSize is unbounded and the image loads
        // when sourceSize is unset
        function test_sizeUnset() {
            ignoreWarning(new RegExp(".*sourceSize is unset.*"));
            var wallpaper = createTemporaryObject(unsetSourceSizeWallpaperComponent, root);
            var image = findChild(wallpaper, "wallpaperImage");
            // Reading the property is enough to make sure the warning happened
            tryCompare(image, "status", Image.Ready);
            tryCompare(image, "implicitWidth", 20.0);
            tryCompare(image, "implicitHeight", 30.0);
        }

        function test_warningOnSizeBindingFailed() {
            // When a binding fails, it will be undefined or zero. Since
            // a 'real' property is read as zero when it is undefined anyway,
            // use that.
            root.sourceSize = 0;
            ignoreWarning(new RegExp(".*will not render.*"));
            var wallpaper = createTemporaryObject(wallpaperComponent, root);
            // A SignalSpy waiting for the signal that causes the warning would
            // be more correct, but hooking up the SignalSpy is sometimes slower
            // than the event triggering the warning and we end up waiting
            // forever.
            wait(3000);
        }

        // Ensures there is a blocker over the wallpaper before it has loaded
        // which goes away once loading finishes
        function test_wallpaperBlock() {
            root.sourceSize = 1;
            root.defaultBackground = "";
            var wallpaper = createTemporaryObject(wallpaperComponent, root);
            var wallpaperFadeRectangle = findChild(wallpaper, "wallpaperFadeRectangle");
            compare(wallpaperFadeRectangle.opacity, 1);
            root.defaultBackground = "../../data/lomiri/backgrounds/red.png";
            tryCompare(wallpaperFadeRectangle, "opacity", 0);
            compare(wallpaperFadeRectangle.visible, false);
        }
    }
}
