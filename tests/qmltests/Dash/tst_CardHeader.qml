/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Unity.Test 0.1 as UT
import "../../../qml/Dash"


Rectangle {
    width: units.gu(40)
    height: units.gu(72)
    color: "lightgrey"

    CardHeader {
        id: cardHeader
        anchors { left: parent.left; right: parent.right }
    }

    Rectangle {
        anchors.fill: cardHeader
        color: "lightblue"
        opacity: 0.5
    }

    UT.UnityTestCase {
        id: testCase
        name: "CardHeader"

        when: windowShown

        property Item mascot: findChild(cardHeader, "mascotShapeLoader")
        property Item titleLabel: findChild(cardHeader, "titleLabel")
        property Item subtitleLabel: findChild(cardHeader, "subtitleLabel")
        property Item oldPriceLabel: findChild(cardHeader, "oldPriceLabel")
        property Item outerRow: findChild(cardHeader, "outerRow")
        property Item column: findChild(cardHeader, "column")

        function initTestCase() {
            verify(typeof testCase.mascot === "object", "Couldn't find mascot object.");
            verify(typeof testCase.titleLabel === "object", "Couldn't find titleLabel object.");
            verify(typeof testCase.subtitleLabel === "object", "Couldn't find subtitleLabel object.");
            verify(typeof testCase.oldPriceLabel === "object", "Couldn't find oldPriceLabel object.");
        }

        function cleanup() {
            cardHeader.mascot = "";
            cardHeader.title = "";
            cardHeader.subtitle = "";
        }

        function test_mascot_data() {
            return [
                        { tag: "Empty", source: "", visible: false },
                        { tag: "Invalid", source: "bad_path", visible: false },
                        { tag: "Valid", source: Qt.resolvedUrl("artwork/avatar.png"), visible: true },
            ]
        }

        function test_mascot(data) {
            cardHeader.mascot = data.source;
            tryCompare(testCase.mascot, "visible", data.visible);
        }

        function test_labels_data() {
            return [
                        { tag: "Empty", visible: false },
                        { tag: "Title only", title: "Foo", visible: true },
                        { tag: "Subtitle only", subtitle: "Bar", visible: false },
                        { tag: "Both", title: "Foo", subtitle: "Bar", visible: true },
            ]
        }

        function test_labels(data) {
            cardHeader.title = data.title !== undefined ? data.title : "";
            cardHeader.subtitle = data.subtitle !== undefined ? data.subtitle : "";
            tryCompare(cardHeader, "visible", data.visible);
        }

        function test_dimensions_data() {
            return [
                { tag: "Column width", object: column, width: cardHeader.width },
                { tag: "Column width with mascot", object: column, width: cardHeader.width - mascot.width - outerRow.margins * 3, mascot: "artwork/avatar.png" },
                { tag: "Header height", object: cardHeader, height: function() { return outerRow.height + outerRow.margins * 2 } },
            ]
        }

        function test_dimensions(data) {
            if (data.hasOwnProperty("mascot")) {
                cardHeader.mascot = data.mascot;
            }

            if (data.hasOwnProperty("width")) {
                tryCompare(data.object, "width", data.width);
            }

            if (data.hasOwnProperty("height")) {
                tryCompareFunction(function() { return data.object.height === data.height() }, true);
            }
        }
    }
}
