/*
 * Copyright 2014,2015 Canonical Ltd.
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
    color: theme.palette.selected.background

    property var widgetData0: { "visible": "both", "required": "both", author: "Some dude", rating: 4.5, review: "Very cool app" }

    PreviewRatingEdit {
        id: previewRatingEdit
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: widgetData0
        widgetId: "previewRatingInput"
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    UT.UnityTestCase {
        name: "PreviewRatingEditTest"
        when: windowShown

        function test_switch_and_trigger(data) {
            spy.target = previewRatingEdit;

            var authorLabel = findChild(previewRatingEdit, "authorLabel");
            var reviewTextArea = findChild(previewRatingEdit, "reviewTextArea");
            var inputRating = findChild(findChild(previewRatingEdit, "input"), "rating");
            verify(authorLabel.visible)
            verify(!reviewTextArea.visible)

            var editButton = findChild(previewRatingEdit, "editButton");
            mouseClick(editButton);
            verify(!authorLabel.visible)
            verify(reviewTextArea.visible)

            compare(reviewTextArea.text, "Very cool app");
            compare(inputRating.value, 4.5);

            reviewTextArea.text = "Ho Ho";
            inputRating.value = 3;

            var submitButton = findChild(previewRatingEdit, "submitButton")
            mouseClick(submitButton);

            compare(spy.count, 1);
            var args = spy.signalArguments[0];
            compare(args[0], previewRatingEdit.widgetId);
            compare(args[1], "rated");
            compare(args[2]["rating"], 3);
            compare(args[2]["review"], "Ho Ho");
            verify(args[2]["author"] !== undefined); // Just verifying it exists now
        }
    }
}
