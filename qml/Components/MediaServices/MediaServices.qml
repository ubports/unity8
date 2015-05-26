/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 */

import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 1.3

FocusScope {
    id: root
    property var sourceData
    property string context: ""
    property list<Action> actions
    property Item rootItem: QuickUtils.rootItem(root)

    property alias header: headerContent.item
    property alias content: contentLoader.item
    property alias footer: footerContent.item
    property alias fullscreen: priv.fullscreen

    signal close();

    implicitHeight: {
        if (fullscreen && parent) {
            return parent.height;
        }
        return content ? content.implicitHeight : parent.height
    }

    onFullscreenChanged: {
        if (!fullscreen) rotationAction.checked = false;
    }

    OrientationHelper {
        id: orientationHelper
        automaticOrientation: false

        states: [
            State {
                name: "portrait"
                when: !rotationAction.checked
            },
            State {
                name: "landscape"
                when: rotationAction.checked
                PropertyChanges {
                    target: orientationHelper
                    orientationAngle: 90
                }
            }
        ]

        Rectangle {
            anchors.fill: contentLoader
            color: "#1B1B1B"
            opacity: 0.85
        }

        Loader {
            id: contentLoader

            sourceComponent: {
                switch (context) {
                case "video":
                    return videoComponent;
                }
                return undefined;
            }

            Component {
                id: videoComponent
                VideoPlayer {
                    id: player
                    objectName: "videoPlayer"

                    width: orientationHelper.width
                    height: orientationHelper.height

                    fixedHeight: fullscreen
                    orientation: orientationHelper.state == "portrait" ?  Qt.PortraitOrientation : Qt.LandscapeOrientation

                    screenshot: {
                        var screenshot = root.sourceData["screenshot"];
                        if (screenshot) return screenshot;

                        var source = root.sourceData["source"];
                        if (source) {
                            if (source.toString().indexOf("file://") === 0) {
                                return "image://thumbnailer/" + source.toString().substr(7);
                            }
                        }
                        return "";
                    }

                    mediaPlayer: footer ? footer.mediaPlayer : null

                    onClicked: {
                        if (mediaPlayer.availability !== MediaPlayer.Available) return;

                        if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                            mediaPlayer.play();
                        } else if (controlHideTimer.running) {
                            if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                mediaPlayer.pause();
                            } else {
                                mediaPlayer.play();
                            }
                        } else {
                            controlHideTimer.restart();
                        }
                    }
                    onPositionChanged: controlHideTimer.restart();
                }
            }
        }

        Loader {
            id: headerContent
            anchors {
                top: contentLoader.top
                left: parent.left
                right: parent.right
                topMargin: -units.gu(6)
            }
            height: units.gu(6)
            visible: false

            // eater
            MouseArea {
                anchors.fill: parent
            }

            sourceComponent: root.fullscreen ? headerComponent : undefined

            Component {
                id: headerComponent

                MediaServicesHeader {
                    onGoPrevious: {
                        rotationAction.checked = false;
                        root.close();
                    }

                    component: {
                        switch (context) {
                        case "video":
                            break;
                        }
                        return undefined;
                    }
                }
            }

            // If we interact with the bar, reset the hide timer.
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    mouse.accepted = false
                    if (controlHideTimer.running) controlHideTimer.restart()
                }
            }
        }

        Loader {
            id: footerContent
            anchors {
                left: parent.left
                right: parent.right
                bottom: contentLoader.bottom
                bottomMargin: -units.gu(7)
            }
            height: units.gu(7)
            visible: false

            sourceComponent: {
                switch (context) {
                case "video":
                    return videoControlsComponent;
                }
                return undefined;
            }
            // eater
            MouseArea {
                anchors.fill: parent
            }

            Component {
                id: videoControlsComponent
                VideoPlayerControls {
                    id: controls
                    objectName: "videoControls"

                    viewAction: rotationAction.enabled ? rotationAction : fullscreenAction
                    userActions: root.actions

                    mediaPlayer.source: {
                        if (!root.sourceData) return "";

                        var x = root.sourceData["source"];
                        if (x.toString().indexOf("video://") === 0) {
                            return x.toString().substr(6);
                        }
                        return x;
                    }
                    mediaPlayer.onPlaybackStateChanged: {
                        controlHideTimer.restart();
                    }

                    Binding {
                        target: priv
                        property: "forceControlsShown"

                        value: (fullscreen && mediaPlayer.playbackState === MediaPlayer.StoppedState) ||
                               mediaPlayer.playbackState === MediaPlayer.PausedState ||
                               interacting
                    }

                    onInteractingChanged:  {
                        controlHideTimer.restart();
                    }

                    Binding {
                        target: header
                        property: "title"
                        value: controls.mediaPlayer.metaData.title !== undefined ?
                                   controls.mediaPlayer.metaData.title :
                                   controls.mediaPlayer.source.toString().replace(/^.*[\\\/]/, '')
                        when: header != null
                    }
                }
            }

            // If we interact with the bar, reset the hide timer.
            MouseArea {
                z: 1
                anchors.fill: parent
                onPressed: {
                    mouse.accepted = false
                    if (controlHideTimer.running) controlHideTimer.restart()
                }
            }
        }
    }

    StateGroup {
        states: [
            State {
                name: "controlsShown"
                when: priv.forceControlsShown || priv.controlTimerActive
                PropertyChanges {
                    target: footerContent
                    anchors.bottomMargin: 0
                    visible: true
                }
                PropertyChanges {
                    target: headerContent
                    anchors.topMargin: 0
                    visible: true
                }
            }
        ]

        transitions: [
            Transition {
                to: "controlsShown"
                SequentialAnimation {
                    PropertyAction { target: root; property: "clip"; value: true }
                    PropertyAction { property: "visible" }
                    NumberAnimation {
                        properties: "anchors.bottomMargin,anchors.topMargin"
                        duration: UbuntuAnimation.FastDuration
                    }
                    PropertyAction { target: root; property: "clip"; value: false }
                }
            },
            Transition {
                from: "controlsShown"
                SequentialAnimation {
                    PropertyAction { target: root; property: "clip"; value: true }
                    NumberAnimation {
                        properties: "anchors.bottomMargin,anchors.topMargin"
                        duration: UbuntuAnimation.FastDuration
                    }
                    PropertyAction { property: "visible" }
                    PropertyAction { target: root; property: "clip"; value: false }
                }
            }
        ]
    }

    StateGroup {
        states: [
            State {
                name: "minimized"
                when: !priv.fullscreen
            },
            State {
                name: "fullscreen"
                when: priv.fullscreen
                ParentChange { target: root; parent: rootItem; x: 0; y: 0; width: parent.width; height: parent.height }
                PropertyChanges { target: fullscreenAction; iconName: "view-restore" }
            }
        ]

        transitions: Transition {
            ParentAnimation {
                UbuntuNumberAnimation { properties: "x,y,width,height"; duration: UbuntuAnimation.FastDuration }
            }
        }

    }

    QtObject {
        id: priv

        property bool fullscreen: false
        property bool controlTimerActive: false
        property bool forceControlsShown: false
    }

    Timer {
        id: controlHideTimer
        objectName: "controlHideTimer"
        interval: 4000
        running: false

        onRunningChanged: {
            if (running) {
                priv.controlTimerActive = true;
            }
        }
        onTriggered: priv.controlTimerActive = false;
    }

    Action {
        id: fullscreenAction
        enabled: rotationAction.enabled === false
        iconName: "view-fullscreen"

        onTriggered: priv.fullscreen = !priv.fullscreen
    }

    Action {
        id: rotationAction
        enabled: root.fullscreen === true
        iconName: "orientation-lock"

        property bool checked: false
        onTriggered: checked = !checked
    }
}
