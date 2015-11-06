/*
 * Copyright 2015 Canonical Ltd.
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
    color: Theme.palette.selected.background

    property string validInputText: "Great!"
    property string invalidInputText: ""

    property var widgetDataNewLabels: { "submit-label": "TestSubmitLabel" }

    PreviewCommentInput {
        id: previewCommentInput
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: widgetDataNewLabels
        widgetId: "previewCommentInput"
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    UT.UnityTestCase {
        name: "PreviewCommentInputTest"
        when: windowShown

        property var commentTextArea: findChild(previewCommentInput, "commentTextArea")
        property var submitButton: findChild(previewCommentInput, "submitButton")

        function init() {
            commentTextArea.text = "";
        }

        function test_labels() {
            previewCommentInput.widgetData = widgetDataNewLabels;
            compare(submitButton.text, widgetDataNewLabels["submit-label"]);
        }

        function test_submit_data() {
            return [
                {tag: "empty review", inputText: invalidInputText, emitted: false},
                {tag: "filled review", inputText: validInputText, emitted: true},
            ];
        }

        function test_submit(data) {
            spy.clear();
            spy.target = previewCommentInput;

            commentTextArea.text = data.inputText;
            mouseClick(submitButton);
            if (!data.emitted) {
                compare(spy.count, 0);
            } else {
                compare(spy.count, 1);
                var args = spy.signalArguments[0];
                compare(args[2]["comment"], data.inputText);
            }
        }
    }
}
