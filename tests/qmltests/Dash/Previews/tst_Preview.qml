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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Unity 0.2 as Unity

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(60)
    color: theme.palette.selected.background

    Item {
        id: shell

        anchors.fill: parent
        property var applicationManager: null
    }

    Unity.FakePreviewModel {
        id: mockPreviewModel
    }

    ListModel {
        id: tracksModel
        Component.onCompleted:
        {
            tracksModel.append( { "type" : "audio1",
                                  "widgetId" : "audiopw1",
                                  "properties" : { "tracks" : [
                                                                { title: "Some track name", length: "30", source: "/not/existinga/path/testsound1" }
                                                              ]
                                                 }
                                }
                              );
            tracksModel.append(
                                { "type" : "audio",
                                  "widgetId" : "audiopw",
                                  "properties" : { "tracks" : [
                                                                { title: "Some track name", length: "30", source: "/not/existing/path/testsound1" },
                                                                { title: "Some other track name", subtitle: "Subtitle", length: "83", source: "/not/existing/path/testsound2" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound3" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound4" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound5" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound6" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound7" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound8" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound9" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound10" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound11" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound12" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound13" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound14" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound15" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound16" },
                                                                { title: "And another one", length: "7425", source: "/not/existing/path/testsound17" }
                                                              ]
                                                 }
                                } );
        }
    }

    QtObject {
        id: audiosModel
        property int widgetColumnCount: 1
        property var columnModel: { tracksModel }
    }

    Preview {
        id: preview
        anchors.fill: parent

        previewModel: mockPreviewModel
    }

    SignalSpy {
        id: triggeredSpy
        target: mockPreviewModel
        signalName: "triggered"
    }

    UT.UnityTestCase {
        name: "Preview"
        when: windowShown

        function init() {
            var widget = findChild(preview, "previewListRow0");
            widget.positionViewAtBeginning();
            preview.previewModel = mockPreviewModel;
        }

        function test_triggered() {
            waitForRendering(preview);
            var widget = findChild(preview, "widget-3");

            compare(typeof widget, "object", "Could not find the widget object.");

            compare(triggeredSpy.count, 0)
            widget.triggered(widget.widgetId, "mockAction", {"mock": "data"});
            compare(triggeredSpy.count, 1)

            var args = triggeredSpy.signalArguments[0];

            compare(args[0], "widget-3", "Widget id not passed correctly.");
            compare(args[1], "mockAction", "Action id not passed correctly.");
            compare(args[2]["mock"], "data", "Data not passed correctly.");
        }

        function test_containOnFocus() {
            waitForRendering(preview);
            var widget = findChild(preview, "widget-10");

            var bottomLeft = preview.mapFromItem(widget, 0, widget.height);
            verify(bottomLeft.y > preview.height);

            widget.forceActiveFocus();

            tryCompareFunction(function () {
                var bottomLeft = preview.mapFromItem(widget, 0, widget.height);
                return bottomLeft.y <= preview.height + 1 // FIXME the +1 is to workaround https://bugreports.qt.io/browse/QTBUG-56961
            }, true);
        }

        function test_containOnGrow() {
            waitForRendering(preview);
            var widget = findChild(preview, "widget-13");

            var bottomLeft = preview.mapFromItem(widget, 0, widget.height);
            verify(bottomLeft.y > preview.height);

            root.height += units.gu(50);

            tryCompareFunction(function () {
                var bottomLeft = preview.mapFromItem(widget, 0, widget.height);
                return bottomLeft.y <= preview.height + 1 // FIXME the +1 is to workaround https://bugreports.qt.io/browse/QTBUG-56961
            }, true);
        }

        function test_comboEnsureVisible() {
            waitForRendering(preview);

            // Scroll down
            var previewListRow0 = findChild(preview, "previewListRow0");
            flickToYEnd(previewListRow0);

            // Click on the combo
            var widget = findChild(preview, "widget-21");
            var initialWidgetHeight = widget.height;
            var moreLessButton = findChild(widget, "moreLessButton");
            mouseClick(moreLessButton);


            // FIXME: For some reason the PreviewWidgetFactory (parent of 'widget')
            // is destroyed on idle calls, when the test is under stress.
            // Not to compromise the result, we just skip the test if this happens
            var widget_str = widget.toString()
            var preview_str = preview.toString()
            var skipped = false
            function skipTest() { skipped = true; }
            preview.Component.onDestruction.connect(skipTest)
            widget.Component.onDestruction.connect(skipTest)

            // Wait for the combo to stop growing
            tryCompareFunction(function(){ return (widget.height == units.gu(15) || skipped) }, true, 5000, "Widget lost "+widget_str+" was skipped ");

            // Make sure the combo bottom is on the viewport
            tryCompareFunction(function () {
                if (skipped) return true;
                var bottomLeft = preview.mapFromItem(widget, 0, widget.height);
                return bottomLeft.y <= preview.height + 1 // FIXME the +1 is to workaround https://bugreports.qt.io/browse/QTBUG-56961
            }, true);

            if (!skipped) {
                preview.Component.onDestruction.disconnect(skipTest)
                widget.Component.onDestruction.disconnect(skipTest)
            } else {
                skip("preview %1 or widget %2 have been destroyed, thus we can't safely continue this test".arg(preview_str).arg(widget_str))
            }
        }

        function test_audios() {
            preview.previewModel = audiosModel;
            waitForRendering(preview);

            // Scroll down
            var previewListRow0 = findChild(preview, "previewListRow0");
            flickToYEnd(previewListRow0);

            var previewsContentY = previewListRow0.contentY;

            var trackItem = findChild(preview, "trackItem16");
            mouseClick(findChild(trackItem, "playButton"));

            expectFail("", "Clicking on a track should not change contentY.");
            tryCompareFunction(function () { return previewsContentY != previewListRow0.contentY; }, true);
        }
    }
}
