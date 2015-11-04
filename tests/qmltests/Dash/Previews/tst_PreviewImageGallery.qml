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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(70)
    color: "lightgrey"

    property var sourcesModel0: {
        "sources": []
    }

    property var sourcesModel1: {
        "sources": [
                    "../../graphics/phone_background.jpg",
                    "../../graphics/tablet_background.jpg",
                    "../../graphics/clock@18.png",
                    "../../graphics/borked"
                   ]
    }

    property var sourcesModel1WithFallback: {
        "sources": [
                    "../../graphics/phone_background.jpg",
                    "../../graphics/tablet_background.jpg",
                    "../../graphics/clock@18.png",
                    "../../graphics/borked"
                   ]
        , "fallback": "../../graphics/clock@18.png"
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

        property Item overlay: findChild(imageGallery.rootItem, "overlay")
        property Item overlayCloseButton: findChild(overlay, "overlayCloseButton")
        property Item overlayListView: findChild(overlay, "overlayListView")

        function cleanup() {
            overlay.hide();
            tryCompare(overlay, "visible", false);
            imageGallery.widgetData = sourcesModel1;
            waitForRendering(imageGallery);
        }

        function test_changeEmptyModel() {
            imageGallery.widgetData = sourcesModel0;
            var placeholderScreenshot = findChild(imageGallery, "placeholderScreenshot");
            compare(placeholderScreenshot.visible, true);
        }

        function test_overlayOpenClose() {
            var image0 = findChild(imageGallery, "previewImage0");
            mouseClick(image0);
            tryCompare(overlay, "visible", true);
            tryCompare(overlay, "scale", 1.0);
            tryCompare(overlayCloseButton, "visible", true);
            mouseClick(overlayCloseButton);
            tryCompare(overlay, "visible", false);
        }

        function test_overlayShowHideHeader() {
            var image0 = findChild(imageGallery, "previewImage0");
            mouseClick(image0);
            tryCompare(overlay, "visible", true);
            tryCompare(overlay, "scale", 1.0);
            tryCompare(overlayCloseButton, "visible", true);
            mouseClick(overlay);
            tryCompare(overlayCloseButton, "visible", false);
            mouseClick(overlay);
            tryCompare(overlayCloseButton, "visible", true);
        }

        function test_overlayOpenCorrectImage_data() {
            return [
                { tag: "Image 0", index: 0 },
                { tag: "Image 1", index: 1 },
                { tag: "Image 2", index: 2 },
            ];
        }

        function test_overlayOpenCorrectImage(data) {
            var image = findChild(imageGallery, "previewImage" + data.index);
            mouseClick(image);
            tryCompare(overlay, "visible", true);
            tryCompare(overlay, "scale", 1.0);
            tryCompare(overlayListView, "currentIndex", data.index);
            verify(image.source === overlayListView.currentItem.source);
        }

        function test_fallback() {
            var image3 = findChild(imageGallery, "previewImage3");
            tryCompare(image3, "state", "error");
            imageGallery.widgetData = sourcesModel0;
            imageGallery.widgetData = sourcesModel1WithFallback;
            image3 = findChild(imageGallery, "previewImage3");
            tryCompare(image3, "state", "ready");
        }
    }
}
