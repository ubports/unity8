/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1

Item {
    id: root

    property alias window: applicationWindow
    property alias application: applicationWindow.application

    property bool highlightShown: false
    property real shadowOpacity: 1

    property int windowWidth: application && application.session && application.session.lastSurface ? application.session.lastSurface.size.width : 0
    property int windowHeight: application && application.session && application.session.lastSurface ? application.session.lastSurface.size.height : 0

    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: root
                width: windowWidth
                height: windowHeight
            }
        },
        State {
            name: "transformed"
            PropertyChanges {
                target: applicationWindow
                itemScale: Math.max(root.width / root.windowWidth, root.height / root.windowHeight)
                interactive: false
            }
            PropertyChanges {
                target: clipper
                clip: true
            }
        }
    ]

    scale: highlightShown ? 1.025 : 1
    Behavior on scale {
        UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
    }

    BorderImage {
        anchors {
            fill: root
            margins: -units.gu(2)
        }
        source: "graphics/dropshadow2gu.sci"
        opacity: root.shadowOpacity * .3
    }

    Rectangle {
        id: selectionHighlight
        anchors.fill: parent
        anchors.margins: -units.gu(1)
        color: "white"
        opacity: highlightShown ? 0.55 : 0
        antialiasing: true
    }

    Rectangle {
        anchors { left: selectionHighlight.left; right: selectionHighlight.right; bottom: selectionHighlight.bottom; }
        height: units.dp(2)
        color: UbuntuColors.orange
        visible: root.highlightShown
        antialiasing: true
    }

    Item {
        id: clipper
        anchors.fill: parent

        ApplicationWindow {
            id: applicationWindow
            objectName: application ? "appWindow_" + application.appId : "appWindow_null"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            width: root.windowWidth
            height: root.windowHeight
            interactive: false
            resizeSurface: false
            focus: false

            property real itemScale: 1
            transform: [
                Scale {
                    origin.x: 0; origin.y: 0
                    xScale: applicationWindow.itemScale
                    yScale: applicationWindow.itemScale
                }
            ]
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.highlightShown ? 0 : .1
        Behavior on opacity {
            UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
        }
    }
}
