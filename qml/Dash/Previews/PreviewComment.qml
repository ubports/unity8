/*
 * Copyright (C) 2015 Canonical, Ltd.
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

/*! \brief Preview widget for comments.

    This widget shows an (optional) avatar contained in widgetData["source"]
    along with a label that comes from widgetData["author"],
    a (optional) subtitle from widgetData["subtitle"] and the comment widgetData["comment"].
*/

PreviewWidget {
    id: root
    implicitHeight: Math.max(avatar.height, column.implicitHeight)

    UbuntuShape {
        id: avatar
        objectName: "avatar"
        anchors {
            left: parent.left
            top: parent.top
        }
        width: units.gu(6)
        height: width
        source: Image {
            source: widgetData["source"]
        }
        radius: "medium"
        opacity: source.status === Image.Ready ? 1 : 0
        visible: widgetData["source"] !== ""
    }

    Column {
        id: column
        objectName: "column"
        anchors {
            left: avatar.visible ? avatar.right : parent.left
            right: parent.right
            top: parent.top
            topMargin: units.gu(0.5)
            leftMargin: avatar.visible ? units.gu(1) : 0
        }
        spacing: units.gu(0.24)

        Label {
            width: parent.width
            text: widgetData["author"] || ""
            fontSize: "small"
            maximumLineCount: 1
            elide: Text.ElideRight
        }
        Label {
            objectName: "subtitle"
            width: parent.width
            visible: text !== ""
            text: widgetData["subtitle"] || ""
            fontSize: "xx-small"
            maximumLineCount: 1
            elide: Text.ElideRight
        }
        Label {
            width: parent.width
            text: widgetData["comment"] || ""
            fontSize: "small"
            wrapMode: Text.Wrap
        }
    }
}
