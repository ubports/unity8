AbstractButton { 
                id: root; 
                property var components; 
                property var cardData; 
                property var artShapeBorderSource: undefined; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                property int titleAlignment: Text.AlignLeft; 
                property int fixedHeaderHeight: -1; 
                property size fixedArtShapeSize: Qt.size(-1, -1); 
                readonly property string title: cardData && cardData["title"] || ""; 
                property bool asynchronous: true; 
                property bool showHeader: true; 
                implicitWidth: childrenRect.width; 
                enabled: false;

onArtShapeBorderSourceChanged: { if (artShapeBorderSource !== undefined && artShapeLoader.item) artShapeLoader.item.borderSource = artShapeBorderSource; } 
readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);
Item  { 
                            id: artShapeHolder; 
                            height: root.fixedArtShapeSize.height > 0 ? root.fixedArtShapeSize.height : artShapeLoader.height; 
                            width: root.fixedArtShapeSize.width > 0 ? root.fixedArtShapeSize.width : artShapeLoader.width; 
                            anchors { horizontalCenter: parent.horizontalCenter; } 
                            Loader { 
                                id: artShapeLoader; 
                                objectName: "artShapeLoader"; 
                                active: cardData && cardData["art"] || false; 
                                asynchronous: root.asynchronous; 
                                visible: status == Loader.Ready;
                                sourceComponent: Item {
                                    id: artShape;
                                    objectName: "artShape";
                                    property bool doShapeItem: components["art"]["conciergeMode"] !== true;
                                    visible: image.status == Image.Ready;
                                    readonly property alias image: artImage;
                                    property alias borderSource: artShapeShape.borderSource;
                                    ShaderEffectSource {
                                        id: artShapeSource;
                                        sourceItem: artImage;
                                        anchors.centerIn: parent;
                                        width: 1;
                                        height: 1;
                                        hideSource: doShapeItem;
                                    }
                                    Shape {
                                        id: artShapeShape;
                                        image: artShapeSource;
                                        anchors.fill: parent;
                                        visible: doShapeItem;
                                        radius: "medium";
                                    }
                                    readonly property real fixedArtShapeSizeAspect: (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) ? root.fixedArtShapeSize.width / root.fixedArtShapeSize.height : -1;
                                    readonly property real aspect: fixedArtShapeSizeAspect > 0 ? fixedArtShapeSizeAspect : components !== undefined ? components["art"]["aspect-ratio"] : 1;
                                    Component.onCompleted: { updateWidthHeightBindings(); if (artShapeBorderSource !== undefined) borderSource = artShapeBorderSource; }
                                    Connections { target: root; onFixedArtShapeSizeChanged: updateWidthHeightBindings(); }
                                    function updateWidthHeightBindings() {
                                        if (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) {
                                            width = root.fixedArtShapeSize.width;
                                            height = root.fixedArtShapeSize.height;
                                        } else {
                                            width = Qt.binding(function() { return image.status !== Image.Ready ? 0 : image.width });
                                            height = Qt.binding(function() { return image.status !== Image.Ready ? 0 : image.height });
                                        }
                                    }
                                    CroppedImageMinimumSourceSize {
                                        id: artImage;
                                        objectName: "artImage";
                                        source: cardData && cardData["art"] || "";
                                        asynchronous: root.asynchronous;
                                        width: root.width;
                                        height: width / artShape.aspect;
                                    }
                                } 
                            }
                        }
Loader { 
                            id: overlayLoader; 
                            anchors { 
                                left: artShapeHolder.left; 
                                right: artShapeHolder.right; 
                                bottom: artShapeHolder.bottom; 
                            } 
                            active: artShapeLoader.active && artShapeLoader.item && artShapeLoader.item.image.status === Image.Ready || false;
                            asynchronous: root.asynchronous; 
                            visible: showHeader && status == Loader.Ready; 
                            sourceComponent: ShaderEffect { 
                                id: overlay; 
                                height: (fixedHeaderHeight > 0 ? fixedHeaderHeight : headerHeight) + units.gu(2);
                                property real luminance: Style.luminance(overlayColor);
                                property color overlayColor: cardData && cardData["overlayColor"] || "#99000000";
                                property var source: ShaderEffectSource { 
                                    id: shaderSource; 
                                    sourceItem: artShapeLoader.item; 
                                    onVisibleChanged: if (visible) scheduleUpdate(); 
                                    live: false; 
                                    sourceRect: Qt.rect(0, artShapeLoader.height - overlay.height, artShapeLoader.width, overlay.height); 
                                } 
                                vertexShader: " 
                                    uniform highp mat4 qt_Matrix; 
                                    attribute highp vec4 qt_Vertex; 
                                    attribute highp vec2 qt_MultiTexCoord0; 
                                    varying highp vec2 coord; 
                                    void main() { 
                                        coord = qt_MultiTexCoord0; 
                                        gl_Position = qt_Matrix * qt_Vertex; 
                                    }"; 
                                fragmentShader: " 
                                    varying highp vec2 coord; 
                                    uniform sampler2D source; 
                                    uniform lowp float qt_Opacity; 
                                    uniform highp vec4 overlayColor;
                                    void main() { 
                                        lowp vec4 tex = texture2D(source, coord); 
                                        gl_FragColor = vec4(overlayColor.r, overlayColor.g, overlayColor.b, 1) * qt_Opacity * overlayColor.a * tex.a; 
                                    }"; 
                            } 
                        }
readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin;
Label { 
                        id: titleLabel;
                        objectName: "titleLabel"; 
                        anchors { right: parent.right; 
                        rightMargin: units.gu(1); 
                        left: parent.left; 
                        leftMargin: units.gu(1); 
                        top: overlayLoader.top; 
                        topMargin: units.gu(1);
                        } 
                        elide: Text.ElideRight; 
                        fontSize: "small"; 
                        wrapMode: Text.Wrap; 
                        maximumLineCount: 2; 
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                        color: root.scopeStyle && overlayLoader.item ? root.scopeStyle.getTextColor(overlayLoader.item.luminance) : (overlayLoader.item && overlayLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                        visible: showHeader && overlayLoader.active; 
                        width: undefined;
                        text: root.title; 
                        font.weight: cardData && cardData["subtitle"] ? Font.DemiBold : Font.Normal; 
                        horizontalAlignment: root.titleAlignment; 
                    }
Label { 
                            id: subtitleLabel; 
                            objectName: "subtitleLabel"; 
                            anchors { left: titleLabel.left; 
                            leftMargin: titleLabel.leftMargin; 
                            rightMargin: units.gu(1); 
                            right: titleLabel.right; 
                            top: titleLabel.bottom; 
                            } 
                            anchors.topMargin: units.dp(2); 
                            elide: Text.ElideRight; 
                            maximumLineCount: 1; 
                            fontSize: "x-small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: root.scopeStyle && overlayLoader.item ? root.scopeStyle.getTextColor(overlayLoader.item.luminance) : (overlayLoader.item && overlayLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
                        }
UbuntuShape { 
    id: touchdown; 
    objectName: "touchdown"; 
    anchors { fill: artShapeHolder } 
    visible: root.pressed;
    radius: "medium"; 
    borderSource: "radius_pressed.sci" 
}
implicitHeight: artShapeHolder.height;
}
