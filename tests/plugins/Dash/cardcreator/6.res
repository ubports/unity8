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

Loader {
                                id: backgroundLoader; 
                                objectName: "backgroundLoader"; 
                                anchors.fill: parent; 
                                asynchronous: root.asynchronous; 
                                visible: status == Loader.Ready; 
                                sourceComponent: UbuntuShape { 
                                    objectName: "background"; 
                                    radius: "medium"; 
                                    backgroundColor: getColor(0) || "white"; 
                                    secondaryBackgroundColor: getColor(1) || backgroundColor; 
                                    backgroundMode: UbuntuShape.VerticalGradient;
                                    anchors.fill: parent;
                                    source: backgroundImage.source ? backgroundImage : null; 
                                    property real luminance: Style.luminance(backgroundColor); 
                                    property Image backgroundImage: Image { 
                                        objectName: "backgroundImage"; 
                                        source: { 
                                            if (cardData && typeof cardData["background"] === "string") return cardData["background"]; 
                                            else return "http://assets.ubuntu.com/sites/ubuntu/latest/u/img/logos/logo-ubuntu-grey.png";
                                        } 
                                    } 
                                    function getColor(index) { 
                                        if (cardData && typeof cardData["background"] === "object" 
                                            && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { 
                                            return cardData["background"]["elements"][index]; 
                                        } else return index === 0 ? undefined : undefined;
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
                        color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? theme.palette.normal.baseText : "white");
                        visible: showHeader ; 
                        width: undefined;
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
                            maximumLineCount: 1; 
                            fontSize: "x-small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? theme.palette.normal.baseText : "white");
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
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
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? theme.palette.normal.baseText : "white");
                            height: source != "" ? titleLabel.font.pixelSize : 0; 
                            width: implicitWidth > 0 && implicitHeight > 0 ? (implicitWidth / implicitHeight * height) : implicitWidth;
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
