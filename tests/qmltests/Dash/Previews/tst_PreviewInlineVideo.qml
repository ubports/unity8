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
        "screenshot": Qt.resolvedUrl("../artwork/avatar.png"),
        "share-data": {
            "uri": [
                        "file:///this/is/an/url",
                        "file:///this/is/an/url/2",
                        "file:///this/is/an/url/3"
                    ],
            "content-type": "text"
        }
    }

    property var widgetData1: {
        "source": "file:///test-video2",
        "screenshot": "file:///test-video2-screenshot"
    }

    MediaDataSource {
        source: "file:///test-video1"
        duration: 6000000
        metaData: {
            "title" : "TEST MPEG",
            "resolution" : { "width": 1920, "height": 1080 }
        }
    }

    Item {
        anchors.fill: parent

        Item {
            id: inner
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: controls.left
            }

            Item {
                anchors.fill: parent
                anchors.margins: units.gu(2)

                PreviewInlineVideo {
                    id: videoPlayback
                    width: parent.width
                    widgetData: widgetData0

                    rootItem: inner
                }
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
