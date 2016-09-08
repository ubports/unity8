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
readonly property size artShapeSize: Qt.size(-1, -1);
readonly property int headerHeight: row.height;
Row { 
                    id: row; 
                    objectName: "outerRow"; 
                    property real margins: units.gu(1); 
                    spacing: margins; 
                    height: root.fixedHeaderHeight;
                    anchors { top: parent.top; 
                                     topMargin: units.gu(1);
                    left: parent.left;
}
                    anchors.right: parent.right; 
                    anchors.margins: margins;
                    anchors.rightMargin: 0;
data: [ 
Loader { 
                        id: mascotShapeLoader; 
                        objectName: "mascotShapeLoader"; 
                        asynchronous: true;
                        active: mascotImage.status === Image.Ready;
                        visible: showHeader && active && status === Loader.Ready;
                        width: units.gu(6); 
                        height: units.gu(5.625); 
                        sourceComponent: UbuntuShape { image: mascotImage }
                        anchors { verticalCenter: parent.verticalCenter; }
                    }

,CroppedImageMinimumSourceSize {
                    id: mascotImage; 
                    objectName: "mascotImage"; 
                    anchors { verticalCenter: parent.verticalCenter; }
                    source: cardData && cardData["mascot"] || ""; 
                    width: units.gu(6);
                    height: units.gu(5.625); 
                    horizontalAlignment: Image.AlignHCenter; 
                    verticalAlignment: Image.AlignVCenter; 
                    visible: false; 
                }

,Item { 
                            id: headerTitleContainer; 
                            anchors { verticalCenter: parent.verticalCenter;  } 
                            width: parent.width - x; 
                            implicitHeight: titleLabel.height + subtitleLabel.height; 
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
                    maximumLineCount: 2; 
                    font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                    color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText;
                    visible: showHeader ; 
                    width: undefined;
                    text: root.title; 
                    font.weight: cardData && cardData["subtitle"] ? Font.DemiBold : Font.Normal; 
                    horizontalAlignment: Text.AlignLeft;
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
                        color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText;
                        visible: titleLabel.visible && titleLabel.text; 
                        text: cardData && cardData["subtitle"] || ""; 
                        font.weight: Font.Light; 
                    }
]
}
]
}
UbuntuShape {
    id: touchdown;
    objectName: "touchdown";
    anchors { fill: root }
    visible: root.pressed;
    radius: "medium";
    borderSource: "radius_pressed.sci"
}
implicitHeight: row.y + row.height + units.gu(1);
}
