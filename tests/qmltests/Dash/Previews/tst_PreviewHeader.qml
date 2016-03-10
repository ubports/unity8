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
    width: units.gu(60)
    height: units.gu(80)

    property var origHeaderjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "../graphics/play_button.png",
        "attributes": [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}]
    }

    property var headerjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "../graphics/play_button.png",
        "attributes": [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}]
    }

    property var brokenheaderjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "bad_path",
        "fallback": "",
        "attributes": [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}]
    }

    property var fallbackheaderjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "bad_path2",
        "fallback": "../graphics/play_button.png",
        "attributes": [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}]
    }

    property var emptyfallbackheaderjson: {
        "title": "THE TITLE",
        "subtitle": "Something catchy",
        "mascot": "",
        "fallback": "../graphics/play_button.png",
        "attributes": [{"value":"text1","icon":"image://theme/ok"},{"value":"text2","icon":"image://theme/cancel"}]
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
        id: testCase
        name: "PreviewHeaderTest"
        when: windowShown

        property Item mascotShapeLoader: findChild(previewHeader, "mascotShapeLoader")
        property Item outerRow: findChild(previewHeader, "outerRow")
        property Item column: findChild(previewHeader, "column")

        function initTestCase() {
            verify(typeof testCase.mascotShapeLoader === "object", "Couldn't find mascot loader object.");
            verify(typeof testCase.outerRow === "object", "Couldn't find outerRow object.");
            verify(typeof testCase.column === "object", "Couldn't find column object.");

            headerjson.mascot = "";
            headerjson.title = "";
            headerjson.subtitle = "";
            previewHeader.widgetData = headerjson;
        }

        function test_mascot_data() {
            return [
                        { tag: "Empty", source: "", loaderVisible: false, visible: false },
                        { tag: "Invalid", source: "bad_path", loaderVisible: true, visible: false },
                        { tag: "Valid", source: "../graphics/play_button.png", loaderVisible: true, visible: true },
            ]
        }

        function test_mascot(data) {
            headerjson.mascot = data.source;
            previewHeader.widgetData = headerjson;

            tryCompare(testCase.mascotShapeLoader, "visible", data.loaderVisible);
            if (data.loaderVisible) {
                tryCompareFunction(function() { return findChild(previewHeader, "mascotShape") != null }, true);
                var mascot = findChild(previewHeader, "mascotShape")
                tryCompare(mascot, "visible", data.visible);
            }
        }

        function test_dimensions_data() {
            return [
                { tag: "Column width with mascot", object: column, width: previewHeader.width - mascotShapeLoader.width - outerRow.margins * 3, mascot: "artwork/avatar.png" },
                { tag: "Header height", object: previewHeader, height: function() { return outerRow.height + outerRow.margins * 2 } },
            ]
        }

        function test_dimensions(data) {
            if (data.hasOwnProperty("mascot")) {
                headerjson.mascot = data.mascot;
            }
            previewHeader.widgetData = headerjson;

            if (data.hasOwnProperty("width")) {
                tryCompare(data.object, "width", data.width);
            }

            if (data.hasOwnProperty("height")) {
                tryCompareFunction(function() { return data.object.height === data.height() }, true);
            }
        }

        function test_json() {
            headerjson = origHeaderjson;
            previewHeader.widgetData = headerjson;

            var innerPreviewHeader = findChild(previewHeader, "innerPreviewHeader");
            compare(innerPreviewHeader.title, "THE TITLE");
            compare(innerPreviewHeader.subtitle, "Something catchy");
            compare(innerPreviewHeader.mascot.toString().slice(-24), "graphics/play_button.png");
        }

        function test_fallback() {
            previewHeader.widgetData = brokenheaderjson;
            tryCompareFunction(function() { return findChild(previewHeader, "mascotShape") != null }, true);
            var mascot = findChild(previewHeader, "mascotShape");
            compare(mascot.visible, false);

            previewHeader.widgetData = {};
            previewHeader.widgetData = fallbackheaderjson;
            tryCompareFunction(function() { return findChild(previewHeader, "mascotShape") != null }, true);
            var mascot = findChild(previewHeader, "mascotShape");
            tryCompare(mascot, "visible", true);
            tryCompare(mascot.source, "status", Image.Ready);

            previewHeader.widgetData = {};
            previewHeader.widgetData = emptyfallbackheaderjson;
            tryCompareFunction(function() { return findChild(previewHeader, "mascotShape") != null }, true);
            var mascot = findChild(previewHeader, "mascotShape");
            tryCompare(mascot, "visible", true);
            tryCompare(mascot.source, "status", Image.Ready);
        }
    }
}
