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

        source: Qt.resolvedUrl("MockPreviewWidget.qml")

        widgetData: {
            "type": "mock"
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

        function init() {
            verify(typeof mockWidget === "object", "Could not find the mock preview widget.");
        }

        function test_previewData() {
            tryCompare(mockWidget, "widgetData", factory.widgetData);
        }

        function test_triggered() {
            mockWidget.trigger();

            triggeredSpy.wait();

            var args = triggeredSpy.signalArguments[0];

            compare(args[0], "mockWidget", "Widget id not passed correctly.");
            compare(args[1], "mockAction", "Action id not passed correctly.");
            compare(args[2]["mock"], "data", "Data not passed correctly.");
        }
    }
}
