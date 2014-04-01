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

    property real fontScale: 1.0
    property int headerAlignment: Text.AlignLeft
    readonly property int headerHeight: headerLoader.item ? headerLoader.item.height : 0
    property int fixedHeaderHeight: -1

    property bool showHeader: true

    implicitWidth: childrenRect.width
    implicitHeight: summary.y + summary.height + (summary.text && backgroundLoader.active ? units.gu(1) : 0)

    Loader {
        id: backgroundLoader
        objectName: "backgroundLoader"

        readonly property bool artAndSummary: components["art"]["field"] && components["summary"] || false
        active: template["card-layout"] !== "horizontal" && (template["card-background"] || components["background"] || artAndSummary)
        anchors.fill: parent

        sourceComponent: UbuntuShape {
            objectName: "background"
            radius: "medium"
            color: getColor(0) || "white"
            gradientColor: getColor(1) || color
            anchors.fill: parent
            image: backgroundImage.source ? backgroundImage : null

            property real luminance: 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b

            property Image backgroundImage: Image {
                objectName: "backgroundImage"
                source: {
                    if (cardData && typeof cardData["background"] === "string") return cardData["background"]
                    else if (template && typeof template["card-background"] === "string") return template["card-background"]
                    else return ""
                }
            }

            function getColor(index) {
                if (cardData && typeof cardData["background"] === "object"
                    && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) {
                    return cardData["background"]["elements"][index];
                } else if (template && typeof template["card-background"] === "object"
                        && (template["card-background"]["type"] === "color" || template["card-background"]["type"] === "gradient"))  {
                    return template["card-background"]["elements"][index];
                } else return undefined;
            }
        }
    }

    UbuntuShape {
        id: artShape
        radius: "medium"
        objectName: "artShape"
        anchors.horizontalCenter: template && template["card-layout"] === "horizontal" ? undefined : parent.horizontalCenter
        anchors.left: template && template["card-layout"] === "horizontal" ? parent.left : undefined
        visible: cardData && cardData["art"] || false

        readonly property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1
        readonly property bool aspectSmallerThanImageAspect: aspect < image.aspect

        Component.onCompleted: updateWidthHeightBindings();
        onAspectSmallerThanImageAspectChanged: updateWidthHeightBindings();

        function updateWidthHeightBindings() {
            if (aspectSmallerThanImageAspect) {
                width = Qt.binding(function() { return !visible ? 0 : image.width });
                height = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.height : width / image.aspect });
            } else {
                width = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.width : height * image.aspect });
                height = Qt.binding(function() { return !visible ? 0 : image.height });
            }
        }

        image: Image {
            objectName: "artImage"
            source: cardData && cardData["art"] || ""
            cache: true
            // FIXME uncomment when having investigated / fixed the crash
            //sourceSize.width: width > height ? width : 0
            //sourceSize.height: height > width ? height : 0
            fillMode: components && components["art"]["fill-mode"] === "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop

            readonly property real aspect: implicitWidth / implicitHeight
            readonly property bool isHorizontal: template && template["card-layout"] === "horizontal"

            Component.onCompleted: updateWidthHeightBindings();
            onIsHorizontalChanged: updateWidthHeightBindings();

            function updateWidthHeightBindings() {
                if (isHorizontal) {
                    width = Qt.binding(function() { return height * artShape.aspect });
                    height = Qt.binding(function() { return root.headerHeight });
                } else {
                    width = Qt.binding(function() { return root.width });
                    height = Qt.binding(function() { return width / artShape.aspect });
                }
            }
        }
    }

    Loader {
        id: overlayLoader
        anchors {
            left: artShape.left
            right: artShape.right
            bottom: artShape.bottom
        }
        active: template && template["overlay"] && artShape.visible && artShape.image.status === Image.Ready || false

        sourceComponent: ShaderEffect {
            id: overlay

            height: headerLoader.item.height
            opacity: headerLoader.item.opacity * 0.6

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
    }

    Loader {
        id: headerLoader
        objectName: "cardHeaderLoader"

        anchors {
            top: {
                if (template) {
                    if (template["overlay"]) return overlayLoader.top;
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
        active: cardData && cardData["title"] || cardData && cardData["mascot"] || false

        sourceComponent: CardHeader {
            id: header
            objectName: "cardHeader"

            mascot: cardData && cardData["mascot"] || ""
            title: cardData && cardData["title"] || ""
            subtitle: cardData && cardData["subtitle"] || ""

            titleWeight: components && components["subtitle"] ? Font.DemiBold : Font.Normal

            opacity: showHeader ? 1 : 0
            inOverlay: root.template && root.template["overlay"] === true
            fontColor: inOverlay ? "white" : summary.color
            useMascotShape: !backgroundLoader.active && !inOverlay
            headerAlignment: root.headerAlignment
            height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight

            Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.SnapDuration } }
        }
    }

    Label {
        id: summary
        objectName: "summaryLabel"
        anchors {
            top: headerLoader.active ? headerLoader.bottom : artShape.bottom
            left: parent.left
            right: parent.right
            margins: backgroundLoader.active ? units.gu(1) : 0
            topMargin: 0
        }
        wrapMode: Text.Wrap
        maximumLineCount: 5
        elide: Text.ElideRight
        text: cardData && cardData["summary"] || ""
        height: text ? implicitHeight : 0
        fontSize: "small"
        // TODO karni: Change "grey" to Ubuntu.Components.Palette color once updated.
        color: backgroundLoader.active && backgroundLoader.item.luminance < 0.7 ? "white" : "grey"
    }
}
