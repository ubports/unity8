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
import ".."
import "../../../qml/Stages"
import Ubuntu.Components 0.1
import Unity.Application 0.1

Rectangle {
    color: "black"
    id: root
    width: units.gu(70)
    height: units.gu(70)

    Component {
        id: fakeSurfaceComponent
        Rectangle {
            color: "green"

            Rectangle {
                color: "blue"
                anchors.fill: parent
                anchors.margins: units.gu(2)
                Text {
                    anchors.fill: parent
                    text: "Surface"
                    color: "green"
                    font.bold: true
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10; font.pixelSize: 200
                    verticalAlignment: Text.AlignVCenter
                }
            }

            width: units.gu(1)
            height: units.gu(1)

            property int type: MirSurfaceItem.Normal
            property int state: MirSurfaceItem.Restored
            property string name: "Fake Surface"
            property Item parentSurface: null
            property list<Item> childSurfaces
            function release() {}
            signal removed();
        }
    }

    Item {
        id: tempSurfaceHolder
    }

    Component {
        id: surfaceContainerComponent
        SurfaceContainer {
            anchors.fill: parent
        }
    }
    Loader {
        id: surfaceContainerLoader
        anchors {
            top: parent.top
            topMargin: fullscreenCheckbox.checked ? 0 : units.gu(3) + units.dp(2)
            bottom: parent.bottom
            left: parent.left
        }
        width: units.gu(40)
        sourceComponent: surfaceContainerComponent
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: surfaceContainerLoader.right
            right: parent.right
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {
                    id: surfaceCheckbox; checked: false;
                    onCheckedChanged: {
                        if (surfaceContainerLoader.status !== Loader.Ready)
                            return;

                        if (checked) {
                            var fakeSurface = fakeSurfaceComponent.createObject(tempSurfaceHolder);
                            surfaceContainerLoader.item.surface = fakeSurface;
                        } else {
                            var fakeSurface = surfaceContainerLoader.item.surface;
                            surfaceContainerLoader.item.surface = null;
                            fakeSurface.parent = null;
                            fakeSurface.destroy();
                        }
                    }
                }
                Label { text: "surface" }
            }
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: fullscreenCheckbox; checked: true; }
                Label { text: "fullscreen" }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "SurfaceContainer"
        when: windowShown

        function cleanup() {
            // reload our test subject to get it in a fresh state once again
            surfaceContainerLoader.active = false;
            surfaceCheckbox.checked = false;
            surfaceContainerLoader.active = true;
        }

        /*
            Add a first surface. Then remove it. Then add a second surface.
            That second surface should be properly sized.

            Regression test for https://bugs.launchpad.net/ubuntu/+source/qtmir/+bug/1359819
         */
        function test_resetSurfaceGetsProperlySized() {
            surfaceCheckbox.checked = true;
            surfaceCheckbox.checked = false;
            surfaceCheckbox.checked = true;
            var fakeSurface = surfaceContainerLoader.item.surface;
            compare(fakeSurface.width, surfaceContainerLoader.item.width);
            compare(fakeSurface.height, surfaceContainerLoader.item.height);
        }

        // function test_childSurfaces_data() {
        //     return [ { tag: "1", count: 1 },
        //              { tag: "4", count: 4 } ];
        // }

        // function test_childSurfaces(data) {
        //     var unity8dash = findChild(shell, "unity8-dash");
        //     compare(unity8dash.childSurfaces.count(), 0);

        //     var i;
        //     var surfaces = [];
        //     for (i = 0; i < data.count; i++) {
        //         surfaces.push(ApplicationTest.addChildSurface("unity8-dash", 0, 0, Qt.resolvedUrl("Dash/artwork/music-player-design.png")));
        //         compare(unity8dash.childSurfaces.count(), i+1);
        //     }

        //     surfaceSpy.clear();
        //     for (i = data.count-1; i >= 0; i--) {
        //         ApplicationTest.removeSurface(surfaces[i]);
        //         tryCompareFunction(function() { return unity8dash.childSurfaces.count(); }, i);
        //     }
        //     tryCompare(surfaceSpy, "count", data.count)
        // }

        // function test_tieredChildSurfaces_data() {
        //     return [
        //         { tag: "2", count: 2 },
        //         { tag: "10", count: 10 }
        //     ];
        // }

        // function test_tieredChildSurfaces(data) {
        //     var unity8dash = findChild(shell, "unity8-dash");
        //     compare(unity8dash.childSurfaces.count(), 0);

        //     var i;
        //     var surfaces = [];
        //     var lastSurfaceId = 0;
        //     var delegate;
        //     var surfaceContainer = unity8dash;
        //     for (i = 0; i < data.count; i++) {
        //         lastSurfaceId = ApplicationTest.addChildSurface("unity8-dash", 0, lastSurfaceId, Qt.resolvedUrl("Dash/artwork/music-player-design.png"))
        //         surfaces.push(lastSurfaceId);

        //         compare(surfaceContainer.childSurfaces.count(), 1);

        //         delegate = findChild(surfaceContainer, "childDelegate0");
        //         surfaceContainer = findChild(delegate, "surfaceContainer");
        //     }

        //     surfaceSpy.clear();
        //     for (i = data.count-1; i >= 0; i--) {
        //         ApplicationTest.removeSurface(surfaces[i]);
        //     }

        //     compare(unity8dash.childSurfaces.count(), 0);
        //     tryCompare(surfaceSpy, "count", data.count)
        // }
    }
}
