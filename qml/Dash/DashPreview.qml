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

Item {
    id: root

    property int keyboardSize: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
    property var previewData
    property alias showProcessingAction: waitingForActionMouseArea.enabled

    property real previewWidthRatio: 0.5
    property bool isCurrent: false

    property Component previewImages
    property Component header
    property Component actions
    property Component description
    property Component ratings

    readonly property bool narrowMode: width <= height * 1.5
    readonly property int columnWidth: narrowMode ? contentRow.width : (contentRow.width / 3) - contentRow.spacing
    readonly property int contentSpacing: units.gu(3)

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

    onPreviewDataChanged: showProcessingAction = false

    MouseArea {
        anchors.fill: parent
    }

    Row {
        id: contentRow
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: root.contentSpacing
            leftMargin: root.contentSpacing
            rightMargin: root.contentSpacing
        }
        height: childrenRect.height

        spacing: units.gu(2)


        Flickable {
            id: leftFlickable
            objectName: "leftFlickable"
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: root.columnWidth
            contentHeight: leftColumn.height + root.contentSpacing
            anchors.bottomMargin: root.keyboardSize
            clip: true

            Behavior on contentY { NumberAnimation { duration: 300 } }

            Column {
                id: leftColumn
                objectName: "leftColumn"
                height: childrenRect.height
                spacing: root.contentSpacing
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
        }

        Flickable {
            id: centerFlickable
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: root.columnWidth
            contentHeight: centerColumn.height
            clip: true

            Column {
                id: centerColumn
                objectName: "centerColumn"
                height: childrenRect.height
                anchors {
                    left: parent.left
                    right: parent.right
                }
                spacing: root.contentSpacing
            }
        }

        Flickable {
            id: rightFlickable
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: root.columnWidth
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
        id: previewImageLoader
        parent: leftColumn
        sourceComponent: root.previewImages
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    Loader {
        id: ratingsLoader
        parent: root.narrowMode ? leftColumn : rightColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        sourceComponent: root.ratings
    }

    Loader {
        id: descriptionLoader
        parent: root.narrowMode ? leftColumn : centerColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        sourceComponent: root.description
    }

    Loader {
        id: actionsLoader
        parent: root.narrowMode ? leftColumn : centerColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        sourceComponent: root.actions
    }

    Loader {
        id: headerLoader
        parent: root.narrowMode ? leftColumn : centerColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        sourceComponent: root.header
    }

    MouseArea {
        id: waitingForActionMouseArea
        objectName: "waitingForActionMouseArea"
        anchors.fill: parent
        enabled: false
    }
}
