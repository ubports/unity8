/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../../Components/ListItems" as ListItems

Base {
    id: root
    highlightWhenPressed: false

    signal phoneClicked
    signal textClicked

    Row {
        height: phoneButton.height
        anchors {
            left: parent.left
            right: parent.right
        }
        AbstractButton {
            id: phoneButton
            width: parent.width - units.gu(7)
            height: Math.max(units.gu(8), phoneColumn.height + units.gu(2))
            Column {
                id: phoneColumn
                spacing: units.gu(0.5)
                anchors {
                    top: parent.top
                    topMargin: units.gu(1)
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                }
                Label {
                    text: {
                    var parts = []
                        if (location) parts.push(location)
                        if (type && type != "voice") parts.push(type)
                        if (parts.length == 0) return "other"
                        return parts.join(" ")
                    }
                    elide: Text.ElideRight
                    color: "#f3f3e7"
                    style: Text.Raised
                    styleColor: "black"
                    font.capitalization: Font.Capitalize
                    opacity: 0.7;
                    fontSize: "small"
                }
                Label {
                    width: parent.width
                    text: number
                    elide: Text.ElideRight
                    color: "#f3f3e7"
                    style: Text.Raised
                    styleColor: "black"
                    opacity: 0.9;
                    fontSize: "large"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    font.weight: Font.Light
                }
            }

            ListItems.Highlight {
                anchors.fill: parent
                pressed: phoneButton.pressed
            }

            onClicked: phoneClicked()
        }

        AbstractButton {
            id: textButton
            width: units.gu(7)
            height: parent.height

            Image {
                anchors.centerIn: parent
                width: units.gu(4)
                height: units.gu(4)
                source: "../graphics/icon_write_text.png"
                fillMode: Image.PreserveAspectFit
            }

            ListItems.Highlight {
                anchors.fill: parent
                pressed: textButton.pressed
            }

            onClicked: textClicked()
        }
    }
}
