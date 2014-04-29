
.pragma library

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

.pragma library

function createCardComponent(parent, template, components, asynchronous) {
    var imports = 'import QtQuick 2.2; \
                   import Ubuntu.Components 0.1; \
                   import Ubuntu.Thumbnailer 0.1;';
    var code;
    code = 'AbstractButton { \
                clip: true; \
                id: root; \
                property var template; \
                property var components; \
                property var cardData; \
                property real fontScale: 1.0; \
                property int headerAlignment: Text.AlignLeft; \
                property size fixedArtShapeSize: Qt.size(-1, -1); \
                readonly property string title: cardData && cardData["title"] || ""; \
                property bool asynchronous: ' + asynchronous + '; \
                property bool showHeader: true; \
                implicitWidth: childrenRect.width; ';

    var hasArt = components["art"]["field"];
    var hasSummary = components["summary"] || false;
    var artAndSummary = hasArt && hasSummary;
    var isHorizontal = template["card-layout"] === "horizontal";
    var hasBackground = !isHorizontal && (template["card-background"] || components["background"] || artAndSummary);
    var inOverlay = hasArt && template && template["overlay"] === true;
    var hasTitle = components["title"] || false;
    var hasMascot = components["mascot"] || false;
    var hasSubtitle = components["subtitle"] || false;
    var mascotImageHeight = 'units.gu(5.625)';

    if (hasBackground) {
        code += 'Loader {\
                    id: backgroundLoader; \
                    objectName: "backgroundLoader"; \
                    anchors.fill: parent; \
                    asynchronous: root.asynchronous; \
                    visible: status == Loader.Ready; \
                    sourceComponent: UbuntuShape { \
                        objectName: "background"; \
                        radius: "medium"; \
                        color: getColor(0) || "white"; \
                        gradientColor: getColor(1) || color; \
                        anchors.fill: parent; \
                        image: backgroundImage.source ? backgroundImage : null; \
                        property real luminance: 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b; \
                        property Image backgroundImage: Image { \
                            objectName: "backgroundImage"; \
                            source: { \
                                if (cardData && typeof cardData["background"] === "string") return cardData["background"]; \
                                else if (template && typeof template["card-background"] === "string") return template["card-background"]; \
                                else return ""; \
                            } \
                        } \
                        function getColor(index) { \
                            if (cardData && typeof cardData["background"] === "object" \
                                && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { \
                                return cardData["background"]["elements"][index]; \
                            } else if (template && typeof template["card-background"] === "object" \
                                    && (template["card-background"]["type"] === "color" || template["card-background"]["type"] === "gradient"))  { \
                                return template["card-background"]["elements"][index]; \
                            } else return undefined; \
                        } \
                    } \
                }';
    }

    if (hasArt) {
        code += 'readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);'
        var imageWidthHeight;
        if (isHorizontal) {
            if (hasMascot) {
                imageWidthHeight = 'width: height * artShape.aspect; \
                                    height: mascotImage.height + 2 * units.gu(1);'
            } else {
                imageWidthHeight = 'width: height * artShape.aspect; \
                                    height: ' + mascotImageHeight + ' + 2 * units.gu(1);'
            }
        } else {
            imageWidthHeight = 'width: root.width; \
                                height: width / artShape.aspect;'
        }
        code += 'Item  { \
                    id: artShapeHolder; \
                    height: root.fixedArtShapeSize.height != -1 ? root.fixedArtShapeSize.height : artShapeLoader.height; \
                    width: root.fixedArtShapeSize.width != -1 ? root.fixedArtShapeSize.width : artShapeLoader.width; \
                    ' + (isHorizontal ? 'anchors.left: parent.left;' : 'anchors.horizontalCenter: parent.horizontalCenter;' ) + '\
                    Loader { \
                        id: artShapeLoader; \
                        objectName: "artShapeLoader"; \
                        active: cardData && cardData["art"] || false; \
                        asynchronous: root.asynchronous; \
                        visible: status == Loader.Ready; \
                        sourceComponent: UbuntuShape { \
                            id: artShape; \
                            radius: "medium"; \
                            readonly property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1; \
                            readonly property bool aspectSmallerThanImageAspect: aspect < image.aspect; \
                            Component.onCompleted: updateWidthHeightBindings(); \
                            onAspectSmallerThanImageAspectChanged: updateWidthHeightBindings(); \
                            visible: image.status == Image.Ready; \
                            function updateWidthHeightBindings() { \
                                if (aspectSmallerThanImageAspect) { \
                                    width = Qt.binding(function() { return !visible ? 0 : image.width }); \
                                    height = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.height : width / image.aspect }); \
                                } else { \
                                    width = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.width : height * image.aspect }); \
                                    height = Qt.binding(function() { return !visible ? 0 : image.height }); \
                                } \
                            } \
                            image: Image { \
                                objectName: "artImage"; \
                                source: cardData && cardData["art"] || ""; \
                                cache: true; \
                                asynchronous: root.asynchronous; \
                                fillMode: components && components["art"]["fill-mode"] === "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop; \
                                readonly property real aspect: implicitWidth / implicitHeight; \
                                ' + imageWidthHeight + '\
                            } \
                        } \
                    } \
                }'
    }

    if (inOverlay) {
        var height;
        if (hasMascot) {
            var height = 'mascotImage.height + 2 * units.gu(1);';
        } else {
            var height = mascotImageHeight + ' + 2 * units.gu(1);';
        }
        code += 'Loader { \
            id: overlayLoader; \
            anchors { \
                left: artShapeHolder.left; \
                right: artShapeHolder.right; \
                bottom: artShapeHolder.bottom; \
            } \
            active: artShapeLoader.active && artShapeLoader.item && artShapeLoader.item.image.status === Image.Ready || false; \
            asynchronous: root.asynchronous; \
            visible: status == Loader.Ready; \
            sourceComponent: ShaderEffect { \
                id: overlay; \
                height: ' + height + ' \
                opacity: 0.6; \
                property var source: ShaderEffectSource { \
                    id: shaderSource; \
                    sourceItem: artShapeLoader.item; \
                    onVisibleChanged: if (visible) scheduleUpdate(); \
                    live: false; \
                    sourceRect: Qt.rect(0, artShapeLoader.height - overlay.height, artShapeLoader.width, overlay.height); \
                } \
                vertexShader: " \
                    uniform highp mat4 qt_Matrix; \
                    attribute highp vec4 qt_Vertex; \
                    attribute highp vec2 qt_MultiTexCoord0; \
                    varying highp vec2 coord; \
                    void main() { \
                        coord = qt_MultiTexCoord0; \
                        gl_Position = qt_Matrix * qt_Vertex; \
                    }"; \
                fragmentShader: " \
                    varying highp vec2 coord; \
                    uniform sampler2D source; \
                    uniform lowp float qt_Opacity; \
                    void main() { \
                        lowp vec4 tex = texture2D(source, coord); \
                        gl_FragColor = vec4(0, 0, 0, tex.a) * qt_Opacity; \
                    }"; \
            } \
        }';
    }

    var headerVerticalAnchors;
    if (isHorizontal) {
        headerVerticalAnchors = 'anchors.top: artShapeHolder.top; \
                                 anchors.topMargin: units.gu(1);';
    } else {
        if (inOverlay) {
            headerVerticalAnchors = 'anchors.bottom: artShapeHolder.bottom; \
                                     anchors.bottomMargin: units.gu(1);';
        } else {
            headerVerticalAnchors = 'anchors.top: artShapeHolder.bottom; \
                                     anchors.topMargin: units.gu(1);';
        }
    }


    if (hasMascot) {
        var useMascotShape = !hasBackground && !inOverlay;
        var anchors = "";
        if (isHorizontal) {
            anchors += 'anchors.left: artShapeHolder.right; \
                       anchors.leftMargin: units.gu(1);';
        } else {
            anchors += 'anchors.left: parent.left; \
                       anchors.leftMargin: units.gu(1);';
        }
        anchors += headerVerticalAnchors;

        if (useMascotShape) {
            code += 'Loader { \
                        id: mascotShapeLoader; \
                        objectName: "mascotShapeLoader"; \
                        asynchronous: root.asynchronous; \
                        active: mascotImage.status === Image.Ready; \
                        visible: active && status == Loader.Ready; \
                        width: units.gu(6); \
                        height: units.gu(5.625); \
                        sourceComponent: UbuntuShape { image: mascotImage } \
                        ' + anchors + '\
                    }';
        }

        code += 'Image { \
                    id: mascotImage; \
                    objectName: "mascotImage"; \
                    ' + anchors + '\
                    readonly property int maxSize: Math.max(width, height) * 4; \
                    source: cardData && cardData["mascot"]; \
                    width: units.gu(6); \
                    height: ' + mascotImageHeight + '; \
                    sourceSize { width: maxSize; height: maxSize } \
                    fillMode: Image.PreserveAspectCrop; \
                    horizontalAlignment: Image.AlignHCenter; \
                    verticalAlignment: Image.AlignVCenter; \
                    visible:' + (useMascotShape ? 'false' : 'true') + '; \
                }';
    }

    var summaryColorWithBackground = 'backgroundLoader.active && backgroundLoader.item && backgroundLoader.item.luminance < 0.7 ? "white" : "grey"';

    if (hasTitle) {
        var color;
        if (inOverlay) {
            color = '"white"';
        } else if (hasSummary) {
            color = 'summary.color';
        } else if (hasBackground) {
            color = summaryColorWithBackground;
        } else {
            color = '"grey"';
        }
        var anchors = "anchors.right: parent.right;";
        if (hasMascot) {
            anchors += 'anchors.left: mascotImage.right; \
                        anchors.leftMargin: units.gu(1);';
        } else {
            anchors += 'anchors.left: parent.left; \
                        anchors.leftMargin: units.gu(1);';
        }
        anchors += headerVerticalAnchors;

        var titleAnchors = "";
        var subtitleAnchors = "";
        if (hasMascot && hasSubtitle) {
            titleAnchors = 'anchors { left: parent.left; right: parent.right }';
            code += 'Item { \
                        ' + anchors + '\
                        height: mascotImage.height; \
                        Column { \
                            anchors.verticalCenter: parent.verticalCenter; \
                            spacing: units.dp(2); \
                            width: parent.width - x;';
        } else {
            titleAnchors = anchors;
            subtitleAnchors = 'anchors.left: parent.left; \
                               anchors.leftMargin: units.gu(1); \
                               anchors.top: titleLabel.bottom; \
                               anchors.topMargin: units.dp(2);';
        }

        code += 'Label { \
                    id: titleLabel; \
                    objectName: "titleLabel"; \
                    ' + titleAnchors + '\
                    elide: Text.ElideRight; \
                    fontSize: "small"; \
                    wrapMode: Text.Wrap; \
                    maximumLineCount: 2; \
                    font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \
                    color: ' + color + '; \
                    text: root.title; \
                    font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; \
                    horizontalAlignment: root.headerAlignment; \
                }';

        if (hasSubtitle) {
            code += 'Label { \
                        id: subtitleLabel; \
                        objectName: "subtitleLabel"; \
                        ' + subtitleAnchors + '\
                        elide: Text.ElideRight; \
                        fontSize: "small"; \
                        wrapMode: Text.Wrap; \
                        maximumLineCount: 2; \
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \
                        color: ' + color + '; \
                        text: cardData && cardData["subtitle"] || " "; \
                        font.weight: Font.Light; \
                        horizontalAlignment: root.headerAlignment; \
                    }';

            // Close Column and Item
            if (hasMascot)
                code += '} }';
        }
    }

    if (hasSummary) {
        var summaryTopAnchor;
        if (isHorizontal) summaryTopAnchor = "artShapeHolder.bottom";
        else if (hasMascot) summaryTopAnchor = "mascotImage.bottom";
        else if (hasSubtitle) summaryTopAnchor = "subtitleLabel.bottom";
        else if (hasTitle) summaryTopAnchor = "titleLabel.bottom";
        else if (hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else summaryTopAnchor = "parent.top";
        var color;
        if (hasBackground) {
            color = summaryColorWithBackground;
        } else {
            color = '"grey"';
        }
        code += 'Label { \
                    id: summary; \
                    objectName: "summaryLabel"; \
                    anchors { \
                        top: ' + summaryTopAnchor + '; \
                        left: parent.left; \
                        right: parent.right; \
                        margins: backgroundLoader.active ? units.gu(1) : 0; \
                        topMargin: ' + (hasMascot || hasSubtitle ? 'anchors.margins' : 0) + '; \
                    } \
                    wrapMode: Text.Wrap; \
                    maximumLineCount: 5; \
                    elide: Text.ElideRight; \
                    text: cardData && cardData["summary"] || ""; \
                    height: text ? implicitHeight : 0; \
                    fontSize: "small"; \
                    color: ' + color + '; \
                }';
    }

    // Close the AbstractButton
    if (hasSummary && hasBackground) {
        code += 'implicitHeight: summary.y + summary.height + (summary.text && backgroundLoader.active ? units.gu(1) : 0)';
    } else if (hasSummary) {
        code += 'implicitHeight: summary.y + summary.height';
    } else if (hasMascot) {
        code += 'implicitHeight: mascotImage.y + mascotImage.height';
    } else if (hasTitle) {
        code += 'implicitHeight: titleLabel.y + titleLabel.height';
    }
    code += '}';



    code = imports + 'Component {' + code + '}';
//     console.log(code)
    return Qt.createQmlObject(code, parent, "createCardComponent");
}

