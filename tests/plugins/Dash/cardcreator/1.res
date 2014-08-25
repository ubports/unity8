AbstractButton { 
                id: root; 
                property var template; 
                property var components; 
                property var cardData; 
                property var artShapeBorderSource: undefined; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                property int headerAlignment: Text.AlignLeft; 
                property int fixedHeaderHeight: -1; 
                property size fixedArtShapeSize: Qt.size(-1, -1); 
                readonly property string title: cardData && cardData["title"] || ""; 
                property bool asynchronous: true; 
                property bool showHeader: true; 
                implicitWidth: childrenRect.width; 
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
                                sourceComponent: UbuntuShape { 
                                    id: artShape; 
                                    objectName: "artShape"; 
                                    radius: "medium"; 
                                    visible: image.status == Image.Ready; 
                                    readonly property real fixedArtShapeSizeAspect: (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) ? root.fixedArtShapeSize.width / root.fixedArtShapeSize.height : -1; 
                                    readonly property real aspect: fixedArtShapeSizeAspect > 0 ? fixedArtShapeSizeAspect : components !== undefined ? components["art"]["aspect-ratio"] : 1; 
                                    Component.onCompleted: { updateWidthHeightBindings(); if (artShapeBorderSource !== undefined) borderSource = artShapeBorderSource; }
                                    Connections { target: root; onFixedArtShapeSizeChanged: updateWidthHeightBindings(); } 
                                    function updateWidthHeightBindings() { 
                                        if (root.fixedArtShapeSize.height > 0 && root.fixedArtShapeSize.width > 0) { 
                                            width = root.fixedArtShapeSize.width; 
                                            height = root.fixedArtShapeSize.height; 
                                        } else { 
                                            width = Qt.binding(function() { return !visible ? 0 : image.width });
                                            height = Qt.binding(function() { return !visible ? 0 : image.height });
                                        } 
                                    } 
                                    image: CroppedImageMinimumSourceSize {
                                        objectName: "artImage"; 
                                        source: cardData && cardData["art"] || ""; 
                                        cache: true; 
                                        asynchronous: root.asynchronous; 
                                        visible: false; 
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
                        color: root.scopeStyle ? root.scopeStyle.foreground : Theme.palette.normal.baseText;
                        visible: showHeader ; 
                        text: root.title; 
                        font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; 
                        horizontalAlignment: root.headerAlignment; 
                    }
UbuntuShape {
    id: touchdown;
    objectName: "touchdown";
    anchors { fill: artShapeHolder }
    visible: root.pressed;
    radius: "medium";
    borderSource: "radius_pressed.sci"
}
implicitHeight: titleLabel.y + titleLabel.height + units.gu(1);
}
