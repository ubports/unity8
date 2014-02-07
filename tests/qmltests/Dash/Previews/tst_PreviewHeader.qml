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

    property var headerjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "../graphics/play_button.png"
    }

    PreviewHeader {
        id: previewHeader
        widgetData: headerjson
        width: units.gu(30)

        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.1
        }
    }

    UT.UnityTestCase {
        name: "PreviewHeaderTest"
        when: windowShown

        function test_json() {
            var cardHeader = findChild(previewHeader, "cardHeader");
            compare(cardHeader.title, "THE TITLE");
            compare(cardHeader.subtitle, "Something catchy");
            compare(cardHeader.mascot.toString().slice(-24), "graphics/play_button.png");
        }
    }
}
