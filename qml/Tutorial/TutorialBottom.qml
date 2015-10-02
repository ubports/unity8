/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "." as LocalComponents

TutorialPage {
    id: root

    background {
        sourceSize.height: 1080
        sourceSize.width: 1916
        source: Qt.resolvedUrl("graphics/background2.png")
        rotation: 180
    }

    arrow {
        anchors.bottom: root.bottom
        anchors.bottomMargin: units.gu(4)
        anchors.horizontalCenter: root.horizontalCenter
        rotation: -90
    }

    label {
        text: i18n.tr("Swipe from the bottom edge to manage the app")
        anchors.bottom: arrow.top
        anchors.bottomMargin: units.gu(3)
        anchors.horizontalCenter: root.horizontalCenter
        anchors.horizontalCenterOffset: (label.width - label.contentWidth) / 2
        width: root.width - units.gu(8)
    }

    /*DirectionalDragArea {
        direction: Direction.Upwards
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.gu(1)
    }*/
}
