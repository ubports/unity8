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
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: Theme.palette.selected.background

    PreviewWidgetFactory {
        id: factory
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    SignalSpy {
        id: triggeredSpy
        target: factory
        signalName: "triggered"
    }

    UT.UnityTestCase {
        name: "PreviewWidgetFactory"
        when: windowShown

        property Item mockWidget: findChild(factory, "mockPreviewWidget")

        function cleanup() {
            factory.source = Qt.binding(function() { return factory.widgetSource });
        }

        function test_previewData() {
            factory.source = Qt.resolvedUrl("MockPreviewWidget.qml");

            verify(typeof mockWidget === "object", "Could not find the mock preview widget.");

            tryCompare(mockWidget, "widgetData", factory.widgetData);
        }

        function test_triggered() {
            factory.source = Qt.resolvedUrl("MockPreviewWidget.qml");

            verify(typeof mockWidget === "object", "Could not find the mock preview widget.");

            mockWidget.trigger();

            triggeredSpy.wait();

            var args = triggeredSpy.signalArguments[0];

            compare(args[0], "mockWidget", "Widget id not passed correctly.");
            compare(args[1], "mockAction", "Action id not passed correctly.");
            compare(args[2]["mock"], "data", "Data not passed correctly.");
        }

        function test_mapping_data() {
            return [
                { tag: "Actions", type: "actions", source: "PreviewActions.qml" },
                { tag: "Audio", type: "audio", source: "PreviewAudioPlayback.qml" },
                { tag: "Expandable", type: "expandable", source: "PreviewExpandable.qml" },
                { tag: "Gallery", type: "gallery", source: "PreviewImageGallery.qml" },
                { tag: "Header", type: "header", source: "PreviewHeader.qml" },
                { tag: "Image", type: "image", source: "PreviewZoomableImage.qml" },
                { tag: "Progress", type: "progress", source: "PreviewProgress.qml" },
                { tag: "Rating Input", type: "rating-input", source: "PreviewRatingInput.qml" },
                { tag: "Rating Display", type: "reviews", source: "PreviewRatingDisplay.qml" },
                { tag: "Text", type: "text", source: "PreviewTextSummary.qml" },
                { tag: "Video", type: "video", source: "PreviewVideoPlayback.qml" },
            ];
        }

        function test_mapping(data) {
            factory.widgetData = { type: data.type };
            factory.widgetType = data.type;

            verify((String() + factory.source).indexOf(data.source) != -1);
        }
    }
}
