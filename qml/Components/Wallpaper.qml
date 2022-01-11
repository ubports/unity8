/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import QtQuick.Window 2.2
import Lomiri.Components 1.3

Item {
    id: root
    objectName: "Wallpaper"
    property url source: ""

    // sourceSize should be set to the largest width or height that this
    // Wallpaper will likely be set to.
    // In most cases inside Lomiri, this should be set to the width or height
    // of the shell, whichever is larger.
    // However, care should be taken to avoid changing sourceSize once
    // it's set.
    property real sourceSize: -1.0

    Image {
        id: image
        objectName: "wallpaperImage"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        asynchronous: true

        property real oldSourceSize: 0.0
        property real intermediarySourceSize: {
            // If minSourceSize is defined by root's parent, it will be 0 until
            // the binding resolves. Otherwise, it'll be -1.0. Abuse this
            // behavior to avoid changing sourceSize more than once during
            // startup
            if (root.sourceSize === 0.0) {
                developerSanityTimer.start();
                // -1.0 signals that the wallpaper shouldn't render yet.
                return -1.0
            }
            developerSanityTimer.stop();
            if (root.sourceSize === -1.0 && root.source !== "") {
                console.warn(`${root.objectName}'s sourceSize is unset. It will use a lot of memory.`);
                return 0.0
            }

            return root.sourceSize
        }

        onIntermediarySourceSizeChanged: {
            if (oldSourceSize !== 0.0 && oldSourceSize !== -1.0 && root.source !== "") {
                console.warn(`${root.objectName} source size is changing from ${oldSourceSize} to ${intermediarySourceSize}. This will cause an expensive image reload.`);
            }
            oldSourceSize = intermediarySourceSize;
        }

        sourceSize: Qt.size(intermediarySourceSize, intermediarySourceSize)
        source: intermediarySourceSize !== -1.0 ? root.source : ""
    }

    Rectangle {
        id: wallpaperFadeRectangle
        objectName: "wallpaperFadeRectangle"
        color: theme.palette.normal.background
        anchors.fill: parent
        opacity: image.status === Image.Ready ? 0: 1
        visible: opacity !== 0
        Behavior on opacity {
            LomiriNumberAnimation { duration: LomiriAnimation.FastDuration }
        }
    }

    Timer {
        id: developerSanityTimer
        interval: 2000
        running: false
        onTriggered: {
            if (root.sourceSize === 0.0 && root.source !== "") {
                console.warn(`${root.objectName} has not received its sourceSize yet. It will not render.`);
            }
        }
    }
}
