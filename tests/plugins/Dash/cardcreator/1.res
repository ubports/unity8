AbstractButton { 
                id: root; 
                property var components; 
                property var cardData; 
                property string artShapeStyle: "inset"; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                property int titleAlignment: Text.AlignLeft; 
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
                                active: cardData && cardData["art"] || false; 
                                asynchronous: root.asynchronous; 
                                visible: status == Loader.Ready; 
                                sourceComponent: Item {
                                    id: artShape;
                                    objectName: "artShape";
                                    readonly property bool doShapeItem: components["art"]["conciergeMode"] !== true;
                                    visible: image.status == Image.Ready;
                                    readonly property alias image: artImage;
                                    ShaderEffectSource {
                                        id: artShapeSource;
                                        sourceItem: artImage;
                                        anchors.centerIn: parent;
                                        width: 1;
                                        height: 1;
                                        hideSource: doShapeItem;
                                    }
                                    Loader {
                                        anchors.fill: parent;
                                        visible: artShape.doShapeItem;
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
                                    readonly property real aspect: fixedArtShapeSizeAspect > 0 ? fixedArtShapeSizeAspect : components !== undefined ? components["art"]["aspect-ratio"] : 1; 
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
                                        source: cardData && cardData["art"] || ""; 
                                        asynchronous: root.asynchronous; 
                                        width: root.width; 
                                        height: width / artShape.aspect; 
                                    } 
                                } 
                            } 
                        }
readonly property int headerHeight: titleLabel.height;
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
                        horizontalAlignment: root.titleAlignment; 
                    }
UbuntuShape {
    id: touchdown;
    objectName: "touchdown";
    anchors { fill: artShapeHolder }
    visible: root.artShapeStyle != "shadow" && root.artShapeStyle != "icon" && root.pressed;
    radius: "medium";
    borderSource: "radius_pressed.sci"
}
implicitHeight: titleLabel.y + titleLabel.height + units.gu(1);
}
