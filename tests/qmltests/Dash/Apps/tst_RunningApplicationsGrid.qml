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
import "../../../../Dash/Apps"
import Unity.Test 0.1 as UT

Item {
    width: units.gu(50)
    height: units.gu(40)

    QtObject {
        id: fakeApplicationManager

        property bool sideStageEnabled: false

        function stopApplication(appId) {
            for (var i=0, len=fakeRunningAppsModel.count; i<len; i++) {
                if (appId == fakeRunningAppsModel.get(i).appId) {
                    fakeRunningAppsModel.remove(i)
                }
            }
        }
    }

    QtObject {
        id: shell
        property bool dashShown: true
        property bool stageScreenshotsReady: false
        property var applicationManager: fakeApplicationManager

        function activateApplication(appId) {
        }
    }

    ListModel {
        id: fakeRunningAppsModel

        function contains(appId) {
            for (var i=0, len=fakeRunningAppsModel.count; i<len; i++) {
                if (appId == fakeRunningAppsModel.get(i).appId) {
                    return true;
                }
            }
            return false;
        }

        function rePopulate() {
            for (var i=0, len=availableAppsModel.count; i<len; i++) {
                fakeRunningAppsModel.append(availableAppsModel.get(i));
            }
        }
    }

    ListModel {
        id: availableAppsModel
        ListElement {
            name: "Phone"
            icon: "phone-app"
            exec: "/usr/bin/phone-app"
            appId: "phone"
            imageQml: "import QtQuick 2.0\n \
                       Rectangle { \n \
                          anchors.fill:parent \n \
                          color:'darkgreen' \n \
                          Text { anchors.centerIn: parent; text: 'PHONE' } \n \
                      }"
        }

        ListElement {
            name: "Calendar"
            icon: "calendar-app"
            exec: "/usr/bin/calendar-app"
            appId: "calendar"
            imageQml: "import QtQuick 2.0\n \
                       Rectangle { \n \
                           anchors.fill:parent \n \
                           color:'darkblue' \n \
                           Text { anchors.centerIn: parent; text: 'CALENDAR'\n \
                                  color:'white'} \n \
                      }"
        }
    }

    function resetRunningApplications() {
        fakeRunningAppsModel.clear()
        fakeRunningAppsModel.rePopulate()
    }

    Component.onCompleted: {
        resetRunningApplications()
    }

    // The component under test
    RunningApplicationsGrid {
        id: runningApplicationsGrid
        anchors.fill: parent
        firstModel: fakeRunningAppsModel
    }

    UT.UnityTestCase {
        name: "RunningApplicationsGrid"
        when: windowShown

        function init() {
            runningApplicationsGrid.terminationModeEnabled = false
            resetRunningApplications()
        }

        property var calendarTile
        property var phoneTile

        property var isCalendarLongPressed: false
        function onCalendarLongPressed() {isCalendarLongPressed = true}

        property var isPhoneLongPressed: false
        function onPhoneLongPressed() {isPhoneLongPressed = true}

        // Tiles should go to termination mode when any one of them is long-pressed.
        // Long-pressing when they're in termination mode brings them back to activation mode
        function test_enterTerminationMode() {
            calendarTile = findChild(runningApplicationsGrid, "runningAppTile Calendar")
            verify(calendarTile != undefined)
            calendarTile.onPressAndHold.connect(onCalendarLongPressed)

            phoneTile = findChild(runningApplicationsGrid, "runningAppTile Phone")
            verify(phoneTile != undefined)
            phoneTile.onPressAndHold.connect(onPhoneLongPressed)

            compare(calendarTile.terminationModeEnabled, false)
            compare(phoneTile.terminationModeEnabled, false)
            compare(runningApplicationsGrid.terminationModeEnabled, false)

            isCalendarLongPressed = false
            mousePress(calendarTile, calendarTile.width/2, calendarTile.height/2)
            tryCompareFunction(checkSwitchToTerminationModeAfterLongPress, true)

            mouseRelease(calendarTile, calendarTile.width/2, calendarTile.height/2)

            compare(calendarTile.terminationModeEnabled, true)
            compare(phoneTile.terminationModeEnabled, true)
            compare(runningApplicationsGrid.terminationModeEnabled, true)

            isPhoneLongPressed = false
            mousePress(phoneTile, phoneTile.width/2, phoneTile.height/2)
            tryCompareFunction(checkSwitchToActivationModeAfterLongPress, true)

            mouseRelease(phoneTile, phoneTile.width/2, phoneTile.height/2)

            compare(calendarTile.terminationModeEnabled, false)
            compare(phoneTile.terminationModeEnabled, false)
            compare(runningApplicationsGrid.terminationModeEnabled, false)

            calendarTile.onPressAndHold.disconnect(onCalendarLongPressed)
            phoneTile.onPressAndHold.disconnect(onPhoneLongPressed)
        }

        // Checks that components swicth to termination mode after (and only after) a long
        // press happens on Calendar tile.
        function checkSwitchToTerminationModeAfterLongPress() {
            compare(calendarTile.terminationModeEnabled, isCalendarLongPressed)
            compare(phoneTile.terminationModeEnabled, isCalendarLongPressed)
            compare(runningApplicationsGrid.terminationModeEnabled, isCalendarLongPressed)

            return isCalendarLongPressed &&
                calendarTile.terminationModeEnabled &&
                phoneTile.terminationModeEnabled &&
                runningApplicationsGrid.terminationModeEnabled
        }

        // Checks that components swicth to activation mode after (and only after) a long
        // press happens on Phone tile.
        function checkSwitchToActivationModeAfterLongPress() {
            compare(calendarTile.terminationModeEnabled, !isPhoneLongPressed)
            compare(phoneTile.terminationModeEnabled, !isPhoneLongPressed)
            compare(runningApplicationsGrid.terminationModeEnabled, !isPhoneLongPressed)

            return isPhoneLongPressed &&
                !calendarTile.terminationModeEnabled &&
                !phoneTile.terminationModeEnabled &&
                !runningApplicationsGrid.terminationModeEnabled
        }

        // While on termination mode, clicking a running application tile, outside of
        // the close icon should do nothing
        function test_clickTileToTerminateApp() {
            runningApplicationsGrid.terminationModeEnabled = true

            var calendarTile = findChild(runningApplicationsGrid, "runningAppTile Calendar")
            verify(calendarTile != undefined)

            verify(fakeRunningAppsModel.contains("calendar"))

            mouseClick(calendarTile, calendarTile.width/2, calendarTile.height/2)

            verify(fakeRunningAppsModel.contains("calendar"))

            // The tile for the Calendar app should stay there
            tryCompareFunction(checkCalendarTileExists, true)
        }

        // While in termination mode, clicking on a running application tile's close icon
        // causes the corresponding application to be terminated
        function test_clickCloseIconToTerminateApp() {
            runningApplicationsGrid.terminationModeEnabled = true

            var calendarTile = findChild(runningApplicationsGrid, "runningAppTile Calendar")
            var calendarTileCloseButton = findChild(runningApplicationsGrid, "closeIcon Calendar")

            verify(calendarTile != undefined)
            verify(calendarTileCloseButton != undefined)
            verify(fakeRunningAppsModel.contains("calendar"))

            mouseClick(calendarTileCloseButton, calendarTileCloseButton.width/2, calendarTileCloseButton.height/2)

            verify(!fakeRunningAppsModel.contains("calendar"))

            // The tile for the Calendar app should eventually vanish since the
            // application has been terminated.
            tryCompareFunction(checkCalendarTileExists, false)

        }

        function checkCalendarTileExists() {
            return findChild(runningApplicationsGrid, "runningAppTile Calendar")
                    != undefined
        }
    }
}
