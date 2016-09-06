/*
 * Copyright 2014,2015 Canonical Ltd.
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
import Ubuntu.Components 1.3
import "../../../../qml/Dash/Previews"
import Dash 0.1
import Unity.Test 0.1 as UT
import QtMultimedia 5.0

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: theme.palette.selected.background

    property var tracksModel0: {
        "tracks": [ ]
    }

    property var tracksModel1: {
        "tracks": [ { title: "Some track name", length: "30", source: "/not/existing/path/testsound1" } ]
    }

    property var tracksModel2: {
        "tracks": [ { title: "Some track name", length: "30", source: "/not/existing/path/testsound1" },
                    { title: "Some other track name", subtitle: "Subtitle", length: "83", source: "/not/existing/path/testsound2" },
                    { title: "And another one", length: "7425", source: "/not/existing/path/testsound3" } ]
    }

    PreviewAudioPlayback {
        id: previewAudioPlayback
        anchors.fill: parent
        widgetData: tracksModel2
    }

    UT.UnityTestCase {
        name: "PreviewAudioPlaybackTest"
        when: windowShown

        function init() {
            waitForRendering(previewAudioPlayback);
        }

        function test_time_formatter_data() {
            return [
                    { tag: "NaN", value: "not a number", result: "" },
                    { tag: "-1", value: -1, result: "" },
                    { tag: "0", value: 0, result: "0:00" },
                    { tag: "30", value: 30, result: "0:30" },
                    { tag: "60", value: 60, result: "1:00" },
                    { tag: "3600", value: 3600, result: "1:00:00" }
            ];
        }

        function test_time_formatter(data) {
            compare(DashAudioPlayer.lengthToString(data.value), data.result)
        }

        function test_tracks_data() {
            return [
                    {tag: "0 tracks", tracksModel: tracksModel0},
                    {tag: "1 track", tracksModel: tracksModel1},
                    {tag: "3 tracks", tracksModel: tracksModel2}
            ];
        }

        function test_tracks(data) {
            previewAudioPlayback.widgetData = data.tracksModel;
            waitForRendering(previewAudioPlayback);

            var trackRepeater = findChild(previewAudioPlayback, "trackRepeater");
            compare(trackRepeater.count, data.tracksModel["tracks"].length)

            for (var i = 0; i < data.tracksModel["tracks"].length; ++i) {
                var trackItem = findChild(previewAudioPlayback, "trackItem" + i);
                var titleLabel = findChild(trackItem, "trackTitleLabel");
                compare(titleLabel.text, data.tracksModel["tracks"][i]["title"])
                var subtitleLabel = findChild(trackItem, "trackSubtitleLabel");
                if (data.tracksModel["tracks"][i]["subtitle"] !== undefined) {
                    compare(subtitleLabel.text, data.tracksModel["tracks"][i]["subtitle"])
                } else {
                    compare(subtitleLabel.visible, false)
                }
                // not checking time label because it's formatted, the model only contains seconds
            }
        }

        function checkPlayerUrls(modelFilename, playerUrl) {
            var modelFilename = modelFilename.replace(/^.*[\\\/]/, '');
            var playerFilename = playerUrl.toString().replace(/^.*[\\\/]/, '');

            compare(modelFilename, playerFilename, "Player source is not set correctly.");
        }

        function checkPlayerSource(index) {
            checkPlayerUrls(previewAudioPlayback.widgetData["tracks"][index]["source"], DashAudioPlayer.currentSource);
        }

        function test_playback() {
            previewAudioPlayback.widgetData = tracksModel2;
            waitForRendering(previewAudioPlayback);

            var track0Item = findChild(previewAudioPlayback, "trackItem0");
            var track1Item = findChild(previewAudioPlayback, "trackItem1");
            var track2Item = findChild(previewAudioPlayback, "trackItem2");

            var track0ProgressBar = findChild(track0Item, "progressBarFill");
            var track1ProgressBar = findChild(track1Item, "progressBarFill");
            var track2ProgressBar = findChild(track2Item, "progressBarFill");

            var track0PlayButton = findChild(track0Item, "playButton");
            var track1PlayButton = findChild(track1Item, "playButton");
            var track2PlayButton = findChild(track2Item, "playButton");

            // All progress bars must be hidden in the beginning
            compare(track0ProgressBar.visible, false);
            compare(track1ProgressBar.visible, false);
            compare(track2ProgressBar.visible, false);

            // Playing track 0 should make progress bar 0 visible
            mouseClick(track0PlayButton);

            compare(DashAudioPlayer.playing, true);
            checkPlayerSource(0);

            tryCompare(track0ProgressBar, "visible", true);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", false);

            // Clicking the button again should pause it. The progress bar should stay visible
            mouseClick(track0PlayButton);
            compare(DashAudioPlayer.paused, true);
            checkPlayerSource(0);
            tryCompare(track0ProgressBar, "visible", true);

            // Continue playback
            mouseClick(track0PlayButton);
            compare(DashAudioPlayer.playing, true);
            checkPlayerSource(0);

            // Playing track 1 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track1PlayButton);

            compare(DashAudioPlayer.playing, true);
            checkPlayerSource(1);

            // Check the playlist is song 0, 1, 2
            checkPlayerUrls(tracksModel2["tracks"][0].source, DashAudioPlayer.playlist.itemSource(0));
            checkPlayerUrls(tracksModel2["tracks"][1].source, DashAudioPlayer.playlist.itemSource(1));
            checkPlayerUrls(tracksModel2["tracks"][2].source, DashAudioPlayer.playlist.itemSource(2));

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", true);
            tryCompare(track2ProgressBar, "visible", false);

            // Playing track 2 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track2PlayButton);

            compare(DashAudioPlayer.playing, true);
            checkPlayerSource(2);

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", true);
        }
    }
}
