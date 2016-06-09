/*
 * Copyright (C) 2016 Canonical, Ltd.
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

import QtQuick 2.4
import QtMultimedia 5.0
import Ubuntu.Components 1.3

FocusScope {
    id: root
    property var sourceData
    property string context: ""
    property list<Action> actions
    property Item rootItem: QuickUtils.rootItem(root)
    property var maximumEmbeddedHeight

    property alias header: headerContent.item
    property alias content: contentLoader.item
    property alias footer: footerContent.item
    property alias fullscreen: priv.fullscreen

    signal close();

    onFullscreenChanged: {
        if (!fullscreen) rotationAction.checked = false;
    }

    readonly property color backgroundColor: "#1B1B1B"
    readonly property color iconColor: "#F3F3E7"

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        opacity: 0.85
    }

    OrientationHelper {
        id: orientationHelper
        automaticOrientation: fullscreen

        StateGroup {
            id: orientationState

            states: [
                State {
                    name: "portrait"
                    when: !rotationAction.checked
                },
                State {
                    name: "landscape"
                    when: rotationAction.checked
                }
            ]

            transitions: [
                Transition {
                    to: "landscape"
                    SequentialAnimation {
                        PropertyAction { target: orientationHelper; property: "automaticOrientation"; value: false }
                        PropertyAction { target: orientationHelper; property: "orientationAngle"; value: 90 }
                        PropertyAction { target: orientationHelper; property: "automaticOrientation"; value: false }
                    }
                },
                Transition {
                    to: "portrait"
                    SequentialAnimation {
                        PropertyAction { target: orientationHelper; property: "automaticOrientation"; value: false }
                        PropertyAction { target: orientationHelper; property: "orientationAngle"; value: 0 }
                        PropertyAction { target: orientationHelper; property: "automaticOrientation"; value: fullscreen }
                    }
                }
            ]
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
                    maximumEmbeddedHeight: root.maximumEmbeddedHeight
                    fixedHeight: fullscreen
                    orientation: orientationState.state === "landscape" ? Qt.LandscapeOrientation : Qt.PortraitOrientation

                    playButtonBackgroundColor: root.backgroundColor
                    playButtonIconColor: root.iconColor

                    screenshot: {
                        var screenshotData = root.sourceData["screenshot"];
                        if (screenshotData) return screenshotData;

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
    }

    Loader {
        id: headerContent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: -headerContent.height
        }
        height: units.gu(6)
        visible: false

        // eater
        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor
            opacity: 0.85
            visible: headerContent.status === Loader.Ready
        }

        active: root.fullscreen
        sourceComponent: headerComponent

        Component {
            id: headerComponent

            MediaServicesHeader {
                iconColor: root.iconColor
                onGoPrevious: {
                    rotationAction.checked = false;
                    root.close();
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
            bottom: parent.bottom
            bottomMargin: -footerContent.height
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

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor
            opacity: 0.85
            visible: footerContent.status === Loader.Ready
        }

        Component {
            id: videoControlsComponent
            VideoPlayerControls {
                id: controls
                objectName: "videoControls"

                viewAction: rotationAction.enabled ? rotationAction : fullscreenAction
                userActions: root.actions
                iconColor: root.iconColor
                backgroundColor: root.backgroundColor

                mediaPlayer.source: {
                    if (!root.sourceData) return "";

                    var source = root.sourceData["source"];
                    if (source.toString().indexOf("video://") === 0) {
                        return source.toString().substr(6);
                    }
                    return source;
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
                PropertyChanges { target: root; implicitHeight: content ? content.implicitHeight : 0; }
            },
            State {
                name: "fullscreen"
                when: priv.fullscreen
                ParentChange { target: root; parent: rootItem; x: 0; y: 0; width: parent.width; }
                PropertyChanges { target: root; implicitHeight: root.parent ? root.parent.height : 0; }
                PropertyChanges { target: fullscreenAction; iconName: "view-restore"; }
            }
        ]

        transitions: Transition {
            ParentAnimation {
                UbuntuNumberAnimation { properties: "x,y,width,implicitHeight"; duration: UbuntuAnimation.FastDuration }
            }
        }
    }

    QtObject {
        id: priv

        property bool fullscreen: false
        property alias controlTimerActive: controlHideTimer.running
        property bool forceControlsShown: false
    }

    Timer {
        id: controlHideTimer
        objectName: "controlHideTimer"
        interval: 4000
        running: false
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
        iconName: "view-rotate"

        property bool checked: false
        onTriggered: checked = !checked
    }
}
