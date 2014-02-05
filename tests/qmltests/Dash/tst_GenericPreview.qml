/*
 * Copyright 2013 Canonical Ltd.
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
import "../../../qml/Dash/Generic"
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var calls: []
    property int counter: 0

    function get_actions_data() {
        return [
            { id: 123, displayName: "Button 1", iconHint: "image://theme/search" },
            { id: 456, displayName: "Button 2", iconHint: "image://theme/search" },
            { id: 789, displayName: "Button 3", iconHint: "image://theme/search" }
        ]
    }

    function fake_callback(id, data){
        root.calls[root.calls.length] = id;
    }

    // The component under test
    GenericPreview {
        id: genericPreview
        anchors.fill: parent

        previewData: QtObject {
            id: dataObject
            property string rendererName: "preview-generic"
            property string title: "Unity Generic Preview"
            property string subtitle: "Subtitle"
            property string description: "This is the description"
            property string image: "../../tests/qmltests/Components/tst_LazyImage/square.png"
            property var actions: get_actions_data()
            property string year: "2013"
            property var execute: fake_callback
            property var infoHints: [{displayName: "info 1", value: "value 1"},
                                    {displayName: "info 2", value: "value 2"}
                                    ]
        }
    }

    UT.UnityTestCase {
        name: "GenericPreviewTest"
        when: windowShown

        function init() {
            waitForRendering(genericPreview)
            root.calls = new Array();
        }

        function test_actions() {
            var buttons = findChild(genericPreview, "buttonList");
            compare(buttons.count, 3);

            for(var i = 0; i < buttons.count; i++) {
                var button = findChild(genericPreview, "button" + i);
                mouseClick(button, 1, 1);
                genericPreview.showProcessingAction = false;
            }

            var actions = get_actions_data();
            for(var i = 0; i < actions.length; i++) {
                compare(root.calls[i], actions[i].id);
            }
        }

        function test_title() {
            var titleLabel = findChild(genericPreview, "titleLabel");
            compare(titleLabel.text, dataObject.title)
        }

        function test_subtitle() {
            var subtitleLabel = findChild(genericPreview, "subtitleLabel");
            compare(subtitleLabel.text, dataObject.subtitle)
        }

        function test_image() {
            var image = findChild(genericPreview, "genericPreviewImage");
            tryCompare(image, "height", genericPreview.width - units.gu(6))
        }

        function test_infoHints() {
            var infoHintColumn = findChild(genericPreview, "infoHintColumn")
            var infoHintRepeater = findChild(genericPreview, "infoHintRepeater")
            compare(infoHintRepeater.count, dataObject.infoHints.length)

            for (var i = 0; i < dataObject.infoHints.length; ++i) {
                var infoItem = findChild(infoHintColumn, "infoHintItem" + i)
                var displayName = findChild(infoItem, "displayNameLabel")
                compare(displayName.text, dataObject.infoHints[i].displayName)
                var value = findChild(infoItem, "valueLabel")
                compare(value.text, dataObject.infoHints[i].value)
            }
        }

        function test_showProcessing() {
            var button = findChild(genericPreview, "button1");
            mouseClick(button, 1, 1);
            tryCompare(genericPreview, "showProcessingAction", true);
            genericPreview.previewDataChanged();
            tryCompare(genericPreview, "showProcessingAction", false);
        }
    }
}
