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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: "black"

    property var shareData: {
        "uri": [
                    "Text here",
                    "text here 2",
                    "text here 3"
                ],
        "content-type": "text"
    }

    property var shareDataNoUri: {
        "uri": "",
        "content-type": "text"
    }


    PreviewMediaToolbar {
        id: previewMediaToolbar
        anchors { left: parent.left; bottom: parent.bottom; }
        shareData: root.shareData
    }

    UT.UnityTestCase {
        name: "PreviewMediaToolbarTest"
        when: windowShown

        property Item sharingWidget: findChild(previewMediaToolbar, "sharingWidget")

        function cleanup() {
            previewMediaToolbar.shareData = root.shareData;
        }

        function test_visible() {
            previewMediaToolbar.shareData = shareDataNoUri;
            compare(previewMediaToolbar.visible, false);
            compare(sharingWidget.visible, false);
            previewMediaToolbar.shareData = shareData;
            compare(previewMediaToolbar.visible, true);
            compare(sharingWidget.visible, true);
        }
    }
}
