AbstractButton { 
                id: root; 
                property var template; 
                property var components; 
                property var cardData; 
                property var artShapeBorderSource: undefined; 
                property real fontScale: 1.0; 
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
                    height: root.fixedArtShapeSize.height != -1 ? root.fixedArtShapeSize.height : artShapeLoader.height; 
                    width: root.fixedArtShapeSize.width != -1 ? root.fixedArtShapeSize.width : artShapeLoader.width; 
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
                            readonly property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1; 
                            readonly property bool aspectSmallerThanImageAspect: aspect < image.aspect; 
                            Component.onCompleted: { updateWidthHeightBindings(); if (artShapeBorderSource !== undefined) borderSource = artShapeBorderSource; } 
                            onAspectSmallerThanImageAspectChanged: updateWidthHeightBindings(); 
                            visible: image.status == Image.Ready; 
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
                                objectName: "artImage"; 
                                source: cardData && cardData["art"] || ""; 
                                cache: true; 
                                asynchronous: root.asynchronous; 
                                fillMode: components && components["art"]["fill-mode"] === "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop; 
                                readonly property real aspect: implicitWidth / implicitHeight; 
                                width: root.width; 
                                height: width / artShape.aspect;
                            } 
                        } 
                    } 
                }
readonly property int headerHeight: titleLabel.height + titleLabel.anchors.topMargin * 2;
Label { 
                    id: titleLabel; 
                    objectName: "titleLabel"; 
                    anchors { right: parent.right;left: parent.left;
top: artShapeHolder.bottom; 
                                         topMargin: units.gu(1);
leftMargin: units.gu(1);
 }
                    elide: Text.ElideRight; 
                    fontSize: "small"; 
                    wrapMode: Text.Wrap; 
                    maximumLineCount: 2; 
                    font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                    color: "grey"; 
                    visible: showHeader ; 
                    text: root.title; 
                    font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; 
                    horizontalAlignment: root.headerAlignment; 
                }
implicitHeight: titleLabel.y + titleLabel.height + units.gu(1);
}
