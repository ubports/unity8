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
    width: units.gu(80)
    height: units.gu(80)
    color: "lightgrey"

    property var sourcesModel0: {
        "sources": []
    }

    property var sourcesModel1: {
        "sources": [
                    "../../graphics/phone_background.jpg",
                    "../../graphics/tablet_background.jpg",
                    "../../graphics/clock@18.png"
                   ]
    }

    PreviewImageGallery {
        id: imageGallery
        width: parent.width
        widgetData: sourcesModel1
    }

    UT.UnityTestCase {
        id: testCase
        name: "PreviewImageGalleryTest"
        when: windowShown

        property Item slideShow: findChild(imageGallery.rootItem, "slideShow")
        property Item slideShowCloseButton: findChild(slideShow, "slideShowCloseButton")
        property Item slideShowListView: findChild(slideShow, "slideShowListView")

        function cleanup() {
            slideShow.visible = false;
            imageGallery.widgetData = sourcesModel1;
            waitForRendering(imageGallery);
        }

        function test_changeEmptyModel() {
            imageGallery.widgetData = sourcesModel0;
            var placeholderScreenshot = findChild(imageGallery, "placeholderScreenshot");
            compare(placeholderScreenshot.visible, true);
        }

        function test_slideShowOpenClose() {
            var image0 = findChild(imageGallery, "previewImage0");
            mouseClick(image0, image0.width / 2, image0.height / 2);
            tryCompare(slideShow, "visible", true);
            tryCompare(slideShow, "scale", 1.0);
            tryCompare(slideShowCloseButton, "visible", true);
            mouseClick(slideShowCloseButton, slideShowCloseButton.width / 2, slideShowCloseButton.height / 2);
            tryCompare(slideShow, "visible", false);
        }

        function test_slideShowShowHideHeader() {
            var image0 = findChild(imageGallery, "previewImage0");
            mouseClick(image0, image0.width / 2, image0.height / 2);
            tryCompare(slideShow, "visible", true);
            tryCompare(slideShow, "scale", 1.0);
            tryCompare(slideShowCloseButton, "visible", true);
            mouseClick(slideShow, slideShow.width / 2, slideShow.height / 2);
            tryCompare(slideShowCloseButton, "visible", false);
            mouseClick(slideShow, slideShow.width / 2, slideShow.height / 2);
            tryCompare(slideShowCloseButton, "visible", true);
        }

        function test_slideShowOpenCorrectImage_data() {
            return [
                { tag: "Image 0", index: 0 },
                { tag: "Image 1", index: 1 },
                { tag: "Image 2", index: 2 },
            ];
        }

        function test_slideShowOpenCorrectImage(data) {
            var image = findChild(imageGallery, "previewImage" + data.index);
            mouseClick(image, image.width / 2, image.height / 2);
            tryCompare(slideShow, "visible", true);
            tryCompare(slideShow, "scale", 1.0);
            tryCompare(slideShowListView, "currentIndex", data.index);
            verify(image.source === slideShowListView.currentItem.source);
        }
    }
}
