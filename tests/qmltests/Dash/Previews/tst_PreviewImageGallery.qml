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
    width: units.gu(60)
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
        name: "PreviewImageGalleryTest"
        when: windowShown

        function test_changeEmptyModel() {
            imageGallery.widgetData = sourcesModel0;
            var placeholderScreenshot = findChild(imageGallery, "placeholderScreenshot");
            compare(placeholderScreenshot.visible, true);
        }
    }
}
