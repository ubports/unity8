/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.3
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Unity.Application 0.1
import "../Components/PanelState"
import Utils 0.1

FocusScope {
    id: root

    anchors.fill: parent

    property alias background: wallpaper.source
    property var windowStateStorage: WindowStateStorage
    property bool altTabPressed: false

    onAltTabPressedChanged: {
        print("Alt+Tab pressed:", altTabPressed)
        if (altTabPressed) {
            appRepeater.highlightedIndex = 1;
        } else {
            print("focusing app", appRepeater.highlightedIndex)
            ApplicationManager.focusApplication(ApplicationManager.get(appRepeater.highlightedIndex).appId)
        }
    }

    function altTabNext() {
        if (root.altTabPressed) {
            print("should tab next")
            appRepeater.highlightedIndex = (appRepeater.highlightedIndex + 1) % ApplicationManager.count
            spreadFlickable.snapTo(spreadFlickable.width / 5 * Math.max(0, Math.min(ApplicationManager.count - 5, appRepeater.highlightedIndex - 2)))
        }
    }

    function altTabPrevious() {
        print("alttabprevious pressed")
        if (root.altTabPressed) {
            var newIndex = appRepeater.highlightedIndex - 1 >= 0 ? appRepeater.highlightedIndex - 1 : ApplicationManager.count - 1;
            appRepeater.highlightedIndex = newIndex;
            spreadFlickable.snapTo(spreadFlickable.width / 5 * Math.max(0, Math.min(ApplicationManager.count - 5, appRepeater.highlightedIndex - 2)))
        }
    }

    CrossFadeImage {
        id: wallpaper
        anchors.fill: parent
        sourceSize { height: root.height; width: root.width }
        fillMode: Image.PreserveAspectCrop
    }

    Connections {
        target: ApplicationManager
        onApplicationAdded: {
            ApplicationManager.requestFocusApplication(ApplicationManager.get(ApplicationManager.count-1).appId)
        }

        onFocusRequested: {
            var appIndex = priv.indexOf(appId);
            var appDelegate = appRepeater.itemAt(appIndex);
            if (appDelegate.state === "minimized") {
                appDelegate.state = "normal"
            }
            appDelegate.focusWindow();
            ApplicationManager.focusApplication(appId);
        }
    }

    QtObject {
        id: priv

        readonly property string focusedAppId: ApplicationManager.focusedApplicationId
        readonly property var focusedAppDelegate: focusedAppId ? appRepeater.itemAt(indexOf(focusedAppId)) : null

        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }
    }

    Connections {
        target: PanelState
        onClose: {
            ApplicationManager.stopApplication(ApplicationManager.focusedApplicationId)
        }
        onMinimize: appRepeater.itemAt(0).state = "minimized"
        onMaximize: appRepeater.itemAt(0).state = "normal"
    }

    Binding {
        target: PanelState
        property: "buttonsVisible"
        value: priv.focusedAppDelegate !== null && priv.focusedAppDelegate.state === "maximized"
    }

    Item {
        Repeater {
            id: appRepeater
            model: ApplicationManager

            property int highlightedIndex: 1

            delegate: Item {
                id: appDelegate
                z: ApplicationManager.count - index
                y: units.gu(3)
                width: units.gu(60)
                height: units.gu(50)

                readonly property int minWidth: units.gu(10)
                readonly property int minHeight: units.gu(10)

                function focusWindow() {
                    decoratedWindow.window.forceActiveFocus();
                }

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
                    },
                    State {
                        name: "altTab"; when: root.state == "altTab"
                        PropertyChanges {
                            target: appDelegate
                            x: spreadMaths.desktopX(index, root.width, spreadFlickable.contentX)
                            y: spreadMaths.desktopY(root.height, appDelegate.height)
                            angle: spreadMaths.desktopAngle(index, spreadFlickable.contentX)
                            itemScale: spreadMaths.desktopScale(root.height, appDelegate.height)
                            itemScaleOriginY: appDelegate.height;
                            color: "green"
                            z: index
                        }
                        PropertyChanges {
                            target: darkenOverlay
                            opacity: index != appRepeater.highlightedIndex ? 0.4 : 0
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            decorationShown: false
                        }
                        PropertyChanges {
                            target: tileInfo
                            visible: true
                        }
                    }
                ]
                transitions: [
                    Transition {
                        from: "maximized,minimized,normal,"
                        to: "maximized,minimized,normal,"
                        PropertyAnimation { target: appDelegate; properties: "x,y,opacity,width,height,scale" }
                    }
                ]
                property real angle: 0
                property real itemScale: 1
                property int itemScaleOriginX: 0
                property int itemScaleOriginY: 0

                SpreadMaths {
                    id: spreadMaths
                }

                WindowMoveResizeArea {
                    target: appDelegate
                    minWidth: appDelegate.minWidth
                    minHeight: appDelegate.minHeight
                    resizeHandleWidth: units.gu(0.5)
                    windowId: model.appId // FIXME: Change this to point to windowId once we have such a thing

                    onPressed: decoratedWindow.focus = true;
                }

                DecoratedWindow {
                    id: decoratedWindow
                    anchors.fill: parent
                    application: ApplicationManager.get(index)
                    active: ApplicationManager.focusedApplicationId === model.appId

                    onFocusChanged: {
                        if (focus) {
                            ApplicationManager.requestFocusApplication(model.appId);
                        }
                    }

                    onClose: ApplicationManager.stopApplication(model.appId)
                    onMaximize: appDelegate.state = (appDelegate.state == "maximized" ? "normal" : "maximized")
                    onMinimize: appDelegate.state = "minimized"

                    transform: [
                        Scale {
                            origin.x: itemScaleOriginX
                            origin.y: itemScaleOriginY
                            xScale: itemScale
                            yScale: itemScale
                        },
                        Rotation {
                            origin { x: 0; y: (appDelegate.height - (appDelegate.height * itemScale / 2)) }
                            axis { x: 0; y: 1; z: 0 }
                            angle: appDelegate.angle
                        }
                    ]
                    Rectangle {
                        id: darkenOverlay
                        anchors.fill: parent
                        color: "black"
                        opacity: 0
                    }
                }


                RowLayout {
                    id: tileInfo
                    height: units.gu(6)
                    width: units.gu(20)
                    anchors { left: parent.left; top: parent.bottom; topMargin: units.gu(5) }
                    visible: false
                    spacing: units.gu(1)

                    UbuntuShape {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: height
                        image: Image {
                            anchors.fill: parent
                            source: model.icon
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: tileInfo.height * 0.8
                        text: model.name
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                    }
                }
            }
        }
    }

    Flickable {
        id: spreadFlickable
        anchors.fill: parent
        contentWidth: ApplicationManager.count * width / 5
        visible: false
        onContentXChanged: print("flickable flicked", contentX)

        function snapTo(contentX) {
            snapAnimation.to = contentX
            snapAnimation.start();
        }

        UbuntuNumberAnimation {
            id: snapAnimation
            target: spreadFlickable
            property: "contentX"
        }
    }

    states: [
        State {
            name: "windowed"
        },
        State {
            name: "altTab"; when: root.altTabPressed
            PropertyChanges { target: spreadFlickable; visible: true }
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "altTab"
            PropertyAction { target: spreadFlickable; property: "contentX"; value: 0 }
        }
    ]
}
