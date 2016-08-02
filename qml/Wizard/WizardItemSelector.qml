/*
 * Copyright (C) 2016 Canonical, Ltd.
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

Rectangle {
    id: optionToggle

    property bool expanded
    property var model
    property int selectedIndex: -1
    readonly property double itemHeight: units.gu(4)
    readonly property int maxVisibleItems: 6

    color: theme.palette.normal.foreground
    height: expanded ? maxVisibleItems * itemHeight : itemHeight
    Behavior on height {
        UbuntuNumberAnimation { id: heightAnimation }
    }

    width: parent.width
    radius: units.gu(0.6)
    clip: true
    border.width: units.dp(1)
    border.color: theme.palette.normal.base

    Flickable {
        id: flickable
        interactive: expanded
        flickableDirection: Flickable.VerticalFlick
        width: parent.width
        height: parent.height
        contentHeight: optionToggleRepeater.count * itemHeight

        Column {
            id: optionToggleContent
            width: parent.width

            Repeater {
                id: optionToggleRepeater
                model: optionToggle.model

                delegate: Loader {
                    asynchronous: true
                    visible: status === Loader.Ready

                    Component {
                        id: optionToggleEntry

                        AbstractButton {
                            width: optionToggleContent.width
                            height: optionToggle.itemHeight
                            onClicked: {
                                if (expanded) {
                                    selectedIndex = index;
                                }
                                expanded = !expanded
                            }

                            ListItem.ThinDivider {
                                visible: expanded && index != 0
                            }

                            Label {
                                id: delegateLabel
                                anchors {
                                    left: parent.left
                                    leftMargin: units.gu(1)
                                    right: parent.right
                                    rightMargin: units.gu(3)
                                    verticalCenter: parent.verticalCenter
                                }

                                width: parent.width
                                text: expanded ? modelData : optionToggle.model[selectedIndex]
                                color: textColor
                                font.weight: Font.Light
                                maximumLineCount: 1
                                elide: Text.ElideRight
                            }

                            Icon {
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(1)
                                    verticalCenter: parent.verticalCenter
                                }

                                visible: (index == 0 || !expanded) && !heightAnimation.running
                                name: expanded ? "up" : "down"
                                width: units.gu(1.5)
                                height: width
                            }

                            Image {
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(1)
                                    verticalCenter: parent.verticalCenter
                                }
                                visible: expanded && index == optionToggle.selectedIndex && index != 0
                                height: units.gu(1.5)
                                fillMode: Image.PreserveAspectFit
                                source: Qt.resolvedUrl("Pages/data/Tick@30.png")
                            }
                        }
                    }
                    sourceComponent: optionToggleEntry
                }
            }
        }
    }
}
