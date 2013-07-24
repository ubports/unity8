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
import "../../../../Dash/Video"
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    SignalSpy {
        id: previewClickedSpy
        target: preview
        signalName: "previewImageClicked"
    }

    // The component under test
    VideoPreview {
        id: preview
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "VideoPreview"
        when: windowShown

        function test_play_button_data() {
            return [
            {tag: "playable", playable: true},
            {tag: "not playable", playable: false}
            ]
        }

        function test_play_button(data) {
            var playButton = findChild(preview, "playButton")
            preview.playable = data.playable
            compare(playButton.visible, data.playable)
        }

        function test_play_button_click() {
            preview.playable = true
            var playButton = findChild(preview, "playButton")
            mouseClick(playButton, 1, 1)
            tryCompare(previewClickedSpy, "count", 1)
        }
    }
}
