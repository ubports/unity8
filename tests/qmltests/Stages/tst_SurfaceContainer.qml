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
                    id: surfaceCheckbox;
                    checked: false;
                    onCheckedChanged: {
                        if (surfaceContainerLoader.status !== Loader.Ready)
                            return;

                        if (checked) {
                            var fakeSurface = SurfaceManager.createSurface("fake-surface",
                                                                           MirSurfaceItem.Normal,
                                                                           MirSurfaceItem.Restored,
                                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                            surfaceContainerLoader.item.surface = fakeSurface;
                        } else {
                            ApplicationTest.removeSurface(surfaceContainerLoader.item.surface);
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

    SignalSpy {
        id: surfaceSpy
        target: SurfaceManager
        signalName: "surfaceDestroyed"
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

            tryCompare(surfaceContainerLoader.item, "surface", null);
            surfaceSpy.clear();
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

        function test_animateRemoval() {
            surfaceCheckbox.checked = true;
            var surfaceContainer = surfaceContainerLoader.item;

            verify(surfaceContainer.surface !== null);

            ApplicationTest.removeSurface(surfaceContainer.surface);

            compare(surfaceContainer.state, "zombie");
            tryCompare(surfaceContainer, "surface", null);
        }
    }
}
