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
        "source": Qt.resolvedUrl("../artwork/checkers.png"),
        "zoomable": false
    }

    property var widgetData1: {
        "source": ""
    }

    PreviewZoomableImage {
        id: zoomableImage
        anchors.centerIn: parent
        widgetData: widgetData0
    }

    UT.UnityTestCase {
        name: "PreviewZoomableImageTest"
        when: windowShown

        property Item lazyImage: findChild(zoomableImage, "lazyImage");
        property Item zoomableImageContainer: findChild(zoomableImage.rootItem, "zoomableImageContainer");

        function cleanup() {
            zoomableImageContainer.visible = false;
            zoomableImage.widgetData = widgetData0;
            waitForRendering(zoomableImage);
        }

        function test_loadImage() {
            zoomableImage.widgetData = widgetData0;
            waitForRendering(zoomableImage);
            waitForRendering(lazyImage);
            tryCompare(lazyImage, "state", "ready");

            zoomableImage.widgetData = widgetData1;
            waitForRendering(zoomableImage);
            waitForRendering(lazyImage);
            tryCompare(lazyImage, "state", "default");
        }

        function test_1zoomableImageOpenClose() {
            var zoomableImageCloseButton = findChild(zoomableImageContainer, "zoomableImageCloseButton");
            mouseClick(lazyImage, lazyImage.width / 2, lazyImage.height / 2);
            tryCompare(zoomableImageContainer, "visible", true);
            tryCompare(zoomableImageContainer, "scale", 1.0);
            tryCompare(zoomableImageCloseButton, "visible", true);
            mouseClick(zoomableImageCloseButton, zoomableImageCloseButton.width / 2, zoomableImageCloseButton.height / 2);
            tryCompare(zoomableImageContainer, "visible", false);
        }
    }
}
