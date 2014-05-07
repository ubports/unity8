/*
 * Copyright 2013 Canonical Ltd.
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
import "../../../../qml/Dash/Apps"
import Unity.Test 0.1 as UT
import Unity.Application 0.1

// Using Rectangle to have an opaque surface because AppManager paints app surfaces behind it.
Rectangle {
    width: units.gu(50)
    height: units.gu(40)

    function resetRunningApplications() {
        while (ApplicationManager.count > 0) {
            ApplicationManager.stopApplication(ApplicationManager.get(0).appId)
        }

        ApplicationManager.startApplication("phone-app");
        ApplicationManager.startApplication("webbrowser-app");
    }

    Component.onCompleted: {
        resetRunningApplications()
    }

    // The component under test
    RunningApplicationsGrid {
        id: runningApplicationsGrid
        anchors.fill: parent
        model: ApplicationManager
    }

    UT.UnityTestCase {
        name: "RunningApplicationsGrid"
        when: windowShown

        function init() {
            runningApplicationsGrid.terminationModeEnabled = false
            resetRunningApplications()
        }

        property var browserTile
        property var phoneTile

        property var isBrowserLongPressed: false
        function onBrowserLongPressed() {isBrowserLongPressed = true}

        property var isPhoneLongPressed: false
        function onPhoneLongPressed() {isPhoneLongPressed = true}

        // Tiles should go to termination mode when any one of them is long-pressed.
        // Long-pressing when they're in termination mode brings them back to activation mode
        function test_enterTerminationMode() {
            browserTile = findChild(runningApplicationsGrid, "runningAppTile Browser")
            verify(browserTile != undefined)
            browserTile.onPressAndHold.connect(onBrowserLongPressed)

            phoneTile = findChild(runningApplicationsGrid, "runningAppTile Phone")
            verify(phoneTile != undefined)
            phoneTile.onPressAndHold.connect(onPhoneLongPressed)

            compare(browserTile.terminationModeEnabled, false)
            compare(phoneTile.terminationModeEnabled, false)
            compare(runningApplicationsGrid.terminationModeEnabled, false)

            isBrowserLongPressed = false
            mousePress(browserTile, browserTile.width/2, browserTile.height/2)
            tryCompareFunction(checkSwitchToTerminationModeAfterLongPress, true)

            mouseRelease(browserTile, browserTile.width/2, browserTile.height/2)

            compare(browserTile.terminationModeEnabled, true)
            compare(phoneTile.terminationModeEnabled, true)
            compare(runningApplicationsGrid.terminationModeEnabled, true)

            isPhoneLongPressed = false
            mousePress(phoneTile, phoneTile.width/2, phoneTile.height/2)
            tryCompareFunction(checkSwitchToActivationModeAfterLongPress, true)

            mouseRelease(phoneTile, phoneTile.width/2, phoneTile.height/2)

            compare(browserTile.terminationModeEnabled, false)
            compare(phoneTile.terminationModeEnabled, false)
            compare(runningApplicationsGrid.terminationModeEnabled, false)

            browserTile.onPressAndHold.disconnect(onBrowserLongPressed)
            phoneTile.onPressAndHold.disconnect(onPhoneLongPressed)
        }

        // Checks that components swicth to termination mode after (and only after) a long
        // press happens on Browser tile.
        function checkSwitchToTerminationModeAfterLongPress() {
            compare(browserTile.terminationModeEnabled, isBrowserLongPressed)
            compare(phoneTile.terminationModeEnabled, isBrowserLongPressed)
            compare(runningApplicationsGrid.terminationModeEnabled, isBrowserLongPressed)

            return isBrowserLongPressed &&
                browserTile.terminationModeEnabled &&
                phoneTile.terminationModeEnabled &&
                runningApplicationsGrid.terminationModeEnabled
        }

        // Checks that components swicth to activation mode after (and only after) a long
        // press happens on Phone tile.
        function checkSwitchToActivationModeAfterLongPress() {
            compare(browserTile.terminationModeEnabled, !isPhoneLongPressed)
            compare(phoneTile.terminationModeEnabled, !isPhoneLongPressed)
            compare(runningApplicationsGrid.terminationModeEnabled, !isPhoneLongPressed)

            return isPhoneLongPressed &&
                !browserTile.terminationModeEnabled &&
                !phoneTile.terminationModeEnabled &&
                !runningApplicationsGrid.terminationModeEnabled
        }

        // While on termination mode, clicking a running application tile, outside of
        // the close icon should do nothing
        function test_clickTileNotClose() {
            runningApplicationsGrid.terminationModeEnabled = true

            var browserTile = findChild(runningApplicationsGrid, "runningAppTile Browser")
            verify(browserTile != undefined)

            verify(ApplicationManager.findApplication("webbrowser-app") !== null)

            mouseClick(browserTile, browserTile.width/2, browserTile.height/2)

            verify(ApplicationManager.findApplication("webbrowser-app") !== null)

            // The tile for the Browser app should stay there
            tryCompareFunction(checkBrowserTileExists, true)
        }

        // While in termination mode, clicking on a running application tile's close icon
        // causes the corresponding application to be terminated
        function test_clickCloseIconToTerminateApp() {
            runningApplicationsGrid.terminationModeEnabled = true

            var browserTile = findChild(runningApplicationsGrid, "runningAppTile Browser")
            var browserTileCloseButton = findChild(runningApplicationsGrid, "closeIcon Browser")

            verify(browserTile != undefined)
            verify(browserTileCloseButton != undefined)
            verify(ApplicationManager.findApplication("webbrowser-app") !== 0)

            mouseClick(browserTileCloseButton, browserTileCloseButton.width/2, browserTileCloseButton.height/2)
            wait(0) // spin event loop to start any pending animation

            verify(ApplicationManager.findApplication("webbrowser-app") === null)

            // The tile for the Browser app should eventually vanish since the
            // application has been terminated.
            tryCompareFunction(checkBrowserTileExists, false)
        }

        function checkBrowserTileExists() {
            return findChild(runningApplicationsGrid, "runningAppTile Browser")
                    != undefined
        }

        // While in termination mode, if you click outside any of the tiles, the
        // termination mode is disabled (i.e. we switch back to activation mode).
        function test_clickOutsideTilesDisablesTerminationMode() {
            runningApplicationsGrid.terminationModeEnabled = true

            var browserTile = findChild(runningApplicationsGrid, "runningAppTile Browser")
            verify(browserTile != undefined)

            verify(runningApplicationsGrid.terminationModeEnabled);

            // Click on the bottom right corner of the grid, where there's no
            // RunningApplicationTile lying around
            mouseClick(runningApplicationsGrid,
                       runningApplicationsGrid.width - 1, runningApplicationsGrid.height - 1);

            wait(0) // spin event loop to ensure that any pending signal emission went through

            verify(!runningApplicationsGrid.terminationModeEnabled);
        }
    }
}
