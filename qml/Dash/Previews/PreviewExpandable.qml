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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "../../Components"

/*! \brief Preview widget for expandable widgets.

    This widget shows a list of widgets defined in widgetData["widgets"]
    Those widgets can be collapsed or uncollapsed. When uncollapsed
    all the widgets are shown, when collapsed only the first
    widgetData["collapsed-widgets"] are shown. It has a title that comes
    in via widgetData["title"]
 */

PreviewWidget {
    id: root
    implicitHeight: childrenRect.height

    expanded: false

    Label {
        id: titleLabel
        objectName: "titleLabel"
        anchors {
            left: parent.left
            right: expandButton.left
        }
        fontSize: "large"
        color: root.scopeStyle ? root.scopeStyle.foreground : "grey"
        visible: text !== ""
        opacity: .8
        text: widgetData["title"] || ""
        wrapMode: Text.Wrap
    }

    AbstractButton {
        id: expandButton
        objectName: "expandButton"
        width: titleLabel.height
        height: titleLabel.height
        anchors.right: parent.right
        onClicked: {
            root.expanded = !root.expanded;
        }
        Icon {
            anchors.fill: parent
            width: 64
            height: 64
            name: root.expanded ? "view-collapse" : "view-expand"
        }
    }

    Column {
        anchors {
            top: titleLabel.bottom
            topMargin: units.gu(1)
            left: parent.left
            right: parent.right
        }
        spacing: units.gu(1)
        Repeater {
            id: repeater
            objectName: "repeater"
            model: widgetData["widgets"]
            delegate: PreviewWidgetFactory {
                height: visible ? implicitHeight : 0
                width: parent.width
                widgetId: modelData.widgetId
                widgetType: modelData.type
                widgetData: modelData.properties
                isCurrentPreview: root.isCurrentPreview
                scopeStyle: root.scopeStyle
                anchors {
                    left: parent.left
                    right: parent.right
                }
                expanded: root.expanded
                visible: root.expanded || index < root.widgetData["collapsed-widgets"]

                onTriggered: {
                    root.triggered(widgetId, actionId, data);
                }
            }
        }
    }
}
