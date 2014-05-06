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

.pragma library

function cardString(template, components) {
    var code;
    code = 'AbstractButton { \n\
                id: root; \n\
                property var template; \n\
                property var components; \n\
                property var cardData; \n\
                property real fontScale: 1.0; \n\
                property int headerAlignment: Text.AlignLeft; \n\
                property int fixedHeaderHeight: -1; \n\
                property size fixedArtShapeSize: Qt.size(-1, -1); \n\
                readonly property string title: cardData && cardData["title"] || ""; \n\
                property bool asynchronous: true; \n\
                property bool showHeader: true; \n\
                implicitWidth: childrenRect.width; \n';

    var hasArt = components["art"] && components["art"]["field"] || false;
    var hasSummary = components["summary"] || false;
    var artAndSummary = hasArt && hasSummary;
    var isHorizontal = template["card-layout"] === "horizontal";
    var hasBackground = !isHorizontal && (template["card-background"] || components["background"] || artAndSummary);
    var hasTitle = components["title"] || false;
    var hasMascot = components["mascot"] || false;
    var headerAsOverlay = hasArt && template && template["overlay"] === true && (hasTitle || hasMascot);
    var hasSubtitle = components["subtitle"] || false;
    var hasHeaderRow = hasMascot && hasTitle;

    if (hasBackground) {
        code += 'Loader {\n\
                    id: backgroundLoader; \n\
                    objectName: "backgroundLoader"; \n\
                    anchors.fill: parent; \n\
                    asynchronous: root.asynchronous; \n\
                    visible: status == Loader.Ready; \n\
                    sourceComponent: UbuntuShape { \n\
                        objectName: "background"; \n\
                        radius: "medium"; \n\
                        color: getColor(0) || "white"; \n\
                        gradientColor: getColor(1) || color; \n\
                        anchors.fill: parent; \n\
                        image: backgroundImage.source ? backgroundImage : null; \n\
                        property real luminance: 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b; \n\
                        property Image backgroundImage: Image { \n\
                            objectName: "backgroundImage"; \n\
                            source: { \n\
                                if (cardData && typeof cardData["background"] === "string") return cardData["background"]; \n\
                                else if (template && typeof template["card-background"] === "string") return template["card-background"]; \n\
                                else return ""; \n\
                            } \n\
                        } \n\
                        function getColor(index) { \n\
                            if (cardData && typeof cardData["background"] === "object" \n\
                                && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { \n\
                                return cardData["background"]["elements"][index]; \n\
                            } else if (template && typeof template["card-background"] === "object" \n\
                                    && (template["card-background"]["type"] === "color" || template["card-background"]["type"] === "gradient"))  { \n\
                                return template["card-background"]["elements"][index]; \n\
                            } else return undefined; \n\
                        } \n\
                    } \n\
                }\n';
    }

    if (hasArt) {
        code += 'readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);\n'
        var imageWidthHeight;
        if (isHorizontal) {
            if (hasMascot || hasTitle) {
                imageWidthHeight = 'width: height * artShape.aspect; \n\
                                    height: headerHeight;\n'
            } else {
                // This side of the else is a bit silly, who wants an horizontal layout without mascot and title?
                // So we define a "random" height of the image height + 2 gu for the margins
                imageWidthHeight = 'width: height * artShape.aspect; \n\
                                    height: units.gu(7.625)';
            }
        } else {
            imageWidthHeight = 'width: root.width; \n\
                                height: width / artShape.aspect;\n'
        }
        code += 'Item  { \n\
                    id: artShapeHolder; \n\
                    height: root.fixedArtShapeSize.height != -1 ? root.fixedArtShapeSize.height : artShapeLoader.height; \n\
                    width: root.fixedArtShapeSize.width != -1 ? root.fixedArtShapeSize.width : artShapeLoader.width; \n\
                    ' + (isHorizontal ? 'anchors.left: parent.left;' : 'anchors.horizontalCenter: parent.horizontalCenter;\n' ) + '\n\
                    Loader { \n\
                        id: artShapeLoader; \n\
                        objectName: "artShapeLoader"; \n\
                        active: cardData && cardData["art"] || false; \n\
                        asynchronous: root.asynchronous; \n\
                        visible: status == Loader.Ready; \n\
                        sourceComponent: UbuntuShape { \n\
                            id: artShape; \n\
                            objectName: "artShape"; \n\
                            radius: "medium"; \n\
                            readonly property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1; \n\
                            readonly property bool aspectSmallerThanImageAspect: aspect < image.aspect; \n\
                            Component.onCompleted: updateWidthHeightBindings(); \n\
                            onAspectSmallerThanImageAspectChanged: updateWidthHeightBindings(); \n\
                            visible: image.status == Image.Ready; \n\
                            function updateWidthHeightBindings() { \n\
                                if (aspectSmallerThanImageAspect) { \n\
                                    width = Qt.binding(function() { return !visible ? 0 : image.width }); \n\
                                    height = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.height : width / image.aspect }); \n\
                                } else { \n\
                                    width = Qt.binding(function() { return !visible ? 0 : image.fillMode === Image.PreserveAspectCrop ? image.width : height * image.aspect }); \n\
                                    height = Qt.binding(function() { return !visible ? 0 : image.height }); \n\
                                } \n\
                            } \n\
                            image: Image { \n\
                                objectName: "artImage"; \n\
                                source: cardData && cardData["art"] || ""; \n\
                                cache: true; \n\
                                asynchronous: root.asynchronous; \n\
                                fillMode: components && components["art"]["fill-mode"] === "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop; \n\
                                readonly property real aspect: implicitWidth / implicitHeight; \n\
                                ' + imageWidthHeight + '\n\
                            } \n\
                        } \n\
                    } \n\
                }\n'
    } else {
        code += 'readonly property size artShapeSize: Qt.size(-1, -1);\n'
    }

    if (headerAsOverlay) {
        var height = 'fixedHeaderHeight != -1 ? fixedHeaderHeight : headerHeight;\n';
        code += 'Loader { \n\
            id: overlayLoader; \n\
            anchors { \n\
                left: artShapeHolder.left; \n\
                right: artShapeHolder.right; \n\
                bottom: artShapeHolder.bottom; \n\
            } \n\
            active: artShapeLoader.active && artShapeLoader.item && artShapeLoader.item.image.status === Image.Ready || false; \n\
            asynchronous: root.asynchronous; \n\
            visible: showHeader && status == Loader.Ready; \n\
            sourceComponent: ShaderEffect { \n\
                id: overlay; \n\
                height: ' + height + ' \n\
                opacity: 0.6; \n\
                property var source: ShaderEffectSource { \n\
                    id: shaderSource; \n\
                    sourceItem: artShapeLoader.item; \n\
                    onVisibleChanged: if (visible) scheduleUpdate(); \n\
                    live: false; \n\
                    sourceRect: Qt.rect(0, artShapeLoader.height - overlay.height, artShapeLoader.width, overlay.height); \n\
                } \n\
                vertexShader: " \n\
                    uniform highp mat4 qt_Matrix; \n\
                    attribute highp vec4 qt_Vertex; \n\
                    attribute highp vec2 qt_MultiTexCoord0; \n\
                    varying highp vec2 coord; \n\
                    void main() { \n\
                        coord = qt_MultiTexCoord0; \n\
                        gl_Position = qt_Matrix * qt_Vertex; \n\
                    }"; \n\
                fragmentShader: " \n\
                    varying highp vec2 coord; \n\
                    uniform sampler2D source; \n\
                    uniform lowp float qt_Opacity; \n\
                    void main() { \n\
                        lowp vec4 tex = texture2D(source, coord); \n\
                        gl_FragColor = vec4(0, 0, 0, tex.a) * qt_Opacity; \n\
                    }"; \n\
            } \n\
        }\n';
    }

    var headerVerticalAnchors;
    if (headerAsOverlay) {
        headerVerticalAnchors = 'anchors.bottom: artShapeHolder.bottom; \n\
                                 anchors.bottomMargin: units.gu(1);\n';
    } else {
        if (hasArt) {
            if (isHorizontal) {
                headerVerticalAnchors = 'anchors.top: artShapeHolder.top; \n\
                                         anchors.topMargin: units.gu(1);\n';
            } else {
                headerVerticalAnchors = 'anchors.top: artShapeHolder.bottom; \n\
                                         anchors.topMargin: units.gu(1);\n';
            }
        } else {
            headerVerticalAnchors = 'anchors.top: parent.top; \n\
                                     anchors.topMargin: units.gu(1);\n';
        }
    }
    var headerLeftAnchor;
    var headerLeftAnchorHasMagin = false;
    if (isHorizontal && hasArt) {
        headerLeftAnchor = 'anchors.left: artShapeHolder.right; \n\
                            anchors.leftMargin: units.gu(1);\n';
        headerLeftAnchorHasMagin = true;
    } else {
        headerLeftAnchor = 'anchors.left: parent.left;\n';
    }

    if (hasHeaderRow) {
        code += 'readonly property int headerHeight: row.height + row.margins * 2;\n'
        code += 'Row { \n\
                    id: row; \n\
                    objectName: "outerRow"; \n\
                    property real margins: units.gu(1); \n\
                    spacing: margins; \n\
                    ' + headerVerticalAnchors + '\n\
                    ' + headerLeftAnchor + '\n\
                    anchors.right: parent.right; \n\
                    anchors.margins: margins;\n';
    } else if (hasMascot) {
        code += 'readonly property int headerHeight: mascotImage.height + units.gu(1) * 2;\n'
    } else if (hasSubtitle) {
        code += 'readonly property int headerHeight: subtitleLabel.y + subtitleLabel.height - titleLabel.y + titleLabel.anchors.topMargin * 2 + subtitleLabel.anchors.topMargin;\n'
    } else if (hasTitle) {
        code += 'readonly property int headerHeight: titleLabel.height + titleLabel.anchors.topMargin * 2;\n'
    } else {
        code += 'readonly property int headerHeight: 0;\n'
    }

    if (hasMascot) {
        var useMascotShape = !hasBackground && !headerAsOverlay;
        var anchors = "";
        if (!hasHeaderRow) {
            anchors += headerLeftAnchor;
            anchors += headerVerticalAnchors;
            if (!headerLeftAnchorHasMagin) {
                anchors += 'anchors.leftMargin: units.gu(1);\n'
            }
        } else {
            anchors = "anchors.verticalCenter: parent.verticalCenter;"
        }

        if (useMascotShape) {
            code += 'Loader { \n\
                        id: mascotShapeLoader; \n\
                        objectName: "mascotShapeLoader"; \n\
                        asynchronous: root.asynchronous; \n\
                        active: mascotImage.status === Image.Ready; \n\
                        visible: showHeader && active && status == Loader.Ready; \n\
                        width: units.gu(6); \n\
                        height: units.gu(5.625); \n\
                        sourceComponent: UbuntuShape { image: mascotImage } \n\
                        ' + anchors + '\n\
                    }\n';
        }

        code += 'Image { \n\
                    id: mascotImage; \n\
                    objectName: "mascotImage"; \n\
                    ' + anchors + '\n\
                    readonly property int maxSize: Math.max(width, height) * 4; \n\
                    source: cardData && cardData["mascot"]; \n\
                    width: units.gu(6); \n\
                    height: units.gu(5.625); \n\
                    sourceSize { width: maxSize; height: maxSize } \n\
                    fillMode: Image.PreserveAspectCrop; \n\
                    horizontalAlignment: Image.AlignHCenter; \n\
                    verticalAlignment: Image.AlignVCenter; \n\
                    visible: showHeader && ' + (useMascotShape ? 'false' : 'true') + '; \n\
                }\n';
    }

    var summaryColorWithBackground = 'backgroundLoader.active && backgroundLoader.item && backgroundLoader.item.luminance < 0.7 ? "white" : "grey"';

    if (hasTitle) {
        var color;
        if (headerAsOverlay) {
            color = '"white"';
        } else if (hasSummary) {
            color = 'summary.color';
        } else if (hasBackground) {
            color = summaryColorWithBackground;
        } else {
            color = '"grey"';
        }

        var titleAnchors = "";
        var subtitleAnchors = "";
        if (hasMascot && hasSubtitle) {
            titleAnchors = 'anchors { left: parent.left; right: parent.right }\n';
            subtitleAnchors = titleAnchors;
            code += 'Column { \n\
                        anchors.verticalCenter: parent.verticalCenter; \n\
                        spacing: units.dp(2); \n\
                        width: parent.width - x;\n';
        } else if (hasMascot) {
            titleAnchors = 'anchors.verticalCenter: parent.verticalCenter;\n'
        } else if (headerAsOverlay) {
            titleAnchors = 'anchors.left: parent.left; \n\
                            anchors.leftMargin: units.gu(1); \n\
                            anchors.right: parent.right; \n\
                            anchors.top: overlayLoader.top; \n\
                            anchors.topMargin: units.gu(1);\n';
            subtitleAnchors = 'anchors.left: titleLabel.left; \n\
                               anchors.leftMargin: titleLabel.leftMargin; \n\
                               anchors.right: titleLabel.right; \n\
                               anchors.top: titleLabel.bottom; \n\
                               anchors.topMargin: units.dp(2);\n';
        } else {
            titleAnchors = "anchors.right: parent.right;";
            if (hasMascot) {
                titleAnchors += 'anchors.left: mascotImage.right; \n\
                                 anchors.leftMargin: units.gu(1);\n';
            } else {
                titleAnchors += headerLeftAnchor;
            }
            titleAnchors += headerVerticalAnchors;
            subtitleAnchors = 'anchors.left: titleLabel.left; \n\
                               anchors.leftMargin: titleLabel.leftMargin; \n\
                               anchors.right: titleLabel.right; \n\
                               anchors.top: titleLabel.bottom; \n\
                               anchors.topMargin: units.dp(2);\n';
        }

        code += 'Label { \n\
                    id: titleLabel; \n\
                    objectName: "titleLabel"; \n\
                    ' + titleAnchors + '\n\
                    elide: Text.ElideRight; \n\
                    fontSize: "small"; \n\
                    wrapMode: Text.Wrap; \n\
                    maximumLineCount: 2; \n\
                    font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \n\
                    color: ' + color + '; \n\
                    visible: showHeader ' + (headerAsOverlay ? '&& overlayLoader.active': '') + '; \n\
                    text: root.title; \n\
                    font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; \n\
                    horizontalAlignment: root.headerAlignment; \n\
                }\n';

        if (hasSubtitle) {
            code += 'Label { \n\
                        id: subtitleLabel; \n\
                        objectName: "subtitleLabel"; \n\
                        ' + subtitleAnchors + '\n\
                        elide: Text.ElideRight; \n\
                        fontSize: "small"; \n\
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \n\
                        color: ' + color + '; \n\
                        visible: titleLabel.visible && titleLabel.text; \n\
                        text: cardData && cardData["subtitle"] || ""; \n\
                        font.weight: Font.Light; \n\
                        horizontalAlignment: root.headerAlignment; \n\
                    }\n';

            // Close Column
            if (hasMascot)
                code += '}\n';
        }
    }

    if (hasHeaderRow) {
        // Close Row
        code += '}\n';
    }

    if (hasSummary) {
        var summaryTopAnchor;
        if (isHorizontal && hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else if (headerAsOverlay && hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else if (hasHeaderRow) summaryTopAnchor = "row.bottom";
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
        code += 'Label { \n\
                    id: summary; \n\
                    objectName: "summaryLabel"; \n\
                    anchors { \n\
                        top: ' + summaryTopAnchor + '; \n\
                        left: parent.left; \n\
                        right: parent.right; \n\
                        margins: units.gu(1); \n\
                        topMargin: ' + (hasMascot || hasSubtitle ? 'anchors.margins' : 0) + '; \n\
                    } \n\
                    wrapMode: Text.Wrap; \n\
                    maximumLineCount: 5; \n\
                    elide: Text.ElideRight; \n\
                    text: cardData && cardData["summary"] || ""; \n\
                    height: text ? implicitHeight : 0; \n\
                    fontSize: "small"; \n\
                    color: ' + color + '; \n\
                }\n';
    }

    // Close the AbstractButton
    if (hasSummary) {
        code += 'implicitHeight: summary.y + summary.height + (summary.text ? units.gu(1) : 0);\n';
    } else if (hasHeaderRow) {
        code += 'implicitHeight: row.y + row.height + units.gu(1);\n';
    } else if (hasMascot) {
        code += 'implicitHeight: mascotImage.y + mascotImage.height;\n';
    } else if (hasSubtitle) {
        code += 'implicitHeight: subtitleLabel.y + subtitleLabel.height + units.gu(1);\n';
    } else if (hasTitle) {
        code += 'implicitHeight: titleLabel.y + titleLabel.height + units.gu(1);\n';
    }
    code += '}\n';

    return code;
}

function createCardComponent(parent, template, components) {
    var imports = 'import QtQuick 2.2; \n\
                   import Ubuntu.Components 0.1; \n\
                   import Ubuntu.Thumbnailer 0.1;\n';
    var card = cardString(template, components);
    var code = imports + 'Component {\n' + card + '}\n';
    return Qt.createQmlObject(code, parent, "createCardComponent");
}
