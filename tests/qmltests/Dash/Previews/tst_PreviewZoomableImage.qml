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

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: "lightgrey"

    property var widgetData0: {
        "source": ""
    }

    property var widgetData1: {
        "source": Qt.resolvedUrl("../artwork/checkers.png"),
        "zoomable": false
    }

    PreviewZoomableImage {
        id: zoomableImage
        anchors.fill: parent
        widgetData: widgetData1
    }

    UT.UnityTestCase {
        name: "PreviewZoomableImageTest"
        when: windowShown

        function test_loadImage() {
            var image = findChild(zoomableImage, "image");

            zoomableImage.widgetData = widgetData0;
            waitForRendering(zoomableImage);
            tryCompare(image, "imageState", "default");

            zoomableImage.widgetData = widgetData1;
            waitForRendering(zoomableImage);
            tryCompare(image, "imageState", "ready");
        }
    }
}
