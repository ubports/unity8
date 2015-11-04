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

import QtQuick 2.4
import QtTest 1.0
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var progressjson: {
        "type": "progress",
        "source": { "dbus-name" : "somename", "dbus-object": "somestring" }
    }

    property var progressjsonFinish: {
        "type": "progress",
        "source": { "dbus-name" : "somename", "dbus-object": "finish" }
    }

    property var progressjsonError: {
        "type": "progress",
        "source": { "dbus-name" : "somename", "dbus-object": "error" }
    }

    SignalSpy {
        id: spy
        signalName: "triggered"
    }

    PreviewProgress {
        id: previewProgress
        widgetId: "previewProgress"
        widgetData: progressjson
        width: units.gu(30)

        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.1
        }
    }

    UT.UnityTestCase {
        name: "PreviewProgressTest"
        when: windowShown

        function test_json() {
            spy.target = previewProgress;

            // The mock DownloadTracker triggers its signals when you pass
            // finish/error as dbus-object to it. Exercise it here
            previewProgress.widgetData = progressjsonFinish;
            compare(spy.count, 1);
            var args = spy.signalArguments[0];
            compare(args[0], "previewProgress");
            compare(args[1], "finished");
            compare(args[2], progressjsonFinish);

            spy.clear();

            previewProgress.widgetData = progressjsonError;
            compare(spy.count, 1);
            var args = spy.signalArguments[0];
            compare(args[0], "previewProgress");
            compare(args[1], "failed");
            compare(args[2], progressjsonError);
        }
    }
}
