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
import Ubuntu.Components 1.3
import "../../../qml/Components"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: "black"

    property var shareData: {
        "uri": [
                    "file:///this/is/an/url",
                    "file:///this/is/an/url/2",
                    "file:///this/is/an/url/3"
                ],
        "content-type": "text"
    }

    property var shareDataString: {
        "uri": "file:///this/is/an/url",
        "content-type": "text"
    }

    SharingPicker {
        id: sharingPicker
        anchors { left: parent.left; bottom: parent.bottom; }
        shareData: root.shareData
    }

    UT.UnityTestCase {
        name: "SharingPickerTest"
        when: windowShown

        property Item peerPicker: findChild(sharingPicker.rootItem, "peerPicker")

        function cleanup() {
            peerPicker.visible = false;
        }

        function test_open_picker() {
            sharingPicker.showPeerPicker();
            compare(peerPicker.visible, true);
        }

        function test_createExportedItems() {
            var exportedItems = sharingPicker.createExportedItems(shareData["uri"]);
            for (var i = 0; i < exportedItems.length; i++) {
                compare(exportedItems[i].url, shareData["uri"][i]);
            }
            exportedItems = sharingPicker.createExportedItems(shareDataString["uri"]);
            compare(exportedItems[0].url, shareDataString["uri"]);
        }
    }
}
