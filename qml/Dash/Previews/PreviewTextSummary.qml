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
import "../../Components"

/*! \brief Preview widget for text.

    This widget shows text contained in widgetData["text"]
    along with a title that comes from widgetData["title"].

    In case the widget is collapsed it only shows 3 lines of text.
 */

PreviewWidget {
    id: root
    implicitHeight: childrenRect.height

    Label {
        id: titleLabel
        objectName: "titleLabel"
        anchors {
            left: parent.left
            right: parent.right
        }
        height: visible ? implicitHeight : 0
        fontSize: "large"
        color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
        visible: text !== ""
        opacity: .8
        text: widgetData["title"] || ""
        wrapMode: Text.Wrap
    }

    Label {
        id: textLabel
        objectName: "textLabel"

        readonly property int maximumCollapsedLineCount: 3

        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.visible ? titleLabel.bottom : parent.top
        }
        height: (lineCount <= maximumCollapsedLineCount || root.expanded) ? contentHeight : contentHeight / lineCount * maximumCollapsedLineCount
        clip: true
        fontSize: "small"
        lineHeight: 1.2
        color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
        opacity: .8
        text: widgetData["text"] || ""
        wrapMode: Text.Wrap

        Behavior on height {
            UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
        }
    }
}
