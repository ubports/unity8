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

Rectangle {
    id: root

    property int keyboardSize: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
    property var previewData

    property real previewWidthRatio: 0.5

    property Component header
    property Component title
    property Component buttons
    property Component body

    readonly property bool narrowMode: width <= height
    readonly property int contentSpacing: units.gu(3)

    signal close()
    signal previewImageClicked()

    color: Qt.rgba(0, 0, 0, .3)
    clip: true

    function ensureVisible(item) {
        var o = leftFlickable.mapFromItem(item, 0, 0, item.width, item.height);
        var keyboardY = shell.height - root.keyboardSize;
        if ((o.y + o.height) > keyboardY) {
            leftFlickable.contentY += o.y + o.height - keyboardY;
        }
    }

    Connections {
        target: shell.applicationManager
        onMainStageFocusedApplicationChanged: {
            root.close();
        }
        onSideStageFocusedApplicationChanged: {
            root.close();
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Item {
        id: headerIcon
        height: childrenRect.height
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: root.contentSpacing
            topMargin: root.contentSpacing
            rightMargin: root.contentSpacing
        }
        Loader {
            id: headerLoader
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: root.header
        }
    }

    Item {
        id: headerRow
        height: childrenRect.height
        anchors {
            top: headerIcon.bottom
            left: parent.left
            right: parent.right
            leftMargin: root.contentSpacing
            rightMargin: root.contentSpacing
        }
        Loader {
            id: titleLoader
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: root.title
        }
    }

    Row {
        id: contentRow
        anchors {
            left: parent.left
            right: parent.right
            top: headerRow.bottom
            bottom: parent.bottom
            topMargin: root.contentSpacing
            leftMargin: root.contentSpacing
            rightMargin: root.contentSpacing
        }

        spacing: units.gu(2)

        Flickable {
            id: leftFlickable
            objectName: "leftFlickable"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.narrowMode ? contentRow.width : contentRow.width * root.previewWidthRatio
            contentHeight: leftColumn.height
            anchors.bottomMargin: root.keyboardSize
            clip: true

            Behavior on contentY { NumberAnimation { duration: 300 } }

            Column {
                id: leftColumn
                objectName: "leftColumn"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height
                spacing: units.gu(1)

                Loader {
                    id: buttonLoader
                    anchors.left: parent.left
                    anchors.right: parent.right
                    sourceComponent: root.buttons
                }
            }
        }

        Flickable {
            id: rightFlickable
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: narrowMode ? 0 : (contentRow.width - leftColumn.width - contentRow.spacing)
            contentHeight: rightColumn.height
            clip: true

            Column {
                id: rightColumn
                objectName: "rightColumn"
                height: childrenRect.height
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }

    Loader {
        parent: root.narrowMode ? leftColumn : rightColumn
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent: root.body
    }
}
