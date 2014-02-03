/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import "../../Components"

PreviewWidget {
    id: root
    implicitHeight: titleLabel.visible ? titleLabel.height + textLabel.height : textLabel.height

    Label {
        id: titleLabel
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        fontSize: "large"
        color: Theme.palette.selected.backgroundText
        visible: text !== ""
        opacity: .8
        text: widgetData["title"]
        wrapMode: Text.Wrap
    }

    Label {
        id: textLabel
        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.visible ? titleLabel.bottom : parent.top
        }
        fontSize: "medium"
        color: Theme.palette.selected.backgroundText
        opacity: .8
        text: widgetData["text"]
        wrapMode: Text.Wrap

        clip: true
        Behavior on height {
            NumberAnimation { duration: 300 }
        }

        height: seeMore.more ? contentHeight : contentHeight / lineCount * 5
    }

    SeeMore {
        id: seeMore
        anchors {
            left: parent.left
            right: parent.right
            top: textLabel.bottom
            topMargin: units.gu(2)
        }
    }
}
