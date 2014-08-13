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

import QtQuick 2.3
import Ubuntu.Components 0.1

Item {
    id: root

    property int currentTab: 0

    AbstractButton {
        id: tab1
        height: parent.height
        width: parent.width / 2
        Rectangle {
            anchors.fill: parent
            color: root.currentTab == 0 && root.enabled ? "white" : "transparent"
            radius: units.dp(10)
        }
        Label {
            anchors.centerIn: parent
            text: i18n.tr("Favorites")
            color: root.currentTab == 0 && root.enabled ? "black" : "white"
        }
        onClicked: root.currentTab = 0
    }
    AbstractButton {
        id: tab2
        objectName: "scopesOverviewAllTabButton"
        x: width
        height: parent.height
        width: parent.width / 2
        Rectangle {
            anchors.fill: parent
            color: root.currentTab == 1 && root.enabled ? "white" : "transparent"
            radius: units.dp(10)
        }
        Label {
            anchors.centerIn: parent
            text: i18n.tr("All")
            color: root.currentTab == 1 && root.enabled ? "black" : "white"
        }
        onClicked: root.currentTab = 1
    }
    Rectangle {
        id: centerPiece
        width: root.enabled ? units.dp(10) : units.dp(1)
        height: parent.height
        color: "white"
        x: root.currentTab == 1 ? tab2.x : tab2.x - width
    }
    Rectangle {
        id: border
        anchors.fill: parent
        radius: units.dp(10)
        color: "transparent"
        border.color: centerPiece.color
        border.width: units.dp(1)
    }
}
