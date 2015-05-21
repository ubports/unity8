/*
 * Copyright 2015 Canonical Ltd.
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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3
import QtMultimedia 5.0

Rectangle {
    width: units.gu(70)
    height: units.gu(80)
    color: "lightgrey"

    property var widgetData0: {
        "source": "file:///test-video1",
        "screenshot": "file:///home/nick/Pictures/IMG_20150513_132759.jpg"
    }

    property var widgetData1: {
        "source": "file:///test-video2",
        "screenshot": "file:///test-video2-screenshot"
    }

    MediaDataSource {
        source: "file:///home/nick/Videos/test-mpeg.ogv"
        duration: 60000
        metaData: {
            "title" : "TEST MPEG",
            "resolution" : { "width": 100, "height": 150 }
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

            PreviewInlineVideo {
                id: videoPlayback
                width: parent.width
                widgetData: widgetData0

                rootItem: parent
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

                UT.MouseTouchEmulationCheckbox {}
            }
        }
    }

    UT.UnityTestCase {
        name: "PreviewInlineVideoTest"
        when: windowShown

        function test_loadScreenshot() {
            var screenshot = findChild(videoPlayback, "screenshot");
            verify(screenshot !== null);

            videoPlayback.widgetData = widgetData1;
            var screenshotSource = screenshot.source
            compare(screenshotSource.toString(), "file:///test-video2-screenshot");
        }
    }
}
