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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1

MouseArea {
    signal requestFavorite(string scopeId, bool favorite)

    property alias icon: shapeImage.source
    property alias text: titleLabel.text
    property alias subtext: subtitleLabel.text
    property alias showStar: star.visible

    property bool isFavorite: false
    property bool hideChildren: false

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
        image: Image {
            id: shapeImage
            cache: true
            fillMode: Image.PreserveAspectCrop
        }
    }

    ColumnLayout {
        visible: !hideChildren
        anchors {
            left: shape.right
            leftMargin: units.gu(1)
            right: starArea.right
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        Label {
            id: titleLabel
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 1
            verticalAlignment: Text.AlignHCenter
        }
        Label {
            id: subtitleLabel
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
        height: parent.height
        width: height
        anchors.right: parent.right
        enabled: !editMode
        visible: !hideChildren
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
