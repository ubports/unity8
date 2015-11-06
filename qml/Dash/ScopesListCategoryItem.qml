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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

MouseArea {
    id: root

    signal requestFavorite(string scopeId, bool favorite)
    signal handlePressed(var handle)
    signal handleReleased(var handle)

    property real topMargin: 0
    property alias icon: shapeImage.source
    property alias text: titleLabel.text
    property alias subtext: subtitleLabel.text

    property bool showStar: false
    property bool isFavorite: false
    property bool hideChildren: false

    Item {
        id: holder
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        UbuntuShape {
            id: shape
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            width: units.gu(5)
            height: units.gu(5)
            visible: !hideChildren
            sourceFillMode: UbuntuShape.PreserveAspectCrop
            source: Image {
                id: shapeImage
                cache: true
                sourceSize { width: shape.width; height: shape.height }
            }
        }

        ColumnLayout {
            visible: !hideChildren
            anchors {
                left: shape.right
                leftMargin: units.gu(1)
                right: starArea.left
                verticalCenter: parent.verticalCenter
            }
            Label {
                id: titleLabel
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 1
                verticalAlignment: Text.AlignHCenter
            }
            Label {
                id: subtitleLabel
                Layout.fillWidth: true
                elide: Text.ElideRight
                fontSize: "xx-small"
                wrapMode: Text.Wrap
                maximumLineCount: 1
                verticalAlignment: Text.AlignHCenter
                visible: text != ""
            }
        }
        MouseArea {
            id: starArea
            objectName: "starArea"
            height: parent.height
            width: height
            anchors.right: parent.right
            onClicked: if (!editMode) root.requestFavorite(model.scopeId, !isFavorite);
            onPressed: if (editMode) root.handlePressed(starArea);
            onReleased: if (editMode) root.handleReleased(starArea);
            visible: editMode || showStar
            Icon {
                id: star
                anchors.centerIn: parent
                height: units.gu(2)
                width: units.gu(2)
                visible: !hideChildren
                // TODO is view-grid-symbolic what we really want here? Looks good but seems semantically wrong
                source: editMode ? "image://theme/view-grid-symbolic" : isFavorite ? "image://theme/starred" : "image://theme/non-starred"
            }
        }
    }
}
