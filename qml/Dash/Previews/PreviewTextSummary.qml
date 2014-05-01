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

/*! \brief Preview widget for text.

    This widget shows text contained in widgetData["text"]
    along with a title that comes from widgetData["title"].

    In case the text does not fit in 7 lines a See More / Less widget is also shown.
 */

PreviewWidget {
    id: root
    implicitHeight: column.height

    Column {
        id: column
        anchors { left: parent.left; right: parent.right; }

        Label {
            id: titleLabel
            objectName: "titleLabel"
            anchors { left: parent.left; right: parent.right }
            fontSize: "large"
            // TODO karni: Yet another fix requiring Palette update.
            color: "grey" //Theme.palette.selected.backgroundText
            visible: text !== ""
            opacity: .8
            text: widgetData["title"] || ""
            wrapMode: Text.Wrap
        }

        Label {
            id: textLabel
            objectName: "textLabel"

            readonly property int maximumCollapsedLineCount: 7

            anchors { left: parent.left; right: parent.right }
            height: (!seeMoreContainer.visible || seeMore.more) ? contentHeight : contentHeight / lineCount * (maximumCollapsedLineCount - 2)
            clip: true
            fontSize: "small"
            lineHeight: 1.2
            // TODO karni: Yet another fix requiring Palette update.
            color: "grey" //Theme.palette.selected.backgroundText
            opacity: .8
            text: widgetData["text"]
            wrapMode: Text.Wrap

            Behavior on height {
                UbuntuNumberAnimation {}
            }
        }

        Item {
            id: seeMoreContainer
            objectName: "seeMoreContainer"
            anchors { left: parent.left; right: parent.right }
            height: seeMore.height
            visible: textLabel.lineCount > textLabel.maximumCollapsedLineCount

            SeeMore {
                id: seeMore
                objectName: "seeMore"
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: units.gu(1)
                }
            }
        }
    }
}
