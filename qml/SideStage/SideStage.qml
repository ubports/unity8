/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Unity.Application 0.1
import Ubuntu.Components 0.1
import "../Components"

Stage {
    id: stage

    type: ApplicationInfo.SideStage
    property real handleSizeCollapsed: units.gu(2.5)
    property real handleSizeExpanded: units.gu(4)
    property bool handleExpanded

    /* FIXME: workaround so that when a main stage app goes fullscreen
       the sidestage's top is not transparent. Proper fix would be to
       resize the side stage app.
    */
    Rectangle {
        id: backgroundBeneathPanel
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: shell.panelHeight
        color: background.color
        z: -1
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2c2924"
        z: -1
        visible: stage.usingScreenshots
    }

    SidestageHandle {
        id: handle
        objectName: "sideStageHandle"

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: -width
        }
        width: handleExpanded ? handleSizeExpanded : handleSizeCollapsed
        Behavior on width { NumberAnimation { easing.type: Easing.OutQuart} }
        z: -1
    }

    InputFilterArea {
        anchors.fill: handle
        blockInput: visible
    }
}
