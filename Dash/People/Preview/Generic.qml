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

Base {
    id: root

    property string type

    Item {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: units.gu(2)
            rightMargin: units.gu(4)
        }
        height: childrenRect.height + units.gu(2.5)

        Label {
            id: typeLabel
            anchors {
                top: parent.top
                topMargin: units.gu(1)
            }
            text: switch (root.type) {
                case "email":
                case "address": type; break
                case "imAccount": protocol; break
                default: type
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
            id: contentLabel
            anchors {
                left: parent.left
                right: parent.right
                top: typeLabel.bottom
                topMargin: units.gu(0.5)
            }
            text: switch (root.type) {
                case "email":
                case "address":
                case "imAccount": address; break
                default: text
            }
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
}
