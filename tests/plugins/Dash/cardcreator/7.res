AbstractButton { 
                id: root; 
                property var template; 
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
Loader {
                                id: backgroundLoader; 
                                objectName: "backgroundLoader"; 
                                anchors.fill: parent; 
                                asynchronous: root.asynchronous; 
                                visible: status == Loader.Ready; 
                                sourceComponent: UbuntuShape { 
                                    objectName: "background"; 
                                    radius: "medium"; 
                                    color: getColor(0) || "white"; 
                                    gradientColor: getColor(1) || color; 
                                    anchors.fill: parent; 
                                    image: backgroundImage.source ? backgroundImage : null; 
                                    property real luminance: Style.luminance(color); 
                                    property Image backgroundImage: Image { 
                                        objectName: "backgroundImage"; 
                                        source: { 
                                            if (cardData && typeof cardData["background"] === "string") return cardData["background"]; 
                                            else if (template && typeof template["card-background"] === "string") return template["card-background"]; 
                                            else return ""; 
                                        } 
                                    } 
                                    function getColor(index) { 
                                        if (cardData && typeof cardData["background"] === "object" 
                                            && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { 
                                            return cardData["background"]["elements"][index]; 
                                        } else if (template && typeof template["card-background"] === "object" 
                                                && (template["card-background"]["type"] === "color" || template["card-background"]["type"] === "gradient"))  { 
                                            return template["card-background"]["elements"][index]; 
                                        } else return undefined; 
                                    } 
                                } 
                            }
readonly property size artShapeSize: Qt.size(-1, -1);
readonly property int headerHeight: row.height;
Row { 
                        id: row; 
                        objectName: "outerRow"; 
                        property real margins: units.gu(1); 
                        spacing: margins; 
                        height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight; 
                        anchors { top: parent.top; 
                        topMargin: units.gu(1);
                        left: parent.left;
                        } 
                        anchors.right: parent.right; 
                        anchors.margins: margins;
                        anchors.rightMargin: 0;
                        data: [ 
Image { 
                            id: mascotImage; 
                            objectName: "mascotImage"; 
                            anchors { verticalCenter: parent.verticalCenter; } 
                            readonly property int maxSize: Math.max(width, height) * 4; 
                            source: cardData && cardData["mascot"] || ""; 
                            width: units.gu(6); 
                            height: units.gu(5.625); 
                            sourceSize { width: maxSize; height: maxSize } 
                            fillMode: Image.PreserveAspectCrop; 
                            horizontalAlignment: Image.AlignHCenter; 
                            verticalAlignment: Image.AlignVCenter; 
                            visible: showHeader; 
                        }

,Item { 
                            id: headerTitleContainer; 
                            anchors { verticalCenter: parent.verticalCenter;  } 
                            width: parent.width - x; 
                            implicitHeight: titleLabel.height + subtitleLabel.height + attributesRow.height; 
                            data: [ 
                                Label { 
                        id: titleLabel; 
                        objectName: "titleLabel"; 
                        anchors { right: parent.right; 
                        rightMargin: units.gu(1); 
                        left: parent.left; 
                        top: parent.top; } 
                        elide: Text.ElideRight; 
                        fontSize: "small"; 
                        wrapMode: Text.Wrap; 
                        maximumLineCount: horizontalAlignment === Text.AlignHCenter ? 1 : 2; 
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                        color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                        visible: showHeader ; 
                        text: root.title; 
                        font.weight: cardData && cardData["subtitle"] ? Font.DemiBold : Font.Normal; 
                        horizontalAlignment: root.titleAlignment; 
                    }
,Label { 
                            id: subtitleLabel; 
                            objectName: "subtitleLabel"; 
                            anchors { right: parent.right; 
                            left: parent.left; 
                            rightMargin: units.gu(1); 
                            top: titleLabel.bottom; 
                            } 
                            anchors.topMargin: units.dp(2); 
                            elide: Text.ElideRight; 
                            fontSize: "x-small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
                        }
,CardAttributes { 
                            id: attributesRow; 
                            objectName: "attributesRow"; 
                            anchors { right: parent.right;
                            left: parent.left;
                            rightMargin: units.gu(1);
                            top: subtitleLabel.bottom; 
                            } 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                            fontScale: root.fontScale; 
                            model: cardData && cardData["attributes"]; 
                          }
 
                    ]
                }
 
                                ] 
                    }
UbuntuShape {
    id: touchdown;
    objectName: "touchdown";
    anchors { fill: backgroundLoader }
    visible: root.pressed;
    radius: "medium";
    borderSource: "radius_pressed.sci"
}
implicitHeight: row.y + row.height + units.gu(1);
}
