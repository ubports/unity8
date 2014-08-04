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

import QtQuick 2.2
import Ubuntu.Components 1.1

Item {
    id: root
    objectName: "dashNavigation"

    property var scope: null

    property alias windowWidth: blackRect.width
    property alias windowHeight: blackRect.height
    property var scopeStyle: null
    readonly property var openList: {
        if (navigationButton.showList) return navigationButton.listView;
        if (altNavigationButton.showList) return altNavigationButton.listView;
        return null;
    }

    visible: navigationButton.currentNavigation || altNavigationButton.currentNavigation

    height: visible ? units.gu(5) : 0

    Rectangle {
        id: blackRect
        color: "black"
        opacity: openList && openList.currentItem && openList.currentItem.visible ? 0.3 : 0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
        // Doesn't matter if navigationButton or altNavigationButton list, they are both at the same y
        y: navigationButton.listView.y
        anchors.right: parent.right
        visible: opacity != 0
    }

    Image {
        id: topGradient
        anchors.top: parent.top
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_lightgrad.png"
        z: -1

        readonly property bool bothVisible: navigationButton.visible & altNavigationButton.visible
        width: root.openList && bothVisible ? navigationButton.width : root.width
        x: !bothVisible ? 0 :
                    navigationButton.showList ? altNavigationButton.x :
                    altNavigationButton.showList ? navigationButton.x : 0
    }

    Image {
        anchors {
            bottom: parent.bottom
            left: topGradient.left
            right: topGradient.right
        }
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_darkgrad.png"
        z: -1
    }

    DashNavigationButton {
        id: altNavigationButton
        objectName: "altNavigationButton"
        height: root.height
        width: navigationButton.visible ? root.width / 2 : root.width
        scope: root.scope
        scopeStyle: root.scopeStyle
        listView.width: root.width
        isAltNavigation: true
    }

    DashNavigationButton {
        id: navigationButton
        objectName: "navigationButton"
        height: root.height
        width: altNavigationButton.visible ? root.width / 2 : root.width
        x: altNavigationButton.visible ? root.width / 2 : 0
        scope: root.scope
        scopeStyle: root.scopeStyle
        listView.width: root.width
        listView.x: -x
    }
}
