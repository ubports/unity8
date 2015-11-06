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
        return null;
    }
    readonly property bool disableParentInteractive: {
        return navigationButton.showList || navigationButton.inverseMousePressed;
    }

    // FIXME this is only here for highlight purposes (see Background.qml, too)
    readonly property var background: backgroundItem

    visible: height != 0
    height: navigationButton.currentNavigation ? units.gu(5) : 0

    QtObject {
        id: d
        readonly property color foregroundColor: root.scopeStyle
                                                 ? root.scopeStyle.getTextColor(backgroundItem.luminance)
                                                 : theme.palette.normal.baseText
        readonly property real navigationWidth: root.width >= units.gu(60) ? units.gu(40) : root.width
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
        id: navigationButton
        objectName: "navigationButton"
        height: root.height
        width: d.navigationWidth
        scope: root.scope
        scopeStyle: root.scopeStyle
        foregroundColor: d.foregroundColor
        listView.width: d.navigationWidth
        listView.x: -x
        showDivider: root.width > d.navigationWidth
    }
}
