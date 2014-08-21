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

    PreviewListView {
        id: listView
        anchors.fill: parent
        scope: mockScope
        scopeStyle: ScopeStyle { }
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
    }
}
