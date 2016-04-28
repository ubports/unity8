/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import "../Components"

Showable {
    id: root

    property alias arrow: arrow
    property alias label: label
    property alias background: background
    property alias mouseArea: mouseArea
    property real opacityOverride: 1
    property bool paused
    property bool skipped
    property bool isReady

    signal finished()

    ////

    QtObject {
        id: d
        property bool showOnUnpause
    }

    visible: false
    shown: false

    opacity: Math.max(Math.min(_showOpacity, opacityOverride), 0)
    onOpacityOverrideChanged: {
        if (opacityOverride <= 0) {
            d.showOnUnpause = false;
            hideNow();
        }
    }
    property real _showOpacity: 0

    onPausedChanged: {
        if (paused && shown) {
            d.showOnUnpause = true;
            hide();
        } else if (!paused && d.showOnUnpause) {
            if (isReady) {
                show();
            } else if (hideAnimation.running) {
                hideAnimation.stop();
            }
            d.showOnUnpause = false;
        }
    }

    showAnimation: StandardAnimation {
        property: "_showOpacity"
        from: 0
        to: 1
        duration: UbuntuAnimation.SleepyDuration
        onStarted: root.visible = true
    }

    hideAnimation: StandardAnimation {
        property: "_showOpacity"
        to: 0
        duration: UbuntuAnimation.BriskDuration
        onStopped: {
            root.visible = false;
            if (!d.showOnUnpause) {
                root.finished();
            }
        }
    }

    MouseArea { // eat any errant presses
        id: mouseArea
        anchors.fill: parent
    }

    Image {
        id: background
        // Use x/y/height/width instead of anchors so that we don't adjust
        // the image if the OSK appears.
        x: 0
        y: 0
        height: root.height
        width: root.width
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        id: arrow
        width: units.gu(1.5)
        source: Qt.resolvedUrl("graphics/arrow.svg")
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    Label {
        id: label
        objectName: "tutorialLabel"
        fontSize: "large"
        font.weight: Font.Light
        color: "#333333"
        wrapMode: Text.Wrap
        lineHeight: 1.2
    }
}
