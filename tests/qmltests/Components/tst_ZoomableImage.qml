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

import QtQuick 2.4
import QtTest 1.0
import "../../../qml/Components"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(30)
    height: units.gu(60)
    color: "lightgrey"

    property var widgetData0: {
        "source": "",
        "zoomable": false
    }

    property var widgetData1: {
        "source": "../../../qml/graphics/phone_background.jpg",
        "zoomable": false
    }

    property var widgetData2: {
        "source": "../../mocks/Unity/Application/resources/screenshots/gallery@12.png",
        "zoomable": true
    }

    ZoomableImage {
        id: zoomableImage
        width: parent.width
        anchors.fill: parent
        asynchronous: false
    }

    SignalSpy {
        id: signalSpy
    }

    UT.UnityTestCase {
        name: "ZoomableImageTest"
        when: windowShown

        function test_loadImage() {
            var imageRenderer = findChild(zoomableImage, "imageRenderer");

            zoomableImage.source = widgetData0["source"];
            zoomableImage.zoomable = widgetData0["zoomable"];
            waitForRendering(zoomableImage);
            tryCompare(zoomableImage, "imageStatus", Image.Null);

            signalSpy.signalName = "onStatusChanged";
            signalSpy.target = imageRenderer;
            signalSpy.clear();

            zoomableImage.source = widgetData1["source"];
            zoomableImage.zoomable = widgetData1["zoomable"];
            waitForRendering(imageRenderer);
            tryCompareFunction(function() { return get_filename(imageRenderer.source.toString()) === get_filename(widgetData1["source"]); }, true);
            waitForRendering(zoomableImage);
            tryCompare(zoomableImage, "imageStatus", Image.Ready);
            compare(signalSpy.count, 1);
            compare(imageRenderer.sourceSize.width, root.width);
            zoomableImage.zoomable = true;
            compare(imageRenderer.sourceSize.width, root.width*3);
        }

        function get_filename(a) {
            var wordsA = a.split("/");
            var filenameA = wordsA[wordsA.length-1];
            return filenameA;
        }

        function test_mousewheel() {
            var image = findChild(zoomableImage, "image");
            var imageRenderer = findChild(zoomableImage, "imageRenderer");
            var flickable = findChild(zoomableImage, "flickable");

            zoomableImage.source = widgetData2["source"];
            zoomableImage.zoomable = true;
            waitForRendering(zoomableImage);

            tryCompare(zoomableImage, "imageStatus", Image.Ready);
            tryCompareFunction(function() { return get_filename(imageRenderer.source.toString()) === get_filename(widgetData2["source"]); }, true);
            waitForRendering(image);

            // move mouse to center
            mouseMove(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2);

            var oldScale = image.scale;
            // Test Zoom-in Zoom-out twice.
            for (var c=0; c<2; c++) {
                // zoom in
                for (var i=0; i<10; i++) {
                    mouseWheel(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2, 0, 10);
                    tryCompare(image, "scale", oldScale + (i + 1) * 0.1);
                    compare(flickable.contentWidth, Math.max(imageRenderer.width * image.scale, flickable.width));
                    compare(flickable.contentHeight, Math.max(imageRenderer.height * image.scale, flickable.height));
                }

                // zoom out
                for (var i=0; i<10; i++) {
                    mouseWheel(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2, 0, -10);
                    tryCompare(image, "scale", oldScale + 1.0 - (i + 1) * 0.1);
                    compare(flickable.contentWidth, Math.max(imageRenderer.width * image.scale, flickable.width));
                    compare(flickable.contentHeight, Math.max(imageRenderer.height * image.scale, flickable.height));
                }
            }
        }

        function test_pinch_data() {
            return [ { source:widgetData2["source"],
                       zoomable:false,
                       answer1: true,
                       answer2: false,
                       answer3: true },
                     { source:widgetData2["source"],
                       zoomable:true,
                       answer1: false,
                       answer2: true,
                       answer3: false }
                   ]
        }

        function test_pinch(data) {
            var image = findChild(zoomableImage, "image");
            var imageRenderer = findChild(zoomableImage, "imageRenderer");
            var flickable = findChild(zoomableImage, "flickable");

            zoomableImage.source = data.source;
            zoomableImage.zoomable = data.zoomable;
            waitForRendering(zoomableImage);

            signalSpy.signalName = "onScaleChanged";
            signalSpy.target = image;
            signalSpy.clear();

            tryCompare(zoomableImage, "imageStatus", Image.Ready);
            tryCompareFunction(function() { return get_filename(imageRenderer.source.toString()) === get_filename(data.source); }, true);
            waitForRendering(image);

            var x1Start = zoomableImage.width * 2 / 6;
            var y1Start = zoomableImage.height * 2 / 6;
            var x1End = zoomableImage.width * 1 / 6;
            var y1End = zoomableImage.height * 1 / 6;
            var x2Start = zoomableImage.width * 4 / 6;
            var y2Start = zoomableImage.height * 4 / 6;
            var x2End = zoomableImage.width * 5 / 6;
            var y2End = zoomableImage.height * 5 / 6;

            var oldScale = image.scale;
            var newScale = -1;
            // move mouse to center
            mouseMove(zoomableImage, zoomableImage.width / 2, zoomableImage.height / 2);

            // Test Zoom-in Zoom-out twice.
            for (var c=0; c<2; c++) {
                wait(3000); // have to delay between two consequent pinch event.
                // pinch zoom-in
                touchPinch(zoomableImage, x1Start, y1Start, x1End, y1End, x2Start, y2Start, x2End, y2End);
                waitForRendering(image);

                if (newScale == -1) {
                    newScale = image.scale;
                }
                tryCompare(image, "scale", newScale);
                compare(newScale == oldScale, data.answer1, "scale factor not equal: "+ oldScale + "=?" + newScale);
                compare(newScale > oldScale, data.answer2, "scale factor didn't changed");
                compare(signalSpy.count == 0, data.answer3, "scale signal count error");
                compare(image.scale, newScale, "scale factor error");
                compare(flickable.contentWidth, Math.max(imageRenderer.width * image.scale, flickable.width));
                compare(flickable.contentHeight, Math.max(imageRenderer.height * image.scale, flickable.height));

                // try pan it a bit
                var contentX = flickable.contentX;
                var contentY = flickable.contentY;
                touchFlick(zoomableImage, units.gu(1), units.gu(1), units.gu(10), units.gu(10));
                tryCompare(flickable, "moving", false)
                tryCompareFunction(function() { return flickable.contentX != contentX && flickable.contentY != contentY; }, zoomableImage.zoomable)

                wait(3000); // have to delay between two consequent pinch event.
                // pinch zoom-out
                touchPinch(zoomableImage, x1End, y1End, x1Start, y1Start, x2End, y2End, x2Start, y2Start);
                tryCompare(image, "scale", oldScale);
                compare(flickable.contentWidth, Math.max(imageRenderer.width * image.scale, flickable.width));
                compare(flickable.contentHeight, Math.max(imageRenderer.height * image.scale, flickable.height));
            }
        }
    }
}
