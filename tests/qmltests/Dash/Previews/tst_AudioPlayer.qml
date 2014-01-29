/*
 * Copyright 2014 Canonical Ltd.
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
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import QtMultimedia 5.0

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: "lightgrey"

    property var tracksModel0: [
    ]

    property var tracksModel1: [
        { title: "Some track name", length: "0:30", uri: "../../tests/qmltests/Dash/Music/data/testsound1.ogg" }
    ]

    property var tracksModel2: [
        { title: "Some track name", length: "0:30", uri: "../../tests/qmltests/Dash/Music/data/testsound1.ogg" },
        { title: "Some other track name", length: "1:23", uri: "../../tests/qmltests/Dash/Music/data/testsound2.ogg" },
        { title: "And another one", length: "123:45", uri: "../../tests/qmltests/Dash/Music/data/testsound3.ogg" }
    ]

    AudioPlayer {
        id: audioPlayer
        anchors.fill: parent
        model: tracksModel0
    }

    UT.UnityTestCase {
        name: "AudioPlayerTest"
        when: windowShown

        function init() {
            waitForRendering(audioPlayer);
        }

        function test_tracks_data() {
            return [
                    {tag: "0 tracks", tracksModel: tracksModel0, dividerVisible: false},
                    {tag: "1 track", tracksModel: tracksModel1, dividerVisible: true},
                    {tag: "4 track", tracksModel: tracksModel2, dividerVisible: true}
            ];
        }

        function test_tracks(data) {
            audioPlayer.model = data.tracksModel;
            waitForRendering(audioPlayer);

            var trackRepeater = findChild(audioPlayer, "trackRepeater");
            compare(trackRepeater.count, data.tracksModel.length)

            var topDivider = findChild(audioPlayer, "topDivider");
            compare(topDivider.visible, data.dividerVisible);

            for (var i = 0; i < data.tracksModel.count; ++i) {
                var trackItem = findChild(audioPlayer, "trackItem" + i);
                var titleLabel = findChild(trackItem, "trackTitleLabel");
                compare(titleLabel.text, data.tracksModel[i]["title"])
                var timeLabel = findChild(trackItem, "timeLabel");
                compare(timeLabel.text, data.tracksModel[i]["length"])
            }
        }

        function checkPlayerUri(index) {
            var modelFilename = audioPlayer.model[index]["uri"].replace(/^.*[\\\/]/, '');
            var playerFilename = findInvisibleChild(audioPlayer, "audio").source.toString().replace(/^.*[\\\/]/, '');

            compare(modelFilename, playerFilename, "Player source is not set correctly.");
        }

        function test_playback() {
            audioPlayer.model = tracksModel2;
            waitForRendering(audioPlayer);

            var track0Item = findChild(audioPlayer, "trackItem0");
            var track1Item = findChild(audioPlayer, "trackItem1");
            var track2Item = findChild(audioPlayer, "trackItem2");

            var track0ProgressBar = findChild(track0Item, "progressBarFill");
            var track1ProgressBar = findChild(track1Item, "progressBarFill");
            var track2ProgressBar = findChild(track2Item, "progressBarFill");

            var track0PlayButton = findChild(track0Item, "playButton");
            var track1PlayButton = findChild(track1Item, "playButton");
            var track2PlayButton = findChild(track2Item, "playButton");

            var audio = findInvisibleChild(audioPlayer, "audio");

            // All progress bars must be hidden in the beginning
            compare(track0ProgressBar.visible, false);
            compare(track1ProgressBar.visible, false);
            compare(track2ProgressBar.visible, false);

            // Playing track 0 should make progress bar 0 visible
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);

            tryCompare(audio, "playbackState", Audio.PlayingState);
            checkPlayerUri(0);

            tryCompare(track0ProgressBar, "visible", true);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", false);

            // Clicking the button again should pause it. The progress bar should stay visible
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);
            tryCompare(audio, "playbackState", Audio.PausedState);
            checkPlayerUri(0);
            tryCompare(track0ProgressBar, "visible", true);

            // Continue playback
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);
            tryCompare(audio, "playbackState", Audio.PlayingState);
            checkPlayerUri(0);

            // Playing track 1 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track1PlayButton, track1PlayButton.width / 2, track1PlayButton.height / 2);

            tryCompare(audio, "playbackState", Audio.PlayingState);
            checkPlayerUri(1);

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", true);
            tryCompare(track2ProgressBar, "visible", false);

            // Playing track 2 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track2PlayButton, track2PlayButton.width / 2, track2PlayButton.height / 2);

            tryCompare(audio, "playbackState", Audio.PlayingState);
            checkPlayerUri(2);

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", true);

            // Calling stop() should make all players shut up!
            audioPlayer.stop()
            tryCompare(audio, "playbackState", Audio.StoppedState);
        }
    }
}
