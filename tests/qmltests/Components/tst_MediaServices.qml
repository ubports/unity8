/*
 * Copyright 2016 Canonical Ltd.
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
import QtTest 1.0
import "../../../qml/Components/MediaServices"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3
import QtMultimedia 5.0

Rectangle {
    id: root
    width: units.gu(70)
    height: units.gu(80)
    color: "lightgrey"

    property var sourceData: {
        // TODO do we want a video or make this fake
        "source": "file:///home/nick/Videos/test-mpeg.ogv",
        "screenshot": Qt.resolvedUrl("../Dash/artwork/avatar.png")
    }

    property var sourceData2: {
        // TODO do we want a video or make this fake
        "source": "file:///home/nick/Videos/test-mpeg2.ogv",
        "screenshot": Qt.resolvedUrl("../Dash/artwork/checkers.png")
    }

    MediaDataSource {
        source: root.sourceData["source"]
        duration: 60000
        metaData: {
            "title" : "TEST MPEG",
            "resolution" : { "width": 160, "height": 90 }
        }
    }

    MediaDataSource {
        source: root.sourceData2["source"]
        duration: 30000
        metaData: {
            "title" : "TEST MPEG",
            "resolution" : { "width": 90, "height": 240 }
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: controls.left
            }
            color: "darkblue"

            MediaServices {
                id: services
                fullscreen: false
                width: parent.width
                sourceData: root.sourceData
                context: "video"

                rootItem: parent
                maximumEmbeddedHeight: undefined
            }
        }

        Rectangle {
            id: controls
            color: "darkgrey"
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: units.gu(30)

            Column {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }

                Button {
                    text: "Fullscreen"
                    onClicked: services.fullscreen = !services.fullscreen
                }
                UT.MouseTouchEmulationCheckbox {}
            }
        }
    }

    SignalSpy {
        id: serviceCloseSpy
        target: services
        signalName: "close"
    }

    UT.UnityTestCase {
        name: "VideoMediaServices"
        when: windowShown

        property int oldControlTimerInterval: 0;

        function init() {
            services.sourceData = root.sourceData
            services.context = "video";

            var controlHideTimer = findInvisibleChild(services, "controlHideTimer");
            verify(controlHideTimer !== null);
            oldControlTimerInterval = controlHideTimer.interval;
        }

        function cleanup() {
            serviceCloseSpy.clear();
            services.context = "";
            services.fullscreen = false;
            services.maximumEmbeddedHeight = undefined;
            tryCompareFunction(function() { return services.header ? services.header.visible : false }, false);
            tryCompareFunction(function() { return services.footer ? services.footer.visible : false }, false);

            var controlHideTimer = findInvisibleChild(services, "controlHideTimer");
            controlHideTimer.interval = oldControlTimerInterval;
        }

        function test_videoWidget() {
            var videoPlayer = findChild(services, "videoPlayer");
            verify(videoPlayer !== null);

            var videoControls = findChild(services, "videoControls");
            verify(videoControls !== null);
        }

        function test_tapVideoPlayerToPlayAndPause() {
            var videoPlayer = findChild(services, "videoPlayer");
            verify(videoPlayer !== null)
            tap(videoPlayer, videoPlayer.width/2, videoPlayer.height/2);

            var mediaPlayer = findInvisibleChild(services, "mediaPlayer");
            verify(mediaPlayer !== null);
            compare(mediaPlayer.playbackState, MediaPlayer.PlayingState, "Media player should be playing");

            tap(videoPlayer, videoPlayer.width/2, videoPlayer.height/2);
            compare(mediaPlayer.playbackState, MediaPlayer.PausedState, "Media player should be playing");
        }

        function test_fullscreenSwitch() {
            var mediaPlayer = findInvisibleChild(services, "mediaPlayer");
            verify(mediaPlayer !== null);
            mediaPlayer.play();
            wait(UbuntuAnimation.BriskDuration); // animation

            var button = findChild(services, "viewActionButton");
            verify(button !== null);
            tap(button);

            compare(services.fullscreen, true, "Should have switched to fullscreen mode.");
        }

        function test_HeaderVisibleOnlyWhenFullscreen() {
            services.fullscreen = false;
            compare(services.header, null, "Header should be null when not fullscreen");
            services.fullscreen = true;
            tryCompareFunction(function() { return services.header !== null }, true);
        }

        function test_ControlsShowAndHideWhenPlayed() {
            services.fullscreen = true;
            var controlHideTimer = findInvisibleChild(services, "controlHideTimer");
            controlHideTimer.interval = 100;

            var mediaPlayer = findInvisibleChild(services, "mediaPlayer");
            mediaPlayer.play();

            tryCompare(services.header, "visible", true);
            tryCompare(services.footer, "visible", true);

            tryCompare(services.header, "visible", false);
            tryCompare(services.footer, "visible", false);
        }

        function test_ControlsDontTimeOutWhenPaused() {
            services.fullscreen = true;
            var controlHideTimer = findInvisibleChild(services, "controlHideTimer");
            controlHideTimer.interval = 100;

            var mediaPlayer = findInvisibleChild(services, "mediaPlayer");
            mediaPlayer.play();
            mediaPlayer.pause();
            wait(300);

            compare(services.header.visible, true, "Header should still be visible");
            compare(services.footer.visible, true, "Footer should still be visible");
        }

        function test_close() {
            services.fullscreen = true;
            var mediaPlayer = findInvisibleChild(services, "mediaPlayer");
            mediaPlayer.play();
            mediaPlayer.pause();
            wait(UbuntuAnimation.BriskDuration); // animation

            var navigationButton = findChild(services, "navigationButton");
            verify(navigationButton !== null);

            tap(navigationButton);
            compare(serviceCloseSpy.count, 1, "close was not called");
        }

        function test_maximumVideoSize() {
            services.maximumEmbeddedHeight = root.height / 2
            services.sourceData = root.sourceData2
            verify(services.content !== null);
            tryCompare(services.content, "height", root.height/2);
        }
    }
}
