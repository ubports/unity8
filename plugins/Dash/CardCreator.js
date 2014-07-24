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
                                    readonly property bool aspectSmallerThanImageAspect: aspect < image.aspect; \n\
                                    Component.onCompleted: { updateWidthHeightBindings(); if (artShapeBorderSource !== undefined) borderSource = artShapeBorderSource; } \n\
                                    onAspectSmallerThanImageAspectChanged: updateWidthHeightBindings(); \n\
                                    Connections { target: root; onFixedArtShapeSizeChanged: updateWidthHeightBindings(); } \n\
                                    function updateWidthHeightBindings() { \n\
                                        if (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) { \n\
                                            width = root.fixedArtShapeSize.width; \n\
                                            height = root.fixedArtShapeSize.height; \n\
                                        } else if (aspectSmallerThanImageAspect) { \n\
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

// %1 is used as anchors of row
// %2 is used as first child of the row
// %3 is used as second child of the row
var kHeaderRow2Code = 'Row { \n\
                        id: row; \n\
                        objectName: "outerRow"; \n\
                        property real margins: units.gu(1); \n\
                        spacing: margins; \n\
                        height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight; \n\
                        anchors { %1 } \n\
                        anchors.right: parent.right; \n\
                        anchors.margins: margins;\n\
                        data: [ %2\n\
                                ,\n\
                                %3 \n\
                                ] \n\
                    }\n';

// %1 is used as anchors of row
// %2 is used as first child of the row
// %3 is used as second child of the row
// %4 is used as third child of the row
var kHeaderRow3Code = 'Row { \n\
                        id: row; \n\
                        objectName: "outerRow"; \n\
                        property real margins: units.gu(1); \n\
                        spacing: margins; \n\
                        height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight; \n\
                        anchors { %1 } \n\
                        anchors.right: parent.right; \n\
                        anchors.margins: margins;\n\
                        data: [ %2\n\
                                ,\n\
                                %3 \n\
                                ,\n\
                                %4 \n\
                                ] \n\
                    }\n';

// %1 is used as first child of the column
// %2 is used as second child of the column
var kHeaderColumnCode = 'Column { \n\
                            anchors.verticalCenter: parent.verticalCenter; \n\
                            spacing: units.dp(2); \n\
                            width: parent.width - x;\n\
                            data: [ %1\n\
                                    ,\n\
                                    %2 \n\
                                  ] \n\
                        }\n';

// multiple column version of kHeaderColumnCode.
function kHeaderColumnCodeGenerator() {
    var headerColumnCodeTemplate = 'Column { \n\
                    anchors.verticalCenter: parent.verticalCenter; \n\
                    spacing: units.dp(2); \n\
                    width: parent.width - x;\n\
                    data: [ \n\
                        %1 \n\
                    ]\n\
                }\n';
    var args = Array.prototype.slice.call(arguments);
    var code = headerColumnCodeTemplate.arg(args.join(',\n'));
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
                            source: cardData && cardData["mascot"]; \n\
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

// %1 is used as anchors of subtitleLabel
// %2 is used as color of subtitleLabel
var kSubtitleLabelCode = 'Label { \n\
                            id: subtitleLabel; \n\
                            objectName: "subtitleLabel"; \n\
                            anchors { %1 } \n\
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
                            model: cardData["attributes"] \n\
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
    var headerAsOverlay = hasArt && template && template["overlay"] === true && (hasTitle || hasMascot);
    var hasSubtitle = hasTitle && components["subtitle"] || false;
    var hasHeaderRow = hasMascot && hasTitle;
    var hasAttributes = components["attributes"] || false;

    if (hasBackground) {
        code += kBackgroundLoaderCode;
    }

    if (hasArt) {
        code += 'onArtShapeBorderSourceChanged: { if (artShapeBorderSource !== undefined && artShapeLoader.item) artShapeLoader.item.borderSource = artShapeBorderSource; } \n';
        code += 'readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);\n';

        var widthCode, heightCode;
        var anchors;
        if (isHorizontal) {
            anchors = 'left: parent.left';
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
            anchors = 'horizontalCenter: parent.horizontalCenter;';
            widthCode = 'root.width'
            heightCode = 'width / artShape.aspect';
        }

        code += kArtShapeHolderCode.arg(anchors).arg(widthCode).arg(heightCode);
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

    var mascotShapeCode = "";
    var mascotCode = "";
    if (hasMascot) {
        var useMascotShape = !hasBackground && !headerAsOverlay;
        var anchors = "";
        if (!hasHeaderRow) {
            anchors += headerLeftAnchor;
            anchors += headerVerticalAnchors;
            if (!headerLeftAnchorHasMargin) {
                anchors += 'leftMargin: units.gu(1);\n'
            }
        } else {
            anchors = "verticalCenter: parent.verticalCenter;"
        }

        if (useMascotShape) {
            mascotShapeCode = kMascotShapeLoaderCode.arg(anchors);
        }

        var mascotImageVisible = useMascotShape ? 'false' : 'showHeader';
        mascotCode = kMascotImageCode.arg(anchors).arg(mascotImageVisible);
    }

    var summaryColorWithBackground = 'backgroundLoader.active && backgroundLoader.item && backgroundLoader.item.luminance < 0.7 ? "white" : (root.scopeStyle ? root.scopeStyle.foreground : "grey")';

    var titleSubtitleCode = "";
    if (hasTitle) {
        var color;
        if (headerAsOverlay) {
            color = '"white"';
        } else if (hasSummary) {
            color = 'summary.color';
        } else if (hasBackground) {
            color = summaryColorWithBackground;
        } else {
            color = 'root.scopeStyle ? root.scopeStyle.foreground : "grey"';
        }

        var titleAnchors;
        var subtitleAnchors;
        var attributesAnchors;
        if (hasMascot && (hasSubtitle || hasAttributes)) {
            // Using row + column
            titleAnchors = 'left: parent.left; right: parent.right';
            subtitleAnchors = titleAnchors;
            attributesAnchors = subtitleAnchors;
        } else if (hasMascot) {
            // Using row + label
            titleAnchors = 'verticalCenter: parent.verticalCenter;\n'
        } else {
            if (headerAsOverlay) {
                // Using anchors to the overlay
                titleAnchors = 'left: parent.left; \n\
                                leftMargin: units.gu(1); \n\
                                right: parent.right; \n\
                                rightMargin: units.gu(1); \n\
                                top: overlayLoader.top; \n\
                                topMargin: units.gu(1);\n';
            } else {
                // Using anchors to the mascot/parent
                titleAnchors = "right: parent.right;\n";
                titleAnchors += "rightMargin: units.gu(1);\n";
                titleAnchors += headerLeftAnchor;
                titleAnchors += headerVerticalAnchors;
                if (!headerLeftAnchorHasMargin) {
                    titleAnchors += 'leftMargin: units.gu(1);\n'
                }
            }
            subtitleAnchors = 'left: titleLabel.left; \n\
                               leftMargin: titleLabel.leftMargin; \n\
                               right: titleLabel.right; \n\
                               rightMargin: titleLabel.rightMargin; \n\
                               top: titleLabel.bottom; \n\
                               topMargin: units.dp(2);\n';
            if (hasSubtitle) {
                attributesAnchors = 'left: subtitleLabel.left; \n\
                                   leftMargin: subtitleLabel.leftMargin; \n\
                                   right: subtitleLabel.right; \n\
                                   rightMargin: subtitleLabel.rightMargin; \n\
                                   top: subtitleLabel.bottom; \n\
                                   topMargin: units.dp(2);\n';
            } else {
                attributesAnchors = subtitleAnchors;
            }
        }

        var titleLabelVisibleExtra = (headerAsOverlay ? '&& overlayLoader.active': '');
        var titleCode = kTitleLabelCode.arg(titleAnchors).arg(color).arg(titleLabelVisibleExtra);
        var subtitleCode = "";
        if (hasSubtitle) {
            subtitleCode += kSubtitleLabelCode.arg(subtitleAnchors).arg(color);
        }

        if (hasMascot && (hasSubtitle || hasAttributes)) {
            // If using row + column wrap the code in the column
            titleSubtitleCode = kHeaderColumnCode.arg(titleCode).arg(subtitleCode);
            if (hasSubtitle && hasAttributes) {
                var attributesCode = kAttributesRowCode.arg(attributesAnchors).arg(color);
                titleSubtitleCode = kHeaderColumnCodeGenerator(titleCode, subtitleCode, attributesCode);
            } else if (hasSubtitle) {
                titleSubtitleCode = kHeaderColumnCode.arg(titleCode).arg(subtitleCode);
            } else if (hasAttributes) {
                var attributesCode = kAttributesRowCode.arg(attributesAnchors).arg(color);
                titleSubtitleCode = kHeaderColumnCode.arg(titleCode).arg(attributesCode);
            }
        } else {
            titleSubtitleCode = titleCode;
            if (hasSubtitle) {
                titleSubtitleCode = titleSubtitleCode + subtitleCode;
            }
            if (hasAttributes) {
                var attributesCode = kAttributesRowCode.arg(attributesAnchors).arg(color);
                titleSubtitleCode = titleSubtitleCode + attributesCode;
            }
        }
    }

    if (hasHeaderRow) {
        if (mascotShapeCode != "") {
            code += kHeaderRow3Code.arg(headerVerticalAnchors + headerLeftAnchor).arg(mascotShapeCode).arg(mascotCode).arg(titleSubtitleCode);
        } else {
            code += kHeaderRow2Code.arg(headerVerticalAnchors + headerLeftAnchor).arg(mascotCode).arg(titleSubtitleCode);
        }
    } else {
        code += mascotShapeCode + mascotCode + titleSubtitleCode;
    }

    if (hasSummary) {
        var summaryTopAnchor;
        if (isHorizontal && hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else if (headerAsOverlay && hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else if (hasHeaderRow) summaryTopAnchor = "row.bottom";
        else if (hasMascot) summaryTopAnchor = "mascotImage.bottom";
        else if (hasAttributes) summaryTopAnchor = "attributesRow.bottom";
        else if (hasSubtitle) summaryTopAnchor = "subtitleLabel.bottom";
        else if (hasTitle) summaryTopAnchor = "titleLabel.bottom";
        else if (hasArt) summaryTopAnchor = "artShapeHolder.bottom";
        else summaryTopAnchor = "parent.top";

        var color;
        if (hasBackground) {
            color = summaryColorWithBackground;
        } else {
            color = 'root.scopeStyle ? root.scopeStyle.foreground : "grey"';
        }

        var summaryTopMargin = (hasMascot || hasSubtitle || hasAttributes ? 'anchors.margins' : '0');

        code += kSummaryLabelCode.arg(summaryTopAnchor).arg(summaryTopMargin).arg(color);
    }

    if (hasSummary) {
        code += 'implicitHeight: summary.y + summary.height + (summary.text ? units.gu(1) : 0);\n';
    } else if (hasHeaderRow) {
        code += 'implicitHeight: row.y + row.height + units.gu(1);\n';
    } else if (hasMascot) {
        code += 'implicitHeight: mascotImage.y + mascotImage.height;\n';
    } else if (hasAttributes) {
        code += 'implicitHeight: attributesRow.y + attributesRow.height + units.gu(1);\n';
    } else if (hasSubtitle) {
        code += 'implicitHeight: subtitleLabel.y + subtitleLabel.height + units.gu(1);\n';
    } else if (hasTitle) {
        code += 'implicitHeight: titleLabel.y + titleLabel.height + units.gu(1);\n';
    } else if (hasArt) {
        code += 'implicitHeight: artShapeHolder.height;\n';
    }
    // Close the AbstractButton
    code += '}\n';

    return code;
}

function createCardComponent(parent, template, components) {
    var imports = 'import QtQuick 2.2; \n\
                   import Ubuntu.Components 0.1; \n\
                   import Ubuntu.Thumbnailer 0.1;\n\
                   import Dash 0.1;\n';
    var card = cardString(template, components);
    var code = imports + 'Component {\n' + card + '}\n';

    return Qt.createQmlObject(code, parent, "createCardComponent");
}
