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
import "../Components"

Item {
    id: root
    property var navigation: null
    property var currentNavigation: null
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
                delegate: ListItem {
                    objectName: root.objectName + "child" + index
                    height: root.itemHeight
                    width: column.width
                    anchors {
                        left: column.left
                        right: column.right
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(2)
                    }

                    onClicked: root.enterNavigation(navigationId, allLabel != "" ? allLabel : label, hasChildren)

                    Icon {
                        id: leftIcon
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                        }
                        height: units.gu(2)
                        width: height
                        name: "tick"
                        color: "#3EB34F"
                        visible: isActive
                    }

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: leftIcon.right
                            leftMargin: units.gu(1)
                            right: rightIcon.left
                            rightMargin: units.gu(2)
                        }
                        text: label
                        color: isActive ? "#333333" : "#888888"
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideMiddle
                    }

                    Icon {
                        id: rightIcon
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                        height: units.gu(2)
                        width: height
                        name: "go-next"
                        visible: hasChildren
                    }

                    divider.visible: index != navigation.count - 1
                }
            }
        }
    }
}
