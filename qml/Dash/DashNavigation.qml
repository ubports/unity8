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
import Dash 0.1
import "../Components"

Item {
    id: root
    objectName: "dashNavigation"

    property var scope: null
    property var scopeStyle: null

    property alias windowWidth: blackRect.width
    property alias windowHeight: blackRect.height
    readonly property var openList: {
        if (navigationButton.showList) return navigationButton.listView;
        if (altNavigationButton.showList) return altNavigationButton.listView;
        return null;
    }
    readonly property bool disableParentInteractive: {
        return navigationButton.showList || altNavigationButton.showList ||
               navigationButton.inverseMousePressed || altNavigationButton.inverseMousePressed;
    }

    // FIXME this is only here for highlight purposes (see Background.qml, too)
    readonly property var background: backgroundItem

    visible: height != 0
    height: navigationButton.currentNavigation || altNavigationButton.currentNavigation ? units.gu(5) : 0

    QtObject {
        id: d
        readonly property color foregroundColor: root.scopeStyle
                                                 ? root.scopeStyle.getTextColor(backgroundItem.luminance)
                                                 : theme.palette.normal.baseText
        readonly property bool bothVisible: altNavigationButton.visible && navigationButton.visible
        readonly property real navigationWidth: root.width >= units.gu(60) ? units.gu(40) : root.width
        readonly property real buttonWidth: navigationWidth / (bothVisible ? 2 : 1)
    }

    Rectangle {
        id: blackRect
        objectName: "blackRect"
        color: "black"
        opacity: openList && openList.currentItem && openList.currentItem.visible ? 0.5 : 0
        Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
        anchors { left: parent.left; right: parent.right }
        visible: opacity > 0
    }

    Background {
        id: backgroundItem
        anchors.fill: parent
        style: scopeStyle ? scopeStyle.navigationBackground : "color:///#f5f5f5"
    }

    Image {
        fillMode: Image.Stretch
        source: scopeStyle.backgroundLuminance > 0.2 ? "graphics/navigation_shadow.png" : "graphics/navigation_shadow_light.png"
        anchors { top: parent.bottom; left: parent.left; right: parent.right }
    }

    DashNavigationButton {
        id: altNavigationButton
        objectName: "altNavigationButton"
        height: root.height
        width: d.buttonWidth
        scope: root.scope
        scopeStyle: root.scopeStyle
        foregroundColor: d.foregroundColor
        listView.width: d.navigationWidth
        isAltNavigation: true
        showDivider: navigationButton.visible || root.width > d.navigationWidth
        // needed so that InverseMouseArea is above navigationButton
        z: listView.height > 0 ? 1 : 0
    }

    DashNavigationButton {
        id: navigationButton
        objectName: "navigationButton"
        height: root.height
        width: altNavigationButton.visible ? d.buttonWidth : d.navigationWidth
        x: altNavigationButton.visible ? d.buttonWidth : 0
        scope: root.scope
        scopeStyle: root.scopeStyle
        foregroundColor: d.foregroundColor
        listView.width: d.navigationWidth
        listView.x: -x
        showDivider: root.width > d.navigationWidth
    }

    Image {
        fillMode: Image.Stretch
        source: backgroundItem.luminance > 0.7 ? "graphics/navigation_shadow.png" : "graphics/navigation_shadow_light.png"
        x: navigationButton.listView.height > 0 ? altNavigationButton.x : navigationButton.x
        width: d.buttonWidth
        rotation: 180
        anchors.bottom: parent.bottom
        visible: d.bothVisible && (navigationButton.listView.height > 0 || altNavigationButton.listView.height > 0)
    }
}
