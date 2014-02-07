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

AbstractButton {
    id: root
    property var template
    property var components
    property var cardData

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    UbuntuShape {
        id: artShape
        radius: "medium"
        objectName: "artShape"
        width: {
            if (!visible) return 0
            return image.fillMode === Image.PreserveAspectCrop || aspect < image.aspect ? image.width : height * image.aspect
        }
        height: {
            if (!visible) return 0
            return image.fillMode === Image.PreserveAspectCrop || aspect > image.aspect ? image.height : width / image.aspect
        }
        anchors.horizontalCenter: template && template["card-layout"] === "horizontal" ? undefined : parent.horizontalCenter
        anchors.left: template && template["card-layout"] === "horizontal" ? parent.left : undefined
        visible: cardData && cardData["art"] || false

        property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1

        image: Image {
            width: template && template["card-layout"] === "horizontal" ? height * artShape.aspect : root.width
            height: template && template["card-layout"] === "horizontal" ? header.height : width / artShape.aspect
            objectName: "artImage"
            source: cardData && cardData["art"] || ""
            // FIXME uncomment when having investigated / fixed the crash
            //sourceSize.width: width > height ? width : 0
            //sourceSize.height: height > width ? height : 0
            fillMode: components && components["art"]["fill-mode"] === "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop

            property real aspect: implicitWidth / implicitHeight
        }
    }

    CardHeader {
        id: header
        objectName: "cardHeader"
        anchors {
            top: template && template["card-layout"] === "horizontal" ? artShape.top : artShape.bottom
            left: template && template["card-layout"] === "horizontal" ? artShape.right : parent.left
            right: parent.right
        }

        mascot: cardData && cardData["mascot"] || ""
        title: cardData && cardData["title"] || ""
        subtitle: cardData && cardData["subtitle"] || ""
    }

    Label {
        objectName: "summaryLabel"
        anchors { top: header.visible ? header.bottom : artShape.bottom; left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        maximumLineCount: 5
        elide: Text.ElideRight
        text: cardData && cardData["summary"] || ""
        height: text ? implicitHeight : 0
        fontSize: "small"
        // TODO karni (for each Label): Update Ubuntu.Components.Themes.Palette and use theme color instead
        color: "grey"
    }
}
