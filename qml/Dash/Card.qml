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
    property var template
    property var components
    property var cardData

    property alias fontScale: header.fontScale
    property alias headerHeight: header.height

    property bool showHeader: true

    implicitWidth: childrenRect.width
    implicitHeight: summary.y + summary.height

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

    ShaderEffect {
        id: overlay
        anchors {
            left: artShape.left
            right: artShape.right
            bottom: artShape.bottom
        }

        height: units.gu(8)
        opacity: header.opacity * 0.6
        visible: template && template["overlay"] && artShape.visible && artShape.image.status === Image.Ready || false

        property var source: ShaderEffectSource {
            id: shaderSource
            sourceItem: artShape
            onVisibleChanged: if (visible) scheduleUpdate()
            live: false
            sourceRect: Qt.rect(0, artShape.height - overlay.height, artShape.width, overlay.height)
        }

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }"

        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            void main() {
                lowp vec4 tex = texture2D(source, coord);
                gl_FragColor = vec4(0, 0, 0, tex.a) * qt_Opacity;
            }"
    }

    CardHeader {
        id: header
        objectName: "cardHeader"
        anchors {
            top: {
                if (template) {
                    if (template["overlay"]) return overlay.top;
                    if (template["card-layout"] === "horizontal") return artShape.top;
                }
                return artShape.bottom;
            }
            left: {
                if (template) {
                    if (!template["overlay"] && template["card-layout"] === "horizontal") return artShape.right;
                }
                return parent.left;
            }
            right: parent.right
        }

        mascot: cardData && cardData["mascot"] || ""
        title: cardData && cardData["title"] || ""
        subtitle: cardData && cardData["subtitle"] || ""

        opacity: showHeader ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.SnapDuration } }
    }

    Label {
        id: summary
        objectName: "summaryLabel"
        anchors { top: header.visible ? header.bottom : artShape.bottom; left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        maximumLineCount: 5
        elide: Text.ElideRight
        text: cardData && cardData["summary"] || ""
        height: text ? implicitHeight : 0
        fontSize: "small"
    }
}
