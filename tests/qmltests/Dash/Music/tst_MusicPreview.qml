/*
 * Copyright 2013 Canonical Ltd.
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
import "../../../../qml/Dash/Music"
import Unity.Test 0.1 as UT
import QtMultimedia 5.0

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: "lightgrey"

    MusicPreview {
        id: musicPreview
        anchors.fill: parent
        isCurrent: true

        previewData: QtObject {
            property string rendererName: "preview-music"
            property string title: "Music Preview"
            property string subtitle: "Subtitle"
            property string description: "This is the description"
            property string image: "../../tests/qmltests/Components/tst_LazyImage/square.png"
            property var actions: [
                { id: 123, displayName: "Play"},
                { id: 456, displayName: "Show in folder"}
            ]
            property var tracks: tracksModel2
        }
    }

    ListModel {
        id: tracksModel0
    }
    ListModel {
        id: tracksModel1
        ListElement { uri: "../../tests/qmltests/Dash/Music/data/testsound1.ogg"; trackNo: 1; title: "Some track name"; length: "0:30"}
    }
    ListModel {
        id: tracksModel2
        ListElement { uri: "../../tests/qmltests/Dash/Music/data/testsound1.ogg"; trackNo: 1; title: "Some track name"; length: "0:30"}
        ListElement { uri: "../../tests/qmltests/Dash/Music/data/testsound1.ogg"; trackNo: 2; title: "Some track name"; length: "0:30"}
        ListElement { uri: "../../tests/qmltests/Dash/Music/data/testsound2.ogg"; trackNo: 3; title: "Some other track name"; length: "1:23"}
        ListElement { uri: "../../tests/qmltests/Dash/Music/data/testsound3.ogg"; trackNo: 4; title: "And another one"; length: "123:45"}
    }

    UT.UnityTestCase {
        name: "MusicPreviewTest"
        when: windowShown

        function init() {
            waitForRendering(musicPreview);
        }

        function test_tracks_data() {
            return [
                        {tag: "0 tracks", tracksModel: tracksModel0, dividerVisible: false},
                        {tag: "1 track", tracksModel: tracksModel1, dividerVisible: true},
                        {tag: "4 track", tracksModel: tracksModel2, dividerVisible: true}
            ];
        }

        function test_tracks(data) {
            musicPreview.previewData.tracks = data.tracksModel;
            waitForRendering(musicPreview);

            var trackRepeater = findChild(musicPreview, "trackRepeater");
            compare(trackRepeater.count, data.tracksModel.count)

            var topDivider = findChild(musicPreview, "topDivider");
            compare(topDivider.visible, data.dividerVisible);

            for (var i = 0; i < data.tracksModel.count; ++i) {
                var trackItem = findChild(musicPreview, "trackItem" + i);
                var titleLabel = findChild(trackItem, "trackTitleLabel");
                compare(titleLabel.text, data.tracksModel.get(i).title)
                var timeLabel = findChild(trackItem, "timeLabel");
                compare(timeLabel.text, data.tracksModel.get(i).length)
            }
        }

        function checkPlayerUri(index) {
            var modelFilename = musicPreview.previewData.tracks.get(index).uri.replace(/^.*[\\\/]/, '');
            var playerFilename = findInvisibleChild(musicPreview, "audioPlayer").source.toString().replace(/^.*[\\\/]/, '');

            compare(modelFilename, playerFilename, "Player source is not set correctly.");
        }

        function test_playback() {
            musicPreview.previewData.tracks = tracksModel2;
            waitForRendering(musicPreview);

            var track0Item = findChild(musicPreview, "trackItem0");
            var track1Item = findChild(musicPreview, "trackItem1");
            var track2Item = findChild(musicPreview, "trackItem2");

            var track0ProgressBar = findChild(track0Item, "progressBarFill");
            var track1ProgressBar = findChild(track1Item, "progressBarFill");
            var track2ProgressBar = findChild(track2Item, "progressBarFill");

            var track0PlayButton = findChild(track0Item, "playButton");
            var track1PlayButton = findChild(track1Item, "playButton");
            var track2PlayButton = findChild(track2Item, "playButton");

            var audioPlayer = findInvisibleChild(musicPreview, "audioPlayer");

            // All progress bars must be hidden in the beginning
            compare(track0ProgressBar.visible, false);
            compare(track1ProgressBar.visible, false);
            compare(track2ProgressBar.visible, false);

            // Playing track 0 should make progress bar 0 visible
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);

            tryCompare(audioPlayer, "playbackState", Audio.PlayingState);
            checkPlayerUri(0);

            tryCompare(track0ProgressBar, "visible", true);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", false);

            // Clicking the button again should pause it. The progress bar should stay visible
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);
            tryCompare(audioPlayer, "playbackState", Audio.PausedState);
            checkPlayerUri(0);
            tryCompare(track0ProgressBar, "visible", true);

            // Continue playback
            mouseClick(track0PlayButton, track0PlayButton.width / 2, track0PlayButton.height / 2);
            tryCompare(audioPlayer, "playbackState", Audio.PlayingState);
            checkPlayerUri(0);

            // Playing track 1 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track1PlayButton, track1PlayButton.width / 2, track1PlayButton.height / 2);

            tryCompare(audioPlayer, "playbackState", Audio.PlayingState);
            checkPlayerUri(1);

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", true);
            tryCompare(track2ProgressBar, "visible", false);

            // Playing track 2 should make progress bar 1 visible and hide progress bar 0 again
            mouseClick(track2PlayButton, track2PlayButton.width / 2, track2PlayButton.height / 2);

            tryCompare(audioPlayer, "playbackState", Audio.PlayingState);
            checkPlayerUri(2);

            tryCompare(track0ProgressBar, "visible", false);
            tryCompare(track1ProgressBar, "visible", false);
            tryCompare(track2ProgressBar, "visible", true);

            // Switching away from this preview should make all players shut up!
            musicPreview.isCurrent = false
            tryCompare(audioPlayer, "playbackState", Audio.StoppedState);
        }
    }
}
