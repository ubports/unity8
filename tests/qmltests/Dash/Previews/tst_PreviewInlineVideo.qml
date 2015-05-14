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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3

Rectangle {
    id: mainView
    width: units.gu(40)
    height: units.gu(80)
    color: "lightgrey"

    property var widgetData0: {
        "source": "video:///home/nick/Videos/test-mpeg.ogv",
        "screenshot": "/home/nick/Pictures/malta.jpg"
//        "screenshot": "image://thumbnailer/https://dl.dropboxusercontent.com/u/85539674/team11.ogg"
    }

    property var widgetData1: {
//        "source": "https://dl.dropboxusercontent.com/u/85539674/test-mpeg.ogv",
//        "screenshot": "/home/nick/Pictures/malta.jpg"
    }

    function pushPage(page) { pageStack.push(page); }
    function popPage(page) { pageStack.pop(); }

    PageStack {
        id: pageStack
        anchors.fill: parent
        anchors.margins: units.gu(5)

        PreviewInlineVideo {
            id: videoPlayback
            width: parent.width
            widgetData: widgetData0
        }
    }

    UT.UnityTestCase {
        name: "PreviewInlineVideoTest"
        when: windowShown

        function test_loadScreenshot() {
            var screenshot = findChild(videoPlayback, "screenshot");

            videoPlayback.widgetData = widgetData1;
            var screenshotSource = screenshot.source
            verify(screenshotSource.toString().indexOf("image://thumbnailer/") === 0)
        }
    }
}
