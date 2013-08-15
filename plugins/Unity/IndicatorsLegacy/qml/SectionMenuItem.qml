/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

BasicMenuItem {
    property string label: menu && menu.label ? menu.label : ""
    property bool busy: false
    property int count: menu && menu.linkSection ?  menu.linkSection.count : 0

    color: "#221e1b"
    implicitHeight: label !== "" ? __header.height : 0
    state: count === 0 ? "EMPTY" : ""

    ListItem.Header {
        id: __header

        text: label
        height: units.gu(4)
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        visible: text != ""

        ActivityIndicator {
            id: indicator
            running: busy
            anchors {
                margins: units.gu(0.5)
                right: parent.right
            }
            height: parent.height - (anchors.margins * 2)
            width: height
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
