AbstractButton { 
                id: root; 
                property var cardData; 
                property string artShapeStyle: "inset"; 
                property string backgroundShapeStyle: "inset"; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                property int fixedHeaderHeight: -1; 
                property size fixedArtShapeSize: Qt.size(-1, -1); 
                readonly property string title: cardData && cardData["title"] || ""; 
                property bool asynchronous: true; 
                property bool showHeader: true; 
                implicitWidth: childrenRect.width; 
                enabled: true;

readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);
Item  { 
                            id: artShapeHolder; 
                            height: root.fixedArtShapeSize.height > 0 ? root.fixedArtShapeSize.height : artShapeLoader.height; 
                            width: root.fixedArtShapeSize.width > 0 ? root.fixedArtShapeSize.width : artShapeLoader.width; 
                            anchors { horizontalCenter: parent.horizontalCenter; } 
                            Loader { 
                                id: artShapeLoader; 
                                objectName: "artShapeLoader"; 
                                readonly property string cardArt: cardData && cardData["art"] || decodeURI("IHAVE%5C%22ESCAPED%5C%22QUOTES%5C%22");
                                active: cardArt != "";
                                asynchronous: root.asynchronous; 
                                visible: status == Loader.Ready;
                                sourceComponent: Item {
                                    id: artShape;
                                    objectName: "artShape";
                                    visible: image.status == Image.Ready;
                                    readonly property alias image: artImage;
                                    ShaderEffectSource {
                                        id: artShapeSource;
                                        sourceItem: artImage;
                                        anchors.centerIn: parent;
                                        width: 1;
                                        height: 1;
                                        hideSource: true;
                                    }
                                    Loader {
                                        anchors.fill: parent;
                                        visible: true;
                                        sourceComponent: root.artShapeStyle === "icon" ? artShapeIconComponent : artShapeShapeComponent;
                                        Component {
                                            id: artShapeShapeComponent;
                                            UbuntuShape {
                                                source: artShapeSource;
                                                sourceFillMode: UbuntuShape.PreserveAspectCrop;
                                                radius: "medium";
                                                aspect: {
                                                    switch (root.artShapeStyle) {
                                                        case "inset": return UbuntuShape.Inset;
                                                        case "shadow": return UbuntuShape.DropShadow;
                                                        default:
                                                        case "flat": return UbuntuShape.Flat;
                                                    }
                                                }
                                            }
                                        }
                                        Component {
                                            id: artShapeIconComponent;
                                            ProportionalShape { source: artShapeSource; aspect: UbuntuShape.DropShadow; }
                                        }
                                    }
                                    readonly property real fixedArtShapeSizeAspect: (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) ? root.fixedArtShapeSize.width / root.fixedArtShapeSize.height : -1;
                                    readonly property real aspect: fixedArtShapeSizeAspect > 0 ? fixedArtShapeSizeAspect : 0.75;
                                    Component.onCompleted: { updateWidthHeightBindings(); }
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
                                        source: artShapeLoader.cardArt;
                                        asynchronous: root.asynchronous;
                                        width: root.width;
                                        height: width / artShape.aspect;
                                        onStatusChanged: if (status === Image.Error) source = decodeURI("IHAVE%5C%22ESCAPED%5C%22QUOTES%5C%22");
                                    }
                                } 
                            } 
                        }
readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin;
Label { 
                        id: titleLabel; 
                        objectName: "titleLabel"; 
                        anchors { right: parent.right;
                        left: parent.left;
                        top: artShapeHolder.bottom; 
                        topMargin: units.gu(1);
                        } 
                        elide: Text.ElideRight; 
                        fontSize: "small"; 
                        wrapMode: Text.Wrap; 
                        maximumLineCount: 2; 
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                        color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText;
                        visible: showHeader ; 
                        width: undefined;
                        text: root.title; 
                        font.weight: cardData && cardData["subtitle"] ? Font.DemiBold : Font.Normal; 
                        horizontalAlignment: Text.AlignLeft;
                    }
Label { 
                            id: subtitleLabel; 
                            objectName: "subtitleLabel"; 
                            anchors { left: titleLabel.left; 
                            leftMargin: titleLabel.leftMargin; 
                            right: titleLabel.right; 
                            top: titleLabel.bottom; 
                            } 
                            anchors.topMargin: units.dp(2);
                            elide: Text.ElideRight; 
                            maximumLineCount: 1; 
                            fontSize: "x-small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText;
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
                        }
UbuntuShape {
    id: touchdown;
    objectName: "touchdown";
    anchors { fill: artShapeHolder }
    visible: root.artShapeStyle != "shadow" && root.artShapeStyle != "icon" && root.pressed;
    radius: "medium";
    borderSource: "radius_pressed.sci"
}
implicitHeight: subtitleLabel.y + subtitleLabel.height + units.gu(1);
}
