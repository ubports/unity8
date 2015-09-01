/*
 * Copyright 2014-2015 Canonical Ltd.
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
import Unity.Test 0.1
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
            interactive: interactiveCheckbox.checked
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
                                                                           Mir.NormalType,
                                                                           Mir.RestoredState,
                                                                           Qt.resolvedUrl("../Dash/artwork/music-player-design.png"));
                            surfaceContainerLoader.item.surface = fakeSurface;
                        } else {
                            surfaceContainerLoader.item.surface.setLive(false);
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
            Row {
                anchors { left: parent.left; right: parent.right }
                CheckBox {id: interactiveCheckbox; checked: true; }
                Label { text: "interactive" }
            }
            MouseTouchEmulationCheckbox {}
        }
    }

    SignalSpy {
        id: surfaceSpy
        target: SurfaceManager
        signalName: "surfaceDestroyed"
    }

    UnityTestCase {
        id: testCase
        name: "SurfaceContainer"
        when: windowShown

        property var surfaceContainer:
                surfaceContainerLoader.status === Loader.Ready ? surfaceContainerLoader.item : null

        function cleanup() {
            // reload our test subject to get it in a fresh state once again
            surfaceContainerLoader.active = false;
            surfaceCheckbox.checked = false;
            surfaceContainerLoader.active = true;

            tryCompare(surfaceContainerLoader.item, "surface", null);
            surfaceSpy.clear();

            interactiveCheckbox.checked = true;
        }

        function test_animateRemoval() {
            surfaceCheckbox.checked = true;

            verify(surfaceContainer.surface !== null);

            surfaceContainer.surface.setLive(false);

            compare(surfaceContainer.state, "zombie");
            tryCompare(surfaceContainer, "surface", null);
        }

        function test_surfaceItemGetsNoTouchesWhenContainerNotInteractive() {
            surfaceCheckbox.checked = true;
            verify(surfaceContainer.surface !== null);

            var surfaceItem = findChild(surfaceContainer, "surfaceItem");
            verify(surfaceItem !== null);

            surfaceItem.touchPressCount = 0;
            surfaceItem.touchReleaseCount = 0;

            tap(surfaceContainer, surfaceContainer.width / 2, surfaceContainer.height / 2);

            // surface got touches as the surfaceContainer is interactive
            compare(surfaceItem.touchPressCount, 1)
            compare(surfaceItem.touchReleaseCount, 1);

            interactiveCheckbox.checked = false;
            tap(surfaceContainer, surfaceContainer.width / 2, surfaceContainer.height / 2);

            // surface shouldn't get the touches from the second tap as the surfaceContainer
            // was *not* interactive when it happened.
            compare(surfaceItem.touchPressCount, 1)
            compare(surfaceItem.touchReleaseCount, 1);
        }

        function test_surfaceItemGetsActiveFocusOnMousePress() {
            surfaceCheckbox.checked = true;
            verify(surfaceContainer.surface !== null);

            var surfaceItem = findChild(surfaceContainer, "surfaceItem");
            verify(surfaceItem !== null);

            compare(surfaceItem.activeFocus, false);
            mouseClick(surfaceContainer);
            compare(surfaceItem.activeFocus, true);
        }

        function test_surfaceItemGetsActiveFocusOnTap() {
            surfaceCheckbox.checked = true;
            verify(surfaceContainer.surface !== null);

            var surfaceItem = findChild(surfaceContainer, "surfaceItem");
            verify(surfaceItem !== null);

            compare(surfaceItem.activeFocus, false);
            tap(surfaceContainer);
            compare(surfaceItem.activeFocus, true);
        }
    }
}
