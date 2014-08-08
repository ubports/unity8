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

var kBackgroundLoaderCode = 'Loader {\n\
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

// %1 is used as anchors of artShapeHolder
// %2 is used as image width
// %3 is used as image height
var kArtShapeHolderCode = 'Item  { \n\
                            id: artShapeHolder; \n\
                            height: root.fixedArtShapeSize.height > 0 ? root.fixedArtShapeSize.height : artShapeLoader.height; \n\
                            width: root.fixedArtShapeSize.width > 0 ? root.fixedArtShapeSize.width : artShapeLoader.width; \n\
                            anchors { %1 } \n\
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
                                    visible: image.status == Image.Ready; \n\
                                    readonly property real fixedArtShapeSizeAspect: (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) ? root.fixedArtShapeSize.width / root.fixedArtShapeSize.height : -1; \n\
                                    readonly property real aspect: fixedArtShapeSizeAspect > 0 ? fixedArtShapeSizeAspect : components !== undefined ? components["art"]["aspect-ratio"] : 1; \n\
                                    Component.onCompleted: { updateWidthHeightBindings(); if (artShapeBorderSource !== undefined) borderSource = artShapeBorderSource; } \n\
                                    Connections { target: root; onFixedArtShapeSizeChanged: updateWidthHeightBindings(); } \n\
                                    function updateWidthHeightBindings() { \n\
                                        if (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) { \n\
                                            width = root.fixedArtShapeSize.width; \n\
                                            height = root.fixedArtShapeSize.height; \n\
                                        } else { \n\
                                            width = Qt.binding(function() { return !visible ? 0 : image.width }); \n\
                                            height = Qt.binding(function() { return !visible ? 0 : image.height }); \n\
                                        } \n\
                                    } \n\
                                    image: Image { \n\
                                        objectName: "artImage"; \n\
                                        source: cardData && cardData["art"] || ""; \n\
                                        cache: true; \n\
                                        asynchronous: root.asynchronous; \n\
                                        fillMode: Image.PreserveAspectCrop; \n\
                                        width: %2; \n\
                                        height: %3; \n\
                                    } \n\
                                } \n\
                            } \n\
                        }\n';

var kOverlayLoaderCode = 'Loader { \n\
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
                                height: (fixedHeaderHeight > 0 ? fixedHeaderHeight : headerHeight) + units.gu(2); \n\
                                property real luminance: 0.2126 * overlayColor.r + 0.7152 * overlayColor.g + 0.0722 * overlayColor.b; \n\
                                property color overlayColor: cardData && cardData["overlayColor"] || "#99000000"; \n\
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
                                    uniform highp vec4 overlayColor; \n\
                                    void main() { \n\
                                        lowp vec4 tex = texture2D(source, coord); \n\
                                        gl_FragColor = vec4(overlayColor.r, overlayColor.g, overlayColor.b, 1) * qt_Opacity * overlayColor.a * tex.a; \n\
                                    }"; \n\
                            } \n\
                        }\n';

// multiple row version of HeaderRowCode
function kHeaderRowCodeGenerator() {
var kHeaderRowCodeTemplate = 'Row { \n\
                        id: row; \n\
                        objectName: "outerRow"; \n\
                        property real margins: units.gu(1); \n\
                        spacing: margins; \n\
                        height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight; \n\
                        anchors { %1 } \n\
                        anchors.right: parent.right; \n\
                        anchors.margins: margins; \n\
                        anchors.rightMargin: 0; \n\
                        data: [ \n\
                                %2 \n\
                                ] \n\
                    }\n';
    var args = Array.prototype.slice.call(arguments);
    var code = kHeaderRowCodeTemplate.arg(args.shift()).arg(args.join(',\n'));
    return code;
}

// multiple item version of kHeaderContainerCode
function kHeaderContainerCodeGenerator() {
    var headerContainerCodeTemplate = 'Item { \n\
                            id: headerTitleContainer; \n\
                            anchors { %1 } \n\
                            width: parent.width - x; \n\
                            implicitHeight: %2; \n\
                            data: [ \n\
                                %3 \n\
                            ]\n\
                        }\n';
    var args = Array.prototype.slice.call(arguments);
    var code = headerContainerCodeTemplate.arg(args.shift()).arg(args.shift()).arg(args.join(',\n'));
    return code;
}

// %1 is used as anchors of mascotShapeLoader
var kMascotShapeLoaderCode = 'Loader { \n\
                                id: mascotShapeLoader; \n\
                                objectName: "mascotShapeLoader"; \n\
                                asynchronous: root.asynchronous; \n\
                                active: mascotImage.status === Image.Ready; \n\
                                visible: showHeader && active && status == Loader.Ready; \n\
                                width: units.gu(6); \n\
                                height: units.gu(5.625); \n\
                                sourceComponent: UbuntuShape { image: mascotImage } \n\
                                anchors { %1 } \n\
                            }\n';

// %1 is used as anchors of mascotImage
// %2 is used as visible of mascotImage
var kMascotImageCode = 'Image { \n\
                            id: mascotImage; \n\
                            objectName: "mascotImage"; \n\
                            anchors { %1 } \n\
                            readonly property int maxSize: Math.max(width, height) * 4; \n\
                            source: cardData && cardData["mascot"] || ""; \n\
                            width: units.gu(6); \n\
                            height: units.gu(5.625); \n\
                            sourceSize { width: maxSize; height: maxSize } \n\
                            fillMode: Image.PreserveAspectCrop; \n\
                            horizontalAlignment: Image.AlignHCenter; \n\
                            verticalAlignment: Image.AlignVCenter; \n\
                            visible: %2; \n\
                        }\n';

// %1 is used as anchors of titleLabel
// %2 is used as color of titleLabel
// %3 is used as extra condition for visible of titleLabel
var kTitleLabelCode = 'Label { \n\
                        id: titleLabel; \n\
                        objectName: "titleLabel"; \n\
                        anchors { %1 } \n\
                        elide: Text.ElideRight; \n\
                        fontSize: "small"; \n\
                        wrapMode: Text.Wrap; \n\
                        maximumLineCount: 2; \n\
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \n\
                        color: %2; \n\
                        visible: showHeader %3; \n\
                        text: root.title; \n\
                        font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; \n\
                        horizontalAlignment: root.headerAlignment; \n\
                    }\n';

// %1 is used as extra anchors of emblemImage
var kEmblemImageCode = 'Image { \n\
                            id: emblemImage; \n\
                            objectName: "emblemImage"; \n\
                            anchors { \n\
                                bottom: titleLabel.baseline; \n\
                                right: parent.right; \n\
                                %1
                            } \n\
                            source: cardData && cardData["emblem"] || ""; \n\
                            width: height; \n\
                            height: status === Image.Ready ? titleLabel.font.pixelSize : 0; \n\
                            fillMode: Image.PreserveAspectFit; \n\
                        }\n';

// %1 is used as anchors of touchdown effect
var kTouchdownCode = 'UbuntuShape { \n\
                        id: touchdown; \n\
                        objectName: "touchdown"; \n\
                        anchors { %1 } \n\
                        visible: root.pressed; \n\
                        radius: "medium"; \n\
                        borderSource: "radius_pressed.sci" \n\
                    }\n';

// %1 is used as anchors of subtitleLabel
// %2 is used as color of subtitleLabel
var kSubtitleLabelCode = 'Label { \n\
                            id: subtitleLabel; \n\
                            objectName: "subtitleLabel"; \n\
                            anchors { %1 } \n\
                            anchors.topMargin: units.dp(2); \n\
                            elide: Text.ElideRight; \n\
                            fontSize: "small"; \n\
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); \n\
                            color: %2; \n\
                            visible: titleLabel.visible && titleLabel.text; \n\
                            text: cardData && cardData["subtitle"] || ""; \n\
                            font.weight: Font.Light; \n\
                            horizontalAlignment: root.headerAlignment; \n\
                        }\n';

// %1 is used as anchors of attributesRow
var kAttributesRowCode = 'CardAttributes { \n\
                            id: attributesRow; \n\
                            objectName: "attributesRow"; \n\
                            anchors { %1 } \n\
                            color: %2; \n\
                            model: cardData && cardData["attributes"]; \n\
                          }\n';

// %1 is used as top anchor of summary
// %2 is used as topMargin anchor of summary
// %3 is used as color of summary
var kSummaryLabelCode = 'Label { \n\
                            id: summary; \n\
                            objectName: "summaryLabel"; \n\
                            anchors { \n\
                                top: %1; \n\
                                left: parent.left; \n\
                                right: parent.right; \n\
                                margins: units.gu(1); \n\
                                topMargin: %2; \n\
                            } \n\
                            wrapMode: Text.Wrap; \n\
                            maximumLineCount: 5; \n\
                            elide: Text.ElideRight; \n\
                            text: cardData && cardData["summary"] || ""; \n\
                            height: text ? implicitHeight : 0; \n\
                            fontSize: "small"; \n\
                            color: %3; \n\
                        }\n';

function cardString(template, components) {
    var code;
    code = 'AbstractButton { \n\
                id: root; \n\
                property var template; \n\
                property var components; \n\
                property var cardData; \n\
                property var artShapeBorderSource: undefined; \n\
                property real fontScale: 1.0; \n\
                property var scopeStyle: null; \n\
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
    var hasEmblem = components["emblem"] && !(hasMascot && template["card-size"] === "small") || false;
    var headerAsOverlay = hasArt && template && template["overlay"] === true && (hasTitle || hasMascot);
    var hasSubtitle = hasTitle && components["subtitle"] || false;
    var hasHeaderRow = hasMascot && hasTitle;
    var hasAttributes = hasTitle && components["attributes"]["field"] || false;

    if (hasBackground) {
        code += kBackgroundLoaderCode;
    }

    if (hasArt) {
        code += 'onArtShapeBorderSourceChanged: { if (artShapeBorderSource !== undefined && artShapeLoader.item) artShapeLoader.item.borderSource = artShapeBorderSource; } \n';
        code += 'readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);\n';

        var widthCode, heightCode;
        var artAnchors;
        if (isHorizontal) {
            artAnchors = 'left: parent.left';
            if (hasMascot || hasTitle) {
                widthCode = 'height * artShape.aspect'
                heightCode = 'headerHeight + 2 * units.gu(1)';
            } else {
                // This side of the else is a bit silly, who wants an horizontal layout without mascot and title?
                // So we define a "random" height of the image height + 2 gu for the margins
                widthCode = 'height * artShape.aspect'
                heightCode = 'units.gu(7.625)';
            }
        } else {
            artAnchors = 'horizontalCenter: parent.horizontalCenter;';
            widthCode = 'root.width'
            heightCode = 'width / artShape.aspect';
        }

        code += kArtShapeHolderCode.arg(artAnchors).arg(widthCode).arg(heightCode);
    } else {
        code += 'readonly property size artShapeSize: Qt.size(-1, -1);\n'
    }

    if (headerAsOverlay) {
        code += kOverlayLoaderCode;
    }

    var headerVerticalAnchors;
    if (headerAsOverlay) {
        headerVerticalAnchors = 'bottom: artShapeHolder.bottom; \n\
                                 bottomMargin: units.gu(1);\n';
    } else {
        if (hasArt) {
            if (isHorizontal) {
                headerVerticalAnchors = 'top: artShapeHolder.top; \n\
                                         topMargin: units.gu(1);\n';
            } else {
                headerVerticalAnchors = 'top: artShapeHolder.bottom; \n\
                                         topMargin: units.gu(1);\n';
            }
        } else {
            headerVerticalAnchors = 'top: parent.top; \n\
                                     topMargin: units.gu(1);\n';
        }
    }
    var headerLeftAnchor;
    var headerLeftAnchorHasMargin = false;
    if (isHorizontal && hasArt) {
        headerLeftAnchor = 'left: artShapeHolder.right; \n\
                            leftMargin: units.gu(1);\n';
        headerLeftAnchorHasMargin = true;
    } else {
        headerLeftAnchor = 'left: parent.left;\n';
    }

    var touchdownOnArtShape = !hasBackground && hasArt && !hasMascot && !hasSummary;

    if (hasHeaderRow) {
        code += 'readonly property int headerHeight: row.height;\n'
    } else if (hasMascot) {
        code += 'readonly property int headerHeight: mascotImage.height;\n'
    } else if (hasAttributes) {
        if (hasTitle && hasSubtitle) {
            code += 'readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin + attributesRow.height + attributesRow.anchors.topMargin;\n'
        } else if (hasTitle) {
            code += 'readonly property int headerHeight: titleLabel.height + attributesRow.height + attributesRow.anchors.topMargin;\n'
        } else {
            code += 'readonly property int headerHeight: attributesRow.height;\n'
        }
    } else if (hasSubtitle) {
        code += 'readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin;\n'
    } else if (hasTitle) {
        code += 'readonly property int headerHeight: titleLabel.height;\n'
    } else {
        code += 'readonly property int headerHeight: 0;\n'
    }

    var mascotShapeCode = '';
    var mascotCode = '';
    if (hasMascot) {
        var useMascotShape = !hasBackground && !headerAsOverlay;
        var mascotAnchors = '';
        if (!hasHeaderRow) {
            mascotAnchors += headerLeftAnchor;
            mascotAnchors += headerVerticalAnchors;
            if (!headerLeftAnchorHasMargin) {
                mascotAnchors += 'leftMargin: units.gu(1);\n'
            }
        } else {
            mascotAnchors = 'verticalCenter: parent.verticalCenter;'
        }

        if (useMascotShape) {
            mascotShapeCode = kMascotShapeLoaderCode.arg(mascotAnchors);
        }

        var mascotImageVisible = useMascotShape ? 'false' : 'showHeader';
        mascotCode = kMascotImageCode.arg(mascotAnchors).arg(mascotImageVisible);
    }

    var summaryColorWithBackground = 'backgroundLoader.active && backgroundLoader.item && backgroundLoader.item.luminance < (root.scopeStyle ? root.scopeStyle.threshold : 0.7) ? (root.scopeStyle ? root.scopeStyle.light : "white") : (root.scopeStyle ? root.scopeStyle.dark : "grey")';

    var hasTitleContainer = hasTitle && (hasEmblem || (hasMascot && (hasSubtitle || hasAttributes)));
    var titleSubtitleCode = '';
    if (hasTitle) {
        var titleColor;
        if (headerAsOverlay) {
            titleColor = 'overlayLoader.item.luminance < (root.scopeStyle ? root.scopeStyle.threshold : 0.7) ? (root.scopeStyle ? root.scopeStyle.light : "white") : (root.scopeStyle ? root.scopeStyle.dark : "grey")';
        } else if (hasSummary) {
            titleColor = 'summary.color';
        } else if (hasBackground) {
            titleColor = summaryColorWithBackground;
        } else {
            titleColor = 'root.scopeStyle ? root.scopeStyle.foreground : "grey"';
        }

        var titleAnchors;
        var subtitleAnchors;
        var attributesAnchors;
        var titleContainerAnchors;
        var titleRightAnchor;

        var extraRightAnchor = '';
        var extraLeftAnchor = '';
        if (!touchdownOnArtShape) {
            extraRightAnchor = 'rightMargin: units.gu(1); \n';
            extraLeftAnchor = 'leftMargin: units.gu(1); \n';
        }

        if (hasMascot) {
            titleContainerAnchors = 'verticalCenter: parent.verticalCenter; ';
        } else {
            titleContainerAnchors = 'right: parent.right; ';
            titleContainerAnchors += headerLeftAnchor;
            titleContainerAnchors += headerVerticalAnchors;
            if (!headerLeftAnchorHasMargin) {
                titleContainerAnchors += extraLeftAnchor;
            }
        }
        if (hasEmblem) {
            titleRightAnchor = 'right: emblemImage.left; \n\
                                rightMargin: emblemImage.width > 0 ? units.gu(0.5) : 0; \n';
        } else {
            titleRightAnchor = 'right: parent.right; \n'
            titleRightAnchor += extraRightAnchor;
        }

        if (hasTitleContainer) {
            // Using headerTitleContainer
            titleAnchors = titleRightAnchor;
            titleAnchors += 'left: parent.left; \n\
                             top: parent.top;';
            subtitleAnchors = 'right: parent.right; \n\
                               left: parent.left; \n';
            subtitleAnchors += extraRightAnchor;
            if (hasSubtitle) {
                attributesAnchors = subtitleAnchors + 'top: subtitleLabel.bottom;\n';
                subtitleAnchors += 'top: titleLabel.bottom;\n';
            } else {
                attributesAnchors = subtitleAnchors + 'top: titleLabel.bottom;\n';
            }
        } else if (hasMascot) {
            // Using row + titleContainer
            titleAnchors = 'verticalCenter: parent.verticalCenter;\n';
        } else {
            if (headerAsOverlay) {
                // Using anchors to the overlay
                titleAnchors = titleRightAnchor;
                titleAnchors += 'left: parent.left; \n\
                                 leftMargin: units.gu(1); \n\
                                 top: overlayLoader.top; \n\
                                 topMargin: units.gu(1);\n';
            } else {
                // Using anchors to the mascot/parent
                titleAnchors = titleRightAnchor;
                titleAnchors += headerLeftAnchor;
                titleAnchors += headerVerticalAnchors;
                if (!headerLeftAnchorHasMargin) {
                    titleAnchors += extraLeftAnchor;
                }
            }
            subtitleAnchors = 'left: titleLabel.left; \n\
                               leftMargin: titleLabel.leftMargin; \n';
            subtitleAnchors += extraRightAnchor;
            if (hasEmblem) {
                // using container
                subtitleAnchors += 'right: parent.right; \n';
            } else {
                subtitleAnchors += 'right: titleLabel.right; \n';
            }

            if (hasSubtitle) {
                attributesAnchors = subtitleAnchors + 'top: subtitleLabel.bottom;\n';
                subtitleAnchors += 'top: titleLabel.bottom;\n';
            } else {
                attributesAnchors = subtitleAnchors + 'top: titleLabel.bottom;\n';
            }
        }

        // code for different elements
        var titleLabelVisibleExtra = (headerAsOverlay ? '&& overlayLoader.active': '');
        var titleCode = kTitleLabelCode.arg(titleAnchors).arg(titleColor).arg(titleLabelVisibleExtra);
        var subtitleCode;
        var attributesCode;

        // code for the title container
        var containerCode = [];
        var containerHeight = 'titleLabel.height';
        containerCode.push(titleCode);
        if (hasSubtitle) {
            subtitleCode = kSubtitleLabelCode.arg(subtitleAnchors).arg(titleColor);
            containerCode.push(subtitleCode);
            containerHeight += ' + subtitleLabel.height';
        }
        if (hasEmblem) {
            containerCode.push(kEmblemImageCode.arg(extraRightAnchor));
        }
        if (hasAttributes) {
            attributesCode = kAttributesRowCode.arg(attributesAnchors).arg(titleColor);
            containerCode.push(attributesCode);
            containerHeight += ' + attributesRow.height';
        }

        if (hasTitleContainer) {
            // use container
            titleSubtitleCode = kHeaderContainerCodeGenerator(titleContainerAnchors, containerHeight, containerCode);
        } else {
            // no container
            titleSubtitleCode = titleCode;
            if (hasSubtitle) {
                titleSubtitleCode += subtitleCode;
            }
            if (hasAttributes) {
                titleSubtitleCode += attributesCode;
            }
        }
    }

    if (hasHeaderRow) {
        var rowCode = [mascotCode, titleSubtitleCode];
        if (mascotShapeCode != '') {
           rowCode.unshift(mascotShapeCode);
        }
        code += kHeaderRowCodeGenerator(headerVerticalAnchors + headerLeftAnchor, rowCode)
    } else {
        code += mascotShapeCode + mascotCode + titleSubtitleCode;
    }

    if (hasSummary) {
        var summaryTopAnchor;
        if (isHorizontal && hasArt) summaryTopAnchor = 'artShapeHolder.bottom';
        else if (headerAsOverlay && hasArt) summaryTopAnchor = 'artShapeHolder.bottom';
        else if (hasHeaderRow) summaryTopAnchor = 'row.bottom';
        else if (hasTitleContainer) summaryTopAnchor = 'headerTitleContainer.bottom';
        else if (hasMascot) summaryTopAnchor = 'mascotImage.bottom';
        else if (hasAttributes) summaryTopAnchor = 'attributesRow.bottom';
        else if (hasSubtitle) summaryTopAnchor = 'subtitleLabel.bottom';
        else if (hasTitle) summaryTopAnchor = 'titleLabel.bottom';
        else if (hasArt) summaryTopAnchor = 'artShapeHolder.bottom';
        else summaryTopAnchor = 'parent.top';

        var summaryColor;
        if (hasBackground) {
            summaryColor = summaryColorWithBackground;
        } else {
            summaryColor = 'root.scopeStyle ? root.scopeStyle.foreground : "grey"';
        }

        var summaryTopMargin = (hasMascot || hasSubtitle || hasAttributes ? 'anchors.margins' : '0');

        code += kSummaryLabelCode.arg(summaryTopAnchor).arg(summaryTopMargin).arg(summaryColor);
    }

    var touchdownAnchors;
    if (hasBackground) {
        touchdownAnchors = 'fill: backgroundLoader';
    } else if (touchdownOnArtShape) {
        touchdownAnchors = 'fill: artShapeHolder';
    } else {
        touchdownAnchors = 'fill: root'
    }
    code += kTouchdownCode.arg(touchdownAnchors);

    var implicitHeight = 'implicitHeight: ';
    if (hasSummary) {
        implicitHeight += 'summary.y + summary.height + (summary.text ? units.gu(1) : 0);\n';
    } else if (hasHeaderRow) {
        implicitHeight += 'row.y + row.height + units.gu(1);\n';
    } else if (hasMascot) {
        implicitHeight += 'mascotImage.y + mascotImage.height;\n';
    } else if (hasTitleContainer) {
        implicitHeight += 'headerTitleContainer.y + headerTitleContainer.height + units.gu(1);\n';
    } else if (hasAttributes) {
        implicitHeight += 'attributesRow.y + attributesRow.height + units.gu(1);\n';
    } else if (hasSubtitle) {
        implicitHeight += 'subtitleLabel.y + subtitleLabel.height + units.gu(1);\n';
    } else if (hasTitle) {
        implicitHeight += 'titleLabel.y + titleLabel.height + units.gu(1);\n';
    } else if (hasArt) {
        implicitHeight += 'artShapeHolder.height;\n';
    }
    // Close the AbstractButton
    code += implicitHeight + '}\n';

    return code;
}

function createCardComponent(parent, template, components) {
    var imports = 'import QtQuick 2.2; \n\
                   import Ubuntu.Components 0.1; \n\
                   import Dash 0.1;\n';
    var card = cardString(template, components);
    var code = imports + 'Component {\n' + card + '}\n';

    return Qt.createQmlObject(code, parent, "createCardComponent");
}
