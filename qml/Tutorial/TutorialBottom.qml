/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1
import "../Components"
import "." as LocalComponents

TutorialPage {
    id: root

    property alias edgeSize: dragArea.height

    title: i18n.tr("Open special menus")
    text: i18n.tr("Swipe up from the bottom edge.")
    fullTextWidth: true

    SequentialAnimation {
        id: teaseAnimation
        paused: running && root.paused
        running: !dragArea.useTouchY && slider.dragOffset === 0
        loops: Animation.Infinite

        UbuntuNumberAnimation {
            target: slider
            property: "teaseOffset"
            to: units.gu(1)
            duration: UbuntuAnimation.SleepyDuration
        }
        UbuntuNumberAnimation {
            target: slider
            property: "teaseOffset"
            to: 0
            duration: UbuntuAnimation.SleepyDuration
        }
    }

    foreground {
        children: [
            LocalComponents.Slider {
                id: slider
                anchors {
                    bottom: parent.bottom
                    bottomMargin: width / 2 - height / 2
                    horizontalCenter: parent.horizontalCenter
                }
                rotation: -90
                offset: teaseOffset + dragOffset
                active: dragArea.dragging

                property real teaseOffset
                property real dragOffset: dragArea.useTouchY ? -dragArea.touchY : 0

                Behavior on dragOffset {
                    id: offsetAnimation
                    UbuntuNumberAnimation {}
                }
            }
        ]
    }

    DirectionalDragArea {
        id: dragArea
        direction: Direction.Upwards
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        property bool useTouchY

        onDraggingChanged: {
            if (!dragging) {
                if (slider.percent >= 0.85) {
                    root.hide();
                } else if (slider.percent >= 0.15) {
                    root.showError();
                }
            }

            // We use a separate vars here rather than just directly looking at
            // 'dragging' because we want to preserve our 'slider.offset'
            // value during the above percent check.  Now that we made it,
            // we can have 'slider.offset' go back to zero.
            offsetAnimation.enabled = !dragging;
            useTouchY = dragging;
        }
    }
}
