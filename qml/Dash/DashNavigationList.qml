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
import Ubuntu.Components.ListItems 1.3 as ListItem
import "../Components"

Item {
    id: root
    property real itemsIndent: 0
    property var navigation: null
    property var currentNavigation: null
    property var scopeStyle: null
    property color foregroundColor: theme.palette.normal.baseText
    signal enterNavigation(var newNavigationId, string newNavigationLabel, bool hasChildren)

    readonly property int itemHeight: units.gu(5)
    implicitHeight: flickable.contentHeight

    clip: true

    Behavior on height {
        UbuntuNumberAnimation {
            id: heightAnimation
            duration: UbuntuAnimation.SnapDuration
        }
    }

    Flickable {
        id: flickable

        anchors.fill: parent

        flickableDirection: Flickable.VerticalFlick
        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            Repeater {
                model: navigation && navigation.loaded ? navigation : null
                clip: true
                delegate: ListItem.Standard {
                    objectName: root.objectName + "child" + index
                    height: root.itemHeight
                    showDivider: index != navigation.count - 1
                    selected: isActive
                    anchors.left: parent.left
                    anchors.leftMargin: itemsIndent
                    anchors.right: parent.right

                    onClicked: root.enterNavigation(navigationId, allLabel != "" ? allLabel : label, hasChildren)

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: itemsIndent > 0 ? 0 : units.gu(2)
                            right: rightIcon.visible ? rightIcon.left : parent.right
                            rightMargin: rightIcon.visible ? units.gu(0.5) : units.gu(2)
                        }
                        text: label
                        color: root.foregroundColor
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideMiddle
                    }

                    Icon {
                        id: rightIcon
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(2)
                        }
                        height: units.gu(2)
                        width: height
                        name: hasChildren ? "go-next" : "tick"
                        color: root.foregroundColor
                        visible: hasChildren || isActive
                    }
                }
            }
        }
    }
}
