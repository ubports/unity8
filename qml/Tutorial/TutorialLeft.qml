/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import "." as LocalComponents

TutorialPage {
    id: root

    property var launcher

    title: i18n.tr("Open the launcher")
    text: i18n.tr("Short swipe from the left edge.")

    textXOffset: root.launcher.x + root.launcher.visibleWidth

    Connections {
        target: root.launcher

        onStateChanged: {
            if (root.launcher.state === "visible") {
                finishTimer.start();
            }
        }

        onDash: {
            finishTimer.stop();
            root.showError();
            root.launcher.hide();
        }
    }

    SequentialAnimation {
        id: teaseAnimation
        objectName: "teaseAnimation"
        paused: running && root.paused
        running: !slider.active && root.launcher.visibleWidth === 0 && root.shown
        loops: Animation.Infinite
        property real bounce: 0
        readonly property real maxBounce: units.gu(2)

        UbuntuNumberAnimation {
            target: teaseAnimation
            property: "bounce"
            to: teaseAnimation.maxBounce
            duration: UbuntuAnimation.SleepyDuration
        }
        UbuntuNumberAnimation {
            target: teaseAnimation
            property: "bounce"
            to: 0
            duration: UbuntuAnimation.SleepyDuration
        }
    }

    Binding {
        target: root.launcher
        when: root.shown
        property: "x"
        value: Math.min(root.launcher.panelWidth - root.launcher.visibleWidth, teaseAnimation.bounce)
    }

    Timer {
        id: finishTimer
        interval: 1
        onTriggered: {
            root.hide();
            root.launcher.x = 0; // make sure to reset launcher before we go
        }
    }

    foreground {
        children: [
            LocalComponents.Slider {
                id: slider
                anchors {
                    left: parent.left
                    top: parent.top
                    topMargin: root.textBottom + units.gu(3)
                }
                offset: root.launcher.x + root.launcher.visibleWidth + root.launcher.progress
                active: root.launcher.dragging
                shortSwipe: true
            }
        ]
    }
}
