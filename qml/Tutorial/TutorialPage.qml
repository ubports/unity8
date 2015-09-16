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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "../Components"

Showable {
    id: root

    property alias arrow: arrow
    property alias label: label
    readonly property real margin: units.gu(2)

    signal finished()

    ////

    visible: false
    shown: false

    showAnimation: StandardAnimation {
        property: "opacity"
        from: 0
        to: 1
        duration: UbuntuAnimation.SleepyDuration
        onStarted: root.visible = true
    }

    hideAnimation: StandardAnimation {
        property: "opacity"
        to: 0
        duration: UbuntuAnimation.BriskDuration
        onStopped: {
            root.visible = false;
            root.finished();
        }
    }

    MouseArea { // eat any errant presses
        id: mouseArea
        anchors.fill: parent
    }

    Image {
        // Use x/y/height/width instead of anchors so that we don't adjust
        // the image if the OSK appears.
        x: 0
        y: 0
        height: root.height
        width: root.width
        sourceSize.height: 1080
        sourceSize.width: 1916
        source: Qt.resolvedUrl("graphics/background.png")
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        id: arrow
        anchors.margins: root.margin
        width: units.gu(1)
        sourceSize.height: 106
        sourceSize.width: 34
        source: Qt.resolvedUrl("graphics/arrow.png")
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: label
        anchors.margins: root.margin
        fontSize: "large"
        font.weight: Font.Light
        color: "#333333"
        wrapMode: Text.Wrap
    }
}
