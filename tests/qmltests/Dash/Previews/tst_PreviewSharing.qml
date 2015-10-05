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
import Ubuntu.Components 0.1
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: Theme.palette.selected.background

    property var shareUris: {
        "uri": "Text here",
        "contentType": "text"
    }

    property var shareUrisNoUri: {
        "uri": "",
        "contentType": "text"
    }

    PreviewSharing {
        id: previewSharing
        anchors { left: parent.left; bottom: parent.bottom; }
        shareUris: root.shareUris
    }

    UT.UnityTestCase {
        name: "PreviewSharingTest"
        when: windowShown

        property Item peerPicker: findChild(previewSharing.rootItem, "peerPicker")

        function cleanup() {
            peerPicker.visible = false;
            previewSharing.shareUris = root.shareUris;
        }

        function test_visible() {
            compare(previewSharing.visible, true);
            previewSharing.shareUris = shareUrisNoUri;
            compare(previewSharing.visible, false);
        }

        function test_open_picker() {
            mouseClick(previewSharing);
            compare(peerPicker.visible, true);
        }
    }
}
