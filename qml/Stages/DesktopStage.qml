import QtQuick 2.3
import Ubuntu.Components 1.1
import Unity.Application 0.1

Item {
    id: root

    anchors.fill: parent

    Connections {
        target: ApplicationManager
        onApplicationAdded: {
            // Initial placement to avoid having the window decoration behind the panel
            appRepeater.itemAt(ApplicationManager.count-1).y = units.gu(3)
            ApplicationManager.requestFocusApplication(ApplicationManager.get(ApplicationManager.count-1).appId)
        }

        onFocusRequested: {
            var appIndex = priv.indexOf(appId);
            ApplicationManager.move(appIndex, 0);
            ApplicationManager.focusApplication(appId);
            appRepeater.itemAt(appIndex).state = "normal"
        }
    }

    QtObject {
        id: priv
        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }
    }

    Repeater {
        id: appRepeater
        model: ApplicationManager

        delegate: Item {
            id: appDelegate
            height: units.gu(30)
            width: units.gu(30)
            z: ApplicationManager.count - index

            states: [
                State {
                    name: "normal"
                },
                State {
                    name: "maximized"
                    PropertyChanges { target: appDelegate; x: 0; y: 0; width: root.width; height: root.height }
                },
                State {
                    name: "minimized"
                    PropertyChanges { target: appDelegate; x: -appDelegate.width / 2; scale: units.gu(5) / appDelegate.width; opacity: 0 }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation { target: appDelegate; properties: "x,y,opacity,width,height,scale" }
                }
            ]

            BorderImage {
                anchors {
                    fill: appDelegate
                    margins: -units.gu(2)
                }
                source: "graphics/dropshadow2gu.sci"
                opacity: .3
                Behavior on opacity { UbuntuNumberAnimation {} }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -units.gu(0.5)

                property bool resizeWidth: false
                property bool resizeHeight: false

                property int startX: 0
                property int startWidth: 0
                property int startY: 0
                property int startHeight: 0

                onPressed: {
                    ApplicationManager.requestFocusApplication(model.appId)
                    if (mouseX > width - units.gu(1)) {
                        resizeWidth = true;
                        startX = mouseX;
                        startWidth = appDelegate.width;
                    }
                    if (mouseY > height - units.gu(1)) {
                        resizeHeight = true;
                        startY = mouseY;
                        startHeight = appDelegate.height;
                    }
                    if (!resizeHeight && !resizeWidth) {
                        drag.target = appDelegate;
                    }
                }

                onMouseXChanged: {
                    if (resizeWidth) {
                        appDelegate.width = startWidth + (mouseX - startX)
                    }
                }
                onMouseYChanged: {
                    if (resizeHeight) {
                        appDelegate.height = startHeight + (mouseY - startY)
                    }
                }

                onReleased: {
                    resizeWidth = false;
                    resizeHeight = false;
                    drag.target = undefined;
                }
            }

            WindowDecoration {
                anchors { left: parent.left; top: parent.top; right: parent.right }
                height: units.gu(3)
                title: model.name
                onClose: ApplicationManager.stopApplication(model.appId)
                onMaximize: appDelegate.state = (appDelegate.state == "maximized" ? "normal" : "maximized")
                onMinimize: appDelegate.state = "minimized"
            }

            ApplicationWindow {
                anchors.fill: parent
                anchors.topMargin: units.gu(3)
                application: ApplicationManager.get(index)
                interactive: index == 0
            }
        }
    }
}
