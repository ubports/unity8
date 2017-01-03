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

import QtQuick 2.4
import QtTest 1.0
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Components"
import "../../../qml/Components/PanelState"
import "../../../qml/Stage"
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1
import Unity.ApplicationMenu 0.1
import Unity.Indicators 0.1 as Indicators

Rectangle {
    color: "red"
    id: root
    width: fakeShell.shortestDimension + controls.width
    height: fakeShell.longestDimension

    Component.onCompleted: {
        QuickUtils.keyboardAttached = true;
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    property QtObject fakeApplication: null

    Binding {
        target: UT.MouseTouchAdaptor
        property: "enabled"
        value: false
    }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Item {
        id: fakeShell

        readonly property real shortestDimension: units.gu(100)
        readonly property real longestDimension: units.gu(70)

        width: landscape ? longestDimension : shortestDimension
        height: landscape ? shortestDimension : longestDimension

        x: landscape ? (height - width) / 2 : 0
        y: landscape ? (width - height) / 2 : 0

        property bool landscape: orientationAngle == 90 || orientationAngle == 270
        property int orientationAngle: shellOrientationAngleSelector.value

        rotation: orientationAngle

        WindowResizeArea {
            target: loader
            borderThickness: units.gu(2)
        }

        Loader {
            id: loader
            property int windowedX: units.gu(1)
            property int windowedY: units.gu(1)
            property int windowedWidth: units.gu(50)
            property int windowedHeight: units.gu(40)
            x: windowedX
            y: windowedY
            width: item ? item.implicitWidth : 0
            height: item ? item.implicitHeight : 0

            active: false
            property bool itemDestroyed: false

            sourceComponent: DecoratedWindow {
                id: decoratedWindow

                anchors.fill: parent
                application: fakeApplication
                requestedWidth: loader.windowedWidth
                requestedHeight: loader.windowedHeight
                active: true
                surface: fakeApplication && fakeApplication.surfaceList.count > 0 ? fakeApplication.surfaceList.get(0) : null

                Binding {
                    target: PanelState
                    property: "focusedPersistentSurfaceId"
                    value: decoratedWindow.surface ? decoratedWindow.surface.persistentId : "x"
                }

                Component.onDestruction: {
                    loader.itemDestroyed = true;
                }
                Component.onCompleted: {
                    loader.itemDestroyed = false;
                }
            }

            Rectangle { anchors.fill: parent; color: "green"; opacity: 1 }
        }
    }


    Rectangle {
        id: controls
        color: theme.palette.normal.background
        width: units.gu(30)
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
            spacing: units.gu(1)
            Button {
                id: loadWidthDialerApp
                text: "Load with dialer-app"
                onClicked: { testCase.restartWithApp("dialer-app"); }
            }
            Button {
                id: loadWithWeatherApp
                text: "Load with ubuntu-weather-app"
                onClicked: { testCase.restartWithApp("ubuntu-weather-app"); }
            }
            Button {
                id: loadWithGalleryApp
                text: "Load with gallery-app"
                onClicked: { testCase.restartWithApp("gallery-app"); }
            }
            Button {
                text: "toggle has decoration"
                onClicked: loader.item.hasDecoration = !loader.item.hasDecoration
            }
            Button {
                text: "show/hide decoration"
                onClicked: loader.item.showDecoration = !loader.item.showDecoration
            }
            Label {
                text: "scale to preview progress"
            }

            Slider {
                value: 0
                minimumValue: 0
                maximumValue: 1
                live: true
                onValueChanged: loader.item.scaleToPreviewProgress = value
            }
            ListItem.ItemSelector {
                id: shellOrientationAngleSelector
                anchors { left: parent.left; right: parent.right }
                text: "shellOrientationAngle"
                model: ["0", "90", "180", "270"]
                property int value: selectedIndex * 90
            }
            Button {
                text: "matchShellOrientation()"
                onClicked: { loader.item.matchShellOrientation(); }
            }
            Button {
                text: "animateToShellOrientation()"
                onClicked: { loader.item.animateToShellOrientation(); }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "DecoratedWindow"
        when: windowShown

        property Item decoratedWindow: loader.item

        function init() {
        }

        function cleanup() {
            unloadWindow();
            root.fakeApplication = null;
            killApps();
        }

        function restartWithApp(appId) {
            if (loader.active) {
                unloadWindow();
            }
            if (root.fakeApplication) {
                ApplicationManager.stopApplication(root.fakeApplication.appId);
            }

            root.fakeApplication = ApplicationManager.startApplication(appId);
            loader.active = true;
            tryCompare(loader, "status", Loader.Ready);
        }

        function unloadWindow() {
            loader.active = false;
            tryCompare(loader, "status", Loader.Null);
            tryCompare(loader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(loader, "itemDestroyed", true);

        }

        function test_keepsSceneTransformationWhenShellRotates_data() {
            return [
                {tag: "0", selectedIndex: 0},
                {tag: "90", selectedIndex: 1},
                {tag: "180", selectedIndex: 2},
                {tag: "270", selectedIndex: 3}
            ];
        }
        function test_keepsSceneTransformationWhenShellRotates(data) {
            loadWithGalleryApp.clicked();

            // Wait until it reaches the state we are interested on.
            // It begins with "startingUp"
            tryCompare(decoratedWindow, "counterRotate", false);
            var oldWidth = decoratedWindow.width
            var oldHeight = decoratedWindow.height
            var oldX = decoratedWindow.x
            var oldY = decoratedWindow.y

            shellOrientationAngleSelector.selectedIndex = data.selectedIndex;

            // must keep same aspect ratio
            compare(decoratedWindow.width, oldWidth);
            compare(decoratedWindow.height, oldHeight);


            // and scene transformation must be the identity (ie, no rotation or translation)
            compare(decoratedWindow.x, oldX);
            compare(decoratedWindow.y, oldY);
        }

        function test_showHighLight() {
            loadWithGalleryApp.clicked();
            var highlightRect = findChild(loader.item, "selectionHighlight")
            tryCompare(highlightRect, "visible", false)
            loader.item.showHighlight = true;
            tryCompare(highlightRect, "visible", true)
        }
    }
}
