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
import Ubuntu.Components 1.1
import "../../../qml/Dash"
import Unity.Test 0.1 as UT
import Unity 0.2 as Unity
import Dash 0.1

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(60)
    color: Theme.palette.selected.background

    Unity.MockScope {
        id: mockScope
    }

    Unity.FakeResultsModel {
        id: mockResultsModel
    }

    Unity.FakePreviewModel {
        id: mockPreviewModel
    }

    PreviewListView {
        id: listView
        anchors.fill: parent
        scope: mockScope
        scopeStyle: ScopeStyle {
             style: mockScope.customizations
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "PreviewListView"
        when: windowShown

        property MouseArea mouseArea: findChild(listView, "processingMouseArea")

        SignalSpy {
            id: clickedSpy
            signalName: "clicked"
            target: testCase.mouseArea
        }

        function init() {
            listView.model = mockResultsModel;
            listView.currentIndex = 1;
            listView.currentItem.previewModel = mockPreviewModel;
            listView.open = true;
            verify(testCase.mouseArea, "Can't find the processingMouseArea object.");
        }

        function cleanup() {
            listView.open = false;
            listView.model = null;
            clickedSpy.clear();
        }

        function test_notProcessing() {
            expectFail("", "processingMouseArea should not receive the click.");
            mouseClick(listView, listView.width / 2, listView.height / 2);
            clickedSpy.wait();
        }

        function test_processing() {
            verify(listView.currentItem, "currentItem is not ready yet");
            listView.currentItem.previewModel.setLoaded(false);

            tryCompare(listView, "processing", true);

            mouseClick(listView, listView.width / 2, listView.height / 2);
            clickedSpy.wait();
        }

        function test_title() {
            var header = findChild(listView, "innerPageHeader");
            verify(header, "Could not find the preview header");

            compare(header.title, "Mock Scope");
        }

        function test_header_style() {
            var header = findChild(listView, "pageHeader");
            verify(header, "Could not find the header");

            var innerHeader = findChild(header, "innerPageHeader");
            verify(innerHeader, "Could not find the inner header");
            verify(Qt.colorEqual(innerHeader.textColor, UbuntuColors.darkGrey),
                   "Foreground color not equal: %1 != %2".arg(innerHeader.textColor).arg(UbuntuColors.darkGrey));

            var background = findChild(header, "headerBackground");
            verify(background, "Could not find the background");
            compare(background.style, "gradient:///lightgrey/grey");

            var image = findChild(header, "titleImage");
            verify(image, "Could not find the title image.");
            compare(image.source, Qt.resolvedUrl("../Dash/tst_PageHeader/logo-ubuntu-orange.svg"), "Title image has the wrong source");
        }
    }
}
