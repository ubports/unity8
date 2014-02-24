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
        "source": "../../graphics/phone_background.jpg",
        "zoomable": false
    }

    property var widgetData2: {
        "source": "../graphics/phone/screenshots/gallery@12.png",
        "zoomable": true
    }

    PreviewZoomableImage {
        id: zoomableImage
        width: parent.width
        widgetData: widgetData1
        anchors.fill: parent
    }

    UT.UnityTestCase {
        name: "PreviewZoomableImageTest"
        when: windowShown

        function test_loadImage() {
            var image = findChild(zoomableImage, "image");

            zoomableImage.widgetData = widgetData0;
            tryCompare(image.state, "default");

            zoomableImage.widgetData = widgetData1;
            tryCompare(image.state, "ready");
        }

        function test_zoomable() {
            var image = findChild(zoomableImage, "image");

            zoomableImage.widgetData = widgetData2;
            waitForRendering(zoomableImage);
            tryCompare(image.state, "ready");

            waitForRendering(image);

            var oldScale = image.scale;
            var event1 = touchEvent();
            var event2 = touchEvent();
            var x1Start = zoomableImage.width*2/6;
            var y1Start = zoomableImage.height*2/6;
            var x1End = zoomableImage.width*1/6;
            var y1End = zoomableImage.height*1/6;
            var x2Start = zoomableImage.width*4/6;
            var y2Start = zoomableImage.height*4/6;
            var x2End = zoomableImage.width*5/6;
            var y2End = zoomableImage.height*5/6;

            mouseMove(zoomableImage, zoomableImage.width/2, zoomableImage.height/2);
            mouseWheel(zoomableImage, zoomableImage.width/2, zoomableImage.height/2, 0, 10);

            event1.press(0, x1Start, y1Start);
            event1.commit();
            event1.press(1, x2Start, y2Start);
            event1.commit();

            for (var i=0.0; i<1.0; i+=0.02) {
                event1.move(0, x1Start+(x1End-x1Start)*i, y1Start+(y1End-y1Start)*i);
                event1.move(1, x2Start+(x2End-x2Start)*i, y2Start+(y2End-y2Start)*i);
                event1.commit();
                wait(30);
            }

            event1.release(0, x1End, y1End);
            event1.commit();
            event1.release(1, x2End, y2End);
            event1.commit();

            var newScale = image.scale;
            compare(newScale > oldScale, true, "the image should be larger than before");

        }
    }
}
