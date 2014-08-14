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
import Dash 0.1
import "../Components"

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

    Background {
        id: background
        anchors.fill: parent
        style: scopeStyle ? scopeStyle.navigationBackground : "color:///f5f5f5"
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

    Rectangle {
        visible: navigationButton.visible && altNavigationButton.visible
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: navigationButton.left
            rightMargin: -units.dp(1)
        }
        width: units.dp(2)
        color: scopeStyle ? (background.luminance > scopeStyle.threshold ? scopeStyle.dark : scopeStyle.light) : Theme.palette.normal.baseText
        opacity: 0.3
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

    Image {
        id: dropShadow
        fillMode: Image.Stretch
        source: "graphics/navigation_shadow.png"

        readonly property bool bothVisible: navigationButton.visible & altNavigationButton.visible

        state: "default"

        states: [
            State {
                name: "default"
                when: !dropShadow.bothVisible || (!altNavigationButton.showList && !navigationButton.showList)
                PropertyChanges { target: dropShadow; width: root.width; x: 0; rotation: 0 }
                AnchorChanges { target: dropShadow; anchors.top: parent.bottom; anchors.bottom: undefined }
            },
            State {
                name: "open"
                PropertyChanges { target: dropShadow; width: navigationButton.width; rotation: 180 }
                AnchorChanges { target: dropShadow; anchors.bottom: parent.bottom; anchors.top: undefined }
            },
            State {
                name: "mainOpen"
                extend: "open"
                when: dropShadow.bothVisible && navigationButton.showList
                PropertyChanges { target: dropShadow; x: altNavigationButton.x }
            },
            State {
                name: "altOpen"
                extend: "open"
                when: dropShadow.bothVisible && altNavigationButton.showList
                PropertyChanges { target: dropShadow; x: navigationButton.x }
            }
        ]
    }
}
