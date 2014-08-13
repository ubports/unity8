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
import Unity.Test 0.1 as UT
import Unity.Application 0.1
import "../../../qml/Stages"

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    Repeater {
        anchors.fill: parent
        model: ApplicationManager

        delegate: SurfaceContainer {
            id: container
            anchors.fill: parent
            objectName: application.appId

            surface: model.surface
        }
    }

    SignalSpy {
        id: surfaceSpy
        target: SurfaceManager
        signalName: "surfaceDestroyed"
    }

    UT.UnityTestCase {
        id: testCase
        name: "SurfaceContainer"
        when: windowShown

        function initTestCase() {
            var unity8dash = findChild(shell, "unity8-dash");
            verify(unity8dash !== null);

            tryCompareFunction(function() { return unity8dash.surface !== null; }, true);
        }

        function test_childSurfaces_data() {
            return [ { tag: "1", count: 1 },
                     { tag: "4", count: 4 } ];
        }

        function test_childSurfaces(data) {
            var unity8dash = findChild(shell, "unity8-dash");
            compare(unity8dash.childSurfaces.count, 0);

            var i;
            var surfaces = [];
            for (i = 0; i < data.count; i++) {
                surfaces.push(ApplicationTest.addChildSurface("unity8-dash", 0, Qt.resolvedUrl("Dash/artwork/music-player-design.png")));
                compare(unity8dash.childSurfaces.count, i+1);
            }

            surfaceSpy.clear();
            for (i = data.count-1; i >= 0; i--) {
                ApplicationTest.removeSurface(surfaces[i]);
                tryCompare(unity8dash.childSurfaces, "count", i);
            }
            tryCompare(surfaceSpy, "count", data.count)
        }

        function test_tieredChildSurfaces_data() {
            return [
                { tag: "2", count: 2 },
                { tag: "10", count: 10 }
            ];
        }

        function test_tieredChildSurfaces(data) {
            var unity8dash = findChild(shell, "unity8-dash");
            compare(unity8dash.childSurfaces.count, 0);

            var i;
            var surfaces = [];
            var lastSurfaceId = 0;
            var delegate;
            var surfaceContainer = unity8dash;
            for (i = 0; i < data.count; i++) {
                lastSurfaceId = ApplicationTest.addChildSurface("unity8-dash", lastSurfaceId, Qt.resolvedUrl("Dash/artwork/music-player-design.png"))
                surfaces.push(lastSurfaceId);

                compare(surfaceContainer.childSurfaces.count, 1);

                delegate = findChild(surfaceContainer, "childDelegate0");
                console.log("XXX " + delegate)
                surfaceContainer = findChild(delegate, "surfaceContainer");
            }

            surfaceSpy.clear();
            for (i = data.count-1; i >= 0; i--) {
                ApplicationTest.removeSurface(surfaces[i]);
            }

            compare(unity8dash.childSurfaces.count, 0);
            tryCompare(surfaceSpy, "count", data.count)
        }
    }
}
