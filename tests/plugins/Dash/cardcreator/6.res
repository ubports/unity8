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
readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin;
Item { 
                            id: headerTitleContainer; 
                            anchors { right: parent.right; left: parent.left;
                            top: parent.top; 
                            topMargin: units.gu(1);
                            leftMargin: units.gu(1);
                            } 
                            width: parent.width - x; 
                            implicitHeight: titleLabel.height + subtitleLabel.height; 
                            data: [ 
                                Label { 
                        id: titleLabel; 
                        objectName: "titleLabel"; 
                        anchors { right: emblemIcon.left; 
                        rightMargin: emblemIcon.width > 0 ? units.gu(0.5) : 0; 
                        left: parent.left; 
                        top: parent.top; } 
                        elide: Text.ElideRight; 
                        fontSize: "small"; 
                        wrapMode: Text.Wrap; 
                        maximumLineCount: 2; 
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                        color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                        visible: showHeader ; 
                        text: root.title; 
                        font.weight: components && components["subtitle"] ? Font.DemiBold : Font.Normal; 
                        horizontalAlignment: root.headerAlignment; 
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
                            fontSize: "small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
                            horizontalAlignment: root.headerAlignment; 
                        }
,Icon { 
                            id: emblemIcon; 
                            objectName: "emblemIcon"; 
                            anchors { 
                            bottom: titleLabel.baseline; 
                            right: parent.right; 
                            rightMargin: units.gu(1); 
                            } 
                            source: cardData && cardData["emblem"] || ""; 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item.luminance > 0.7 ? Theme.palette.normal.baseText : "white");
                            width: height; 
                            height: source != "" ? titleLabel.font.pixelSize : 0; 
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
implicitHeight: headerTitleContainer.y + headerTitleContainer.height + units.gu(1);
}
