AbstractButton { 
                id: root; 
                property var components; 
                property var cardData; 
                property string artShapeStyle: "inset"; 
                property string backgroundShapeStyle: "inset"; 
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
                                    aspect: { 
                                        switch (root.backgroundShapeStyle) { 
                                            case "inset": return UbuntuShape.Inset; 
                                            case "shadow": return UbuntuShape.DropShadow; 
                                            default: 
                                            case "flat": return UbuntuShape.Flat; 
                                        } 
                                    } 
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
                                            else return ""; 
                                        } 
                                    } 
                                    function getColor(index) { 
                                        if (cardData && typeof cardData["background"] === "object" 
                                            && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { 
                                            return cardData["background"]["elements"][index]; 
                                        } else return index === 0 ? "#E9E9E9" : undefined; 
                                    } 
                                } 
                            }
readonly property size artShapeSize: artShapeLoader.item ? Qt.size(artShapeLoader.item.width, artShapeLoader.item.height) : Qt.size(-1, -1);
Item { 
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
                                        onStatusChanged: if (status === Image.Error) source = decodeURI("%5C");
                                    } 
                                } 
                            } 
                        }
readonly property int headerHeight: row.height;
Row { 
                        id: row; 
                        objectName: "outerRow"; 
                        property real margins: units.gu(1); 
                        spacing: margins; 
                        height: root.fixedHeaderHeight != -1 ? root.fixedHeaderHeight : implicitHeight; 
                        anchors { top: artShapeHolder.bottom; 
                                         topMargin: units.gu(1);
left: parent.left;
 } 
                        anchors.right: parent.right; 
                        anchors.margins: margins; 
                        anchors.rightMargin: 0; 
                        data: [ 
                                CroppedImageMinimumSourceSize { 
                            id: mascotImage; 
                            objectName: "mascotImage"; 
                            anchors { verticalCenter: parent.verticalCenter; } 
                            source: cardData && cardData["mascot"] || ""; 
                            width: units.gu(6); 
                            height: units.gu(5.625); 
                            horizontalAlignment: Image.AlignHCenter; 
                            verticalAlignment: Image.AlignVCenter; 
                            visible: showHeader; 
                             onStatusChanged: if (status === Image.Error) source = decodeURI("%22");
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
 
                            ]
                        }
 
                                ] 
                    }
UbuntuShape { 
                        id: touchdown; 
                        objectName: "touchdown"; 
                        anchors { fill: backgroundLoader } 
                        visible: root.artShapeStyle != "shadow" && root.artShapeStyle != "icon" && root.pressed; 
                        radius: "medium"; 
                        borderSource: "radius_pressed.sci" 
                    }
implicitHeight: row.y + row.height + units.gu(1);
}
