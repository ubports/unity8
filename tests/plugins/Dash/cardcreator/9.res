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
readonly property int headerHeight: titleLabel.height + subtitleLabel.height + subtitleLabel.anchors.topMargin + audioProgressBar.height + audioProgressBar.anchors.topMargin;
Label { 
                        id: titleLabel; 
                        objectName: "titleLabel"; 
                        anchors { right: parent.right; 
rightMargin: units.gu(1); 
left: audioButton.right; 
                            leftMargin: units.gu(1);
top: parent.top; 
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
rightMargin: units.gu(1); 
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
CardAudioProgress { 
                            id: audioProgressBar; 
                            duration: (cardData["quickPreviewData"] && cardData["quickPreviewData"]["duration"]) || 0; 
                            source: (cardData["quickPreviewData"] && cardData["quickPreviewData"]["uri"]) || ""; 
                            anchors { 
                                bottom: audioButton.bottom; 
                                left: audioButton.right; 
                                right: parent.right; 
                                margins: units.gu(1); 
                            } 
                            color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText; 
                         }AbstractButton { 
                            id: audioButton; 
                            anchors.fill: undefined; 
                            width: height; 
                            height: root.fixedHeaderHeight + 2 * units.gu(1);
                            readonly property url source: (cardData["quickPreviewData"] && cardData["quickPreviewData"]["uri"]) || ""; 
                            UbuntuShape { 
                                anchors.fill: parent; 
                                visible: parent.pressed; 
                                radius: "medium"; 
                            } 
                            Rectangle { 
                                color: Qt.rgba(0, 0, 0, 0.5); 
                                anchors.centerIn: parent; 
                                width: parent.width * 0.5; 
                                height: width; 
                                radius: width / 2; 
                            } 
                            Icon {  
                                anchors.centerIn: parent; 
                                width: parent.width * 0.3; 
                                height: width; 
                                opacity: 0.9; 
                                name: DashAudioPlayer.playing && AudioUrlComparer.compare(parent.source, DashAudioPlayer.currentSource) ? "media-playback-pause" : "media-playback-start"; 
                                color: "white"; 
                                asynchronous: true; 
                            }
                            onClicked: { 
                                if (AudioUrlComparer.compare(source, DashAudioPlayer.currentSource)) { 
                                    if (DashAudioPlayer.playing) { 
                                        DashAudioPlayer.pause(); 
                                    } else { 
                                        DashAudioPlayer.play(); 
                                    } 
                                } else { 
                                    var playlist = (cardData["quickPreviewData"] && cardData["quickPreviewData"]["playlist"]) || null; 
                                    DashAudioPlayer.playSource(source, playlist); 
                                } 
                            } 
                            onPressAndHold: { 
                                root.pressAndHold(); 
                            } 
                        }UbuntuShape { 
                        id: touchdown; 
                        objectName: "touchdown"; 
                        anchors { fill: root } 
                        visible: root.pressed;
                        radius: "medium"; 
                        borderSource: "radius_pressed.sci" 
                    }
implicitHeight: audioButton.height;
}
