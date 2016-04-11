/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3

Rectangle {
    id: optionToggle

    property bool expanded
    property var model
    property int startIndex
    readonly property double itemHeight: units.gu(4)

    signal triggered(string id)

    color: theme.palette.normal.background
    height: expanded ? (optionToggleRepeater.count - startIndex) * itemHeight : itemHeight
    width: parent.width
    radius: units.gu(0.6)
    clip: true
    border.width: units.dp(1)
    border.color: theme.palette.normal.base

    Column {
        id: optionToggleContent
        width: parent.width

        Repeater {
            id: optionToggleRepeater
            model: optionToggle.model

            delegate: Loader {
                asynchronous: true
                visible: status === Loader.Ready
                property string actionLabel: label
                property string actionId: id
                readonly property var splitLabel: actionLabel.match(/(^([-a-z0-9]+):)?(.*)$/)

                Component {
                    id: optionToggleEntry

                    AbstractButton {
                        objectName: "notify_button" + index
                        width: optionToggleContent.width
                        height: optionToggle.itemHeight

                        onClicked: {
                            if (index === startIndex) {
                                optionToggle.expanded = !optionToggle.expanded
                            } else {
                                optionToggle.triggered(actionId)
                            }
                        }

                        ListItem.ThinDivider {
                            visible: index > startIndex
                        }

                        Icon {
                            id: delegateIcon
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(1)
                                verticalCenter: parent.verticalCenter
                            }
                            visible: index !== startIndex
                            width: units.gu(2)
                            height: width
                            name: splitLabel[2] !== undefined ? splitLabel[2] : ""
                        }

                        Label {
                            id: delegateLabel
                            anchors {
                                left: delegateIcon.visible ? delegateIcon.right : parent.left
                                leftMargin: delegateIcon.visible ? units.gu(1) : units.gu(2)
                                right: parent.right
                                rightMargin: units.gu(1)
                                verticalCenter: delegateIcon.visible ? delegateIcon.verticalCenter : parent.verticalCenter
                            }

                            width: parent.width
                            text: splitLabel[3]
                            color: theme.palette.normal.backgroundSecondaryText
                            fontSize: "small"
                            font.weight: Font.Light
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }

                        Icon {
                            anchors {
                                right: parent.right
                                rightMargin: units.gu(1)
                                verticalCenter: delegateIcon.verticalCenter
                            }

                            visible: index === startIndex
                            name: optionToggle.height === optionToggle.itemHeight ? "down" : "up"
                            width: units.gu(2)
                            height: width
                        }
                    }
                }
                sourceComponent: (index >= startIndex) ? optionToggleEntry : undefined
            }
        }
    }
}
