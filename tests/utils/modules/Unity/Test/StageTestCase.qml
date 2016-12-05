/*
 * Copyright 2016 Canonical Ltd.
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
import Unity.Application 0.1
import Ubuntu.Components 1.3

UnityTestCase {
    // set from outside
    property Item stage
    property QtObject topLevelSurfaceList: null

    /*
       Wait until the ApplicationWindow for the given surface id (from TopLevelWindowModel)  is fully loaded
       (ie, the real surface has replaced the splash screen)
     */
    function waitUntilAppWindowIsFullyLoaded(surfaceId) {
        var appDelegate = findChild(stage, "appDelegate_" + surfaceId);
        verify(appDelegate);
        var appWindow = findChild(appDelegate, "appWindow");
        verify(appWindow);
        var appWindowStates = findInvisibleChild(appWindow, "applicationWindowStateGroup");
        verify(appWindowStates);
        tryCompare(appWindowStates, "state", "surface");
        waitUntilTransitionsEnd(appWindowStates);
    }

    /*
        Returns the appDelegate of the first surface created by the app with the specified appId
     */
    function startApplication(appId) {
        try {
            var app = ApplicationManager.findApplication(appId);
            if (app) {
                for (var i = 0; i < topLevelSurfaceList.count; i++) {
                    if (topLevelSurfaceList.applicationAt(i).appId === appId) {
                        var appRepeater = findChild(stage, "appRepeater");
                        verify(appRepeater);
                        return appRepeater.itemAt(i);
                    }
                }
            }

            var surfaceId = topLevelSurfaceList.nextId;
            app = ApplicationManager.startApplication(appId);
            verify(app);
            waitUntilAppWindowIsFullyLoaded(surfaceId);
            compare(app.surfaceList.count, 1);

            return findChild(stage, "appDelegate_" + surfaceId);
        } catch(err) {
            throw new Error("startApplication("+appId+") called from line " +  util.callerLine(1) + " failed!");
        }
    }
}
