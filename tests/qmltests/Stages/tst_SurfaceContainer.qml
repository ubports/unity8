/*
 * Copyright 2014-2016 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "../../../qml/Stages"

Rectangle {
    color: "red"
    id: root
    width: units.gu(80)
    height: units.gu(70)

    Connections {
        target: surfaceContainerLoader.status === Loader.Ready ? surfaceContainerLoader.item : null
        onSurfaceChanged: {
            surfaceCheckbox.checked = surfaceContainerLoader.item.surface !== null
        }
    }

    Component {
        id: surfaceContainerComponent

        SurfaceContainer {
            anchors.fill: parent
            focus: true
            interactive: interactiveCheckbox.checked
            isPromptSurface: promptCheckbox.checked
            Component.onDestruction: {
                surfaceContainerLoader.itemDestroyed = true;
            }
        }
    }

    Loader {
        id: surfaceContainerLoader
        focus: true
        anchors {
            top: parent.top
            topMargin: fullscreenCheckbox.checked ? 0 : units.gu(3)
            bottom: parent.bottom
            left: parent.left
        }
        width: units.gu(40)
        property bool itemDestroyed: false
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

        ColumnLayout {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)


            Row {
                CheckBox {id: fullscreenCheckbox; checked: true; activeFocusOnPress: false }
                Label { text: "fullscreen" }
            }
            Row {
                CheckBox {id: interactiveCheckbox; checked: true; activeFocusOnPress: false }
                Label { text: "interactive" }
            }
            Row {
                CheckBox {id: promptCheckbox; checked: false; activeFocusOnPress: false
                          enabled: surfaceContainerLoader.item.surface === null }
                Label { text: "isPromptSurface" }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: surfaceCheckbox;
                    checked: false;
                    activeFocusOnPress: false
                    onCheckedChanged: {
                        if (surfaceContainerLoader.status !== Loader.Ready)
                            return;

                        if (checked) {
                            var application = ApplicationManager.add("music-app");
                            application.manualSurfaceCreation = true;

                            application.createSurface();
                            surfaceContainerLoader.item.surface = application.surfaceList.get(0);

                            application.setState(ApplicationInfoInterface.Running);
                        } else {
                            if (surfaceContainerLoader.item.surface) {
                                surfaceContainerLoader.item.surface.setLive(false);
                            }
                            ApplicationManager.stopApplication("music-app");
                        }
                    }
                }

                Label {
                    text: "surface"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Button {
                text: "Reload"
                enabled: !surfaceCheckbox.checked
                onClicked: {
                    testCase.cleanup();
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "SurfaceContainer"

        property Item surfaceContainer: surfaceContainerLoader.status === Loader.Ready ? surfaceContainerLoader.item : null

        function cleanup() {
            // reload our test subject to get it in a fresh state once again

            surfaceContainerLoader.itemDestroyed = false;
            surfaceContainerLoader.active = false;

            tryCompare(surfaceContainerLoader, "status", Loader.Null);
            tryCompare(surfaceContainerLoader, "item", null);
            tryCompare(surfaceContainerLoader, "itemDestroyed", true);

            killApps();

            surfaceCheckbox.checked = false;
            interactiveCheckbox.checked = true;
            promptCheckbox.checked = false;

            surfaceContainerLoader.active = true;
            tryCompare(surfaceContainerLoader, "status", Loader.Ready);
        }

        when: windowShown

        function isContainerAnimating(container) {
            var animationsLoader = findChild(container, "animationsLoader");
            if (!animationsLoader || animationsLoader.status != Loader.Ready) {
                return false;
            }

            var animation = animationsLoader.item;

            var animating = false;
            for (var i = 0; i < animation.transitions.length; ++i) {
                if (animation.transitions[i].running) {
                    return true;
                }
            }
            return false;
        }

        function test_promptSurfaceAnimates() {
            promptCheckbox.checked = true;
            surfaceCheckbox.checked = true;

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(surfaceContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(surfaceContainer); }, false);

            surfaceContainer.surface.close();

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(surfaceContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(surfaceContainer); }, false);
        }

        function test_surfaceItemGetsNoTouchesWhenContainerNotInteractive() {
            surfaceCheckbox.checked = true;
            verify(surfaceContainer.surface !== null);

            var surfaceItem = findChild(surfaceContainer, "surfaceItem");
            verify(surfaceItem !== null);

            surfaceItem.touchPressCount = 0;
            surfaceItem.touchReleaseCount = 0;

            tap(surfaceContainer);

            // surface got touches as the surfaceContainer is interactive
            compare(surfaceItem.touchPressCount, 1)
            compare(surfaceItem.touchReleaseCount, 1);

            interactiveCheckbox.checked = false;
            tap(surfaceContainer);

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

            surfaceContainer.focus = false;

            compare(surfaceItem.activeFocus, false);
            mouseClick(surfaceContainer);
            compare(surfaceItem.activeFocus, true);
        }

        function test_surfaceItemGetsActiveFocusOnTap() {
            surfaceCheckbox.checked = true;
            verify(surfaceContainer.surface !== null);

            var surfaceItem = findChild(surfaceContainer, "surfaceItem");
            verify(surfaceItem !== null);

            surfaceContainer.focus = false;

            compare(surfaceItem.activeFocus, false);
            tap(surfaceContainer);
            compare(surfaceItem.activeFocus, true);
        }
    }
}
