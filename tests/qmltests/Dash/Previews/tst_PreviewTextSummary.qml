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

    property var widgetDataComplete: {
        "title": "Title here",
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    }

    property var widgetDataNoTitle: {
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    }

    property var widgetDataShortText: {
        "title": "Title here",
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nPhasellus a mi vitae augue rhoncus lobortis ut rutrum metus.\nCurabitur tortor leo, tristique sed mollis quis, condimentum venenatis nibh."
    }

    PreviewTextSummary {
        id: previewTextSummary
        anchors.fill: parent
        widgetData: widgetDataComplete
    }

    UT.UnityTestCase {
        name: "PreviewTextSummaryTest"
        when: windowShown

        property var textLabel: findChild(previewTextSummary, "textLabel")

        function init() {
            verify(typeof textLabel === "object", "TextLabel object could not be found.")
        }

        function cleanup() {
            previewTextSummary.widgetData = widgetDataComplete
        }

        function test_optional_title() {
            var titleLabel = findChild(previewTextSummary, "titleLabel")

            // verify titleLabel is visible and textLabel is anchored below it
            compare(titleLabel.visible, true)
            tryCompare(textLabel, "y", titleLabel.height)

            // verify titleLabel disappears and textLabel moves up
            previewTextSummary.widgetData = widgetDataNoTitle
            compare(titleLabel.visible, false)
            tryCompare(textLabel, "y", 0)
        }

        function test_see_more() {
            var seeMore = findChild(previewTextSummary, "seeMore")
            var seeMoreContainer = findChild(previewTextSummary, "seeMoreContainer")

            // when it's more than textLabel.maximumCollapsedLineCount lines of text, show SeeMore component
            verify(textLabel.lineCount > textLabel.maximumCollapsedLineCount)
            compare(seeMore.visible, true)
            verify(seeMore.more === false)
            verify(textLabel.height < textLabel.contentHeight)

            // test interactions with SeeMore
            var seeMoreLabel = findChild(seeMore, "seeMoreLabel")
            var seeLessLabel = findChild(seeMore, "seeLessLabel")
            var initialTextLabelHeight = textLabel.height
            mouseClick(seeMoreLabel, seeMoreLabel.width / 2, seeMoreLabel.height / 2)
            tryCompare(textLabel, "height", textLabel.contentHeight)
            mouseClick(seeLessLabel, seeLessLabel.width / 2, seeLessLabel.height / 2)
            tryCompare(textLabel, "height", initialTextLabelHeight)

            // text SeeMore automatic hiding
            previewTextSummary.widgetData = widgetDataShortText
            verify(textLabel.lineCount <= textLabel.maximumCollapsedLineCount)
            compare(seeMoreContainer.visible, false)
            compare(seeMore.visible, false)
            tryCompare(textLabel, "height", textLabel.contentHeight)
        }
    }
}
