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

    property var widgetDataComplete: {
        "title": "Title here",
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    }

    property var widgetDataNoTitle: {
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    }

    property var widgetDataShortText: {
        "title": "Title here",
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus a mi vitae augue rhoncus lobortis ut rutrum metus."
    }

    PreviewTextSummary {
        id: previewTextSummary
        anchors { left: parent.left; right: parent.right }
        widgetData: widgetDataComplete
    }

    UT.UnityTestCase {
        name: "PreviewTextSummaryTest"
        when: windowShown

        property var textLabel: findChild(previewTextSummary, "textLabel")
        property var titleLabel: findChild(previewTextSummary, "titleLabel")

        function init() {
            verify(typeof textLabel === "object", "TextLabel object could not be found.")
        }

        function cleanup() {
            previewTextSummary.widgetData = widgetDataComplete
        }

        function test_optional_title() {
            // verify titleLabel is visible and textLabel is anchored below it
            compare(titleLabel.visible, true)
            tryCompare(textLabel, "y", titleLabel.height)

            // verify titleLabel disappears and textLabel moves up
            previewTextSummary.widgetData = widgetDataNoTitle
            compare(titleLabel.visible, false)
            tryCompare(textLabel, "y", 0)
        }

        function test_show_collapsed() {
            verify(textLabel.lineCount > textLabel.maximumCollapsedLineCount)

            previewTextSummary.expanded = false;
            tryCompareFunction(function() { return textLabel.height < textLabel.contentHeight; }, true)

            previewTextSummary.widgetData = widgetDataShortText
            verify(textLabel.lineCount <= textLabel.maximumCollapsedLineCount)
            tryCompare(textLabel, "height", textLabel.contentHeight)
            tryCompare(previewTextSummary, "height", titleLabel.height + textLabel.height)
        }
    }
}
