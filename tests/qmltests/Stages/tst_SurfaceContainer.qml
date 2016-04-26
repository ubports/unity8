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

            RowLayout {
                Layout.fillWidth: true

                Row {
                    CheckBox {id: fullscreenCheckbox; checked: true; activeFocusOnPress: false }
                    Label { text: "fullscreen" }
                }
                Row {
                    CheckBox {id: interactiveCheckbox; checked: true; activeFocusOnPress: false }
                    Label { text: "interactive" }
                }
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
                            application.setState(ApplicationInfoInterface.Starting);

                            surfaceContainerLoader.item.surface = SurfaceManager.createSurface("foo",
                                    Mir.NormalType, Mir.MaximizedState, application.screenshot);

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

            Rectangle {
                border {
                    color: "black"
                    width: 1
                }
                anchors {
                    left: parent.left
                    right: parent.right
                }
                Layout.preferredHeight: surfaceChildrenControl.height

                RecursingChildSessionControl {
                    id: surfaceChildrenControl
                    anchors { left: parent.left; right: parent.right; }

                    surface: surfaceContainerLoader.item ? surfaceContainerLoader.item.surface : null
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

            surfaceContainerLoader.active = true;
            tryCompare(surfaceContainerLoader, "status", Loader.Ready);
        }

        when: windowShown

        function test_addChildSession_data() {
            return [ { tag: "count=1", count: 1 },
                     { tag: "count=4", count: 4 } ];
        }

        function test_addChildSession(data) {
            surfaceCheckbox.checked = true;
            var childSurfaces = testCase.findChild(surfaceContainer, "childSurfacesRepeater");
            compare(childSurfaces.count, 0);

            var i;
            for (i = 0; i < data.count; i++) {
                surfaceContainer.surface.createPromptSurface();
                compare(childSurfaces.count, i+1);
            }

            for (i = data.count-1; i >= 0; i--) {
                {
                    var childPromptSurface = surfaceContainer.surface.promptSurfaceList.get(i);
                    childPromptSurface.close();
                }
                tryCompareFunction(function() { return childSurfaces.count; }, i);
            }
        }

        function test_childSessionDestructionReturnsFocusToSiblingOrParent() {
            surfaceCheckbox.checked = true;
            var childSurfaces = testCase.findChild(surfaceContainer, "childSurfacesRepeater");
            compare(childSurfaces.count, 0);

            var i;
            // 3 surfaces should cover all edge cases
            for (i = 0; i < 3; i++) {
                surfaceContainer.surface.createPromptSurface();
                compare(childSurfaces.count, i+1);
            }

            for (i = 2; i >= 0; --i) {
                var childPromptSurface = surfaceContainer.surface.promptSurfaceList.get(i);
                compare(childPromptSurface.activeFocus, true);

                childPromptSurface.close();
                tryCompareFunction(function() { return childSurfaces.count; }, i);

                if (i > 0) {
                    // active focus should have gone to the yongest remaining sibling
                    var previousSiblingSurface = surfaceContainer.surface.promptSurfaceList.get(i-1);
                    tryCompare(previousSiblingSurface, "activeFocus", true);
                } else {
                    // active focus should have gone to the parent surface
                    tryCompare(surfaceContainer.surface, "activeFocus", true);
                }
            }
        }

        function test_nestedChildSessions_data() {
            return [ { tag: "depth=2", depth: 2 },
                     { tag: "depth=8", depth: 8 }
            ];
        }
        function test_nestedChildSessions(data) {
            surfaceCheckbox.checked = true;

            var i;
            var container = surfaceContainer;
            var surface = container.surface;
            var surfaces = [surface];
            var parent_childSurfaces = [null];
            for (i = 0; i < data.depth; i++) {
                surface.createPromptSurface();
                var childSurfaces = testCase.findChild(container, "childSurfacesRepeater");
                compare(childSurfaces.count, 1);

                var childDelegate = childSurfaces.itemAt(0);
                container = findChild(childDelegate, "surfaceContainer");
                {
                    var animationsLoader = findChild(container, "animationsLoader");
                    tryCompare(animationsLoader, "status", Loader.Ready);
                    waitUntilTransitionsEnd(animationsLoader.item);
                }
                surface = container.surface;

                surfaces.push(surface);
                parent_childSurfaces.push(childSurfaces);
            }

            for (i = surfaces.length-1; i >= 0; i--) {
                surfaces[i].close();
                if (parent_childSurfaces[i]) {
                    tryCompareFunction(function() { return parent_childSurfaces[i].count; }, 0);
                }
            }
        }

        function test_childrenAdjustForParentSize() {
            surfaceCheckbox.checked = true;

            surfaceContainer.surface.createPromptSurface();

            var delegate = findChild(surfaceContainer, "childDelegate0");
            var childContainer = findChild(delegate, "surfaceContainer");

            tryCompareFunction(function() { return childContainer.height === surfaceContainer.height; }, true);
            tryCompareFunction(function() { return childContainer.width === surfaceContainer.width; }, true);
            tryCompareFunction(function() { return childContainer.x === 0; }, true);
            tryCompareFunction(function() { return childContainer.y === 0; }, true);

            surfaceContainer.anchors.margins = units.gu(2);

            tryCompareFunction(function() { return childContainer.height === surfaceContainer.height; }, true);
            tryCompareFunction(function() { return childContainer.width === surfaceContainer.width; }, true);
            tryCompareFunction(function() { return childContainer.x === 0; }, true);
            tryCompareFunction(function() { return childContainer.y === 0; }, true);
        }

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

        function test_childrenAnimate() {
            surfaceCheckbox.checked = true;

            surfaceContainer.surface.createPromptSurface();

            var delegate = findChild(surfaceContainer, "childDelegate0");
            var childContainer = findChild(delegate, "surfaceContainer");

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, false);

            surfaceContainer.surface.promptSurfaceList.get(0).close();

            // wait for animation to begin
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, true);
            // wait for animation to end
            tryCompareFunction(function() { return isContainerAnimating(childContainer); }, false);
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
