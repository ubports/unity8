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
import Ubuntu.Components 1.1

MouseArea {
    signal requestFavorite(string scopeId, bool favorite)

    property alias icon: shapeImage.source
    property alias text: titleLabel.text
    property alias showStar: star.visible

    property bool isFavorite: false

    UbuntuShape {
        id: shape
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(5)
        height: units.gu(5)
        image: Image {
            id: shapeImage
            cache: true
            fillMode: Image.PreserveAspectCrop
        }
    }
    Label {
        id: titleLabel
        anchors {
            left: shape.right
            leftMargin: units.gu(1)
            right: starArea.right
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 1
        verticalAlignment: Text.AlignHCenter
    }
    MouseArea {
        id: starArea
        height: parent.height
        width: height
        anchors.right: parent.right
        enabled: !editMode
        onClicked: root.requestFavorite(model.scopeId, !isFavorite);
        Icon {
            id: star
            anchors.centerIn: parent
            height: units.gu(2)
            width: units.gu(2)
            // TODO is view-grid-symbolic what we really want here? Looks good but seems semantically wrong
            source: editMode ? "image://theme/view-grid-symbolic" : isFavorite ? "image://theme/starred" : "image://theme/non-starred"
        }
    }
}
