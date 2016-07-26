AbstractButton { 
                id: root; 
                property var cardData; 
                property string backgroundShapeStyle: "inset"; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                readonly property string title: cardData && cardData["title"] || "";
                property bool showHeader: true;
                implicitWidth: childrenRect.width;
                enabled: true;
                property int fixedHeaderHeight: -1; 
                property size fixedArtShapeSize: Qt.size(-1, -1); 
signal action(var actionId);
readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);
Item  { 
                            id: artShapeHolder; 
                            height: root.fixedArtShapeSize.height;
                            width: root.fixedArtShapeSize.width;
                            anchors { horizontalCenter: parent.horizontalCenter; } 
                            Loader { 
                                id: artShapeLoader; 
                                objectName: "artShapeLoader"; 
                                readonly property string cardArt: cardData && cardData["art"] || "";
                                onCardArtChanged: { if (item) { item.image.source = cardArt; } }
                                active: cardArt != "";
                                asynchronous: true; 
                                visible: status == Loader.Ready; 
                                sourceComponent: Item {
                                    id: artShape;
                                    objectName: "artShape";
                                    visible: image.status == Image.Ready;
                                    readonly property alias image: artImage;
                                    UbuntuShape {
                                        anchors.fill: parent;
                                        source: artImage;
                                        sourceFillMode: UbuntuShape.PreserveAspectCrop;
                                        radius: "medium";
                                        aspect: UbuntuShape.Inset;
                                    }
                                    width: root.fixedArtShapeSize.width;
                                    height: root.fixedArtShapeSize.height;
                                    CroppedImageMinimumSourceSize {
                                        id: artImage;
                                        objectName: "artImage"; 
                                        source: artShapeLoader.cardArt;
                                        asynchronous: true;
                                        visible: false;
                                        width: root.width;
                                        height: width / (root.fixedArtShapeSize.width / root.fixedArtShapeSize.height);
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
                        horizontalAlignment: Text.AlignHCenter;
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
