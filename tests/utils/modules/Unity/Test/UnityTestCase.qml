/*
 * Copyright 2013-2016 Canonical Ltd.
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
import Unity.Application 0.1
import Ubuntu.Components 1.3
import Ubuntu.Test 1.0 as UbuntuTest
import Unity.Test 0.1 as UT
import Utils 0.1

TestCase {
    id: testCase
    property var util: TestUtil {id:util}

    // This is needed for waitForRendering calls to return
    // if the watched element already got rendered
    Rectangle {
        id: rotatingRectangle
        width: units.gu(1)
        height: width
        parent: testCase.parent
        border { width: units.dp(1); color: "black" }
        opacity: 0.6

        visible: testCase.running

        RotationAnimation on rotation {
            running: rotatingRectangle.visible
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1000
        }
    }

    // Fake implementation to be provided to items under test
    property var fakeDateTime: new function() {
        this.currentTimeMs = 0
        this.getCurrentTimeMs = function() {return this.currentTimeMs}
    }

    // TODO This function can be removed altogether once we use Qt 5.7 which has the same feature
    function mouseClick(item, x, y, button, modifiers, delay) {
        if (!item)
            qtest_fail("no item given", 1);

        if (button === undefined)
            button = Qt.LeftButton;
        if (modifiers === undefined)
            modifiers = Qt.NoModifier;
        if (delay === undefined)
            delay = -1;
        if (x === undefined)
            x = item.width / 2;
        if (y === undefined)
            y = item.height / 2;
        if (!qtest_events.mouseClick(item, x, y, button, modifiers, delay))
            qtest_fail("window not shown", 2);
    }

    // TODO This function can be removed altogether once we use Qt 5.7 which has the same feature
    function mouseDoubleClick(item, x, y, button, modifiers, delay) {
        if (!item)
            qtest_fail("no item given", 1);

        if (button === undefined)
            button = Qt.LeftButton;
        if (modifiers === undefined)
            modifiers = Qt.NoModifier;
        if (delay === undefined)
            delay = -1;
        if (x === undefined)
            x = item.width / 2;
        if (y === undefined)
            y = item.height / 2;
        if (!qtest_events.mouseDoubleClick(item, x, y, button, modifiers, delay))
            qtest_fail("window not shown", 2)
    }

    // TODO This function can be removed altogether once we use Qt 5.7 which has the same feature
    function mousePress(item, x, y, button, modifiers, delay) {
        if (!item)
            qtest_fail("no item given", 1);

        if (button === undefined)
            button = Qt.LeftButton;
        if (modifiers === undefined)
            modifiers = Qt.NoModifier;
        if (delay === undefined)
            delay = -1;
        if (x === undefined)
            x = item.width / 2;
        if (y === undefined)
            y = item.height / 2;
        if (!qtest_events.mousePress(item, x, y, button, modifiers, delay))
            qtest_fail("window not shown", 2)
    }

    // TODO This function can be removed altogether once we use Qt 5.7 which has the same feature
    function mouseRelease(item, x, y, button, modifiers, delay) {
        if (!item)
            qtest_fail("no item given", 1);

        if (button === undefined)
            button = Qt.LeftButton;
        if (modifiers === undefined)
            modifiers = Qt.NoModifier;
        if (delay === undefined)
            delay = -1;
        if (x === undefined)
            x = item.width / 2;
        if (y === undefined)
            y = item.height / 2;
        if (!qtest_events.mouseRelease(item, x, y, button, modifiers, delay))
            qtest_fail("window not shown", 2)
    }


    // Flickable won't recognise a single mouse move as dragging the flickable.
    // Use 5 steps because it's what
    // Qt uses in QQuickViewTestUtil::flick
    // speed is in pixels/second
    function mouseFlick(item, x, y, toX, toY, pressMouse, releaseMouse,
                        speed, iterations) {
        if (!item)
            qtest_fail("no item given", 1);

        pressMouse = ((pressMouse != null) ? pressMouse : true); // Default to true for pressMouse if not present
        releaseMouse = ((releaseMouse != null) ? releaseMouse : true); // Default to true for releaseMouse if not present

        // set a default speed if not specified
        speed = (speed != null) ? speed : units.gu(10);

        // set a default iterations if not specified
        iterations = (iterations !== undefined) ? iterations : 5

        var distance = Math.sqrt(Math.pow(toX - x, 2) + Math.pow(toY - y, 2))
        var totalTime = (distance / speed) * 1000 /* converting speed to pixels/ms */

        var timeStep = totalTime / iterations
        var diffX = (toX - x) / iterations
        var diffY = (toY - y) / iterations
        if (pressMouse) {
            fakeDateTime.currentTimeMs += timeStep
            mousePress(item, x, y)
        }
        for (var i = 0; i < iterations; ++i) {
            fakeDateTime.currentTimeMs += timeStep
            if (i === iterations - 1) {
                // Avoid any rounding errors by making the last move be at precisely
                // the point specified
                mouseMove(item, toX, toY, iterations / speed)
            } else {
                mouseMove(item, x + (i + 1) * diffX, y + (i + 1) * diffY, iterations / speed)
            }
        }
        if (releaseMouse) {
            fakeDateTime.currentTimeMs += timeStep
            mouseRelease(item, toX, toY)
        }
    }


    // Find an object with the given name in the children tree of "obj"
    function findChild(obj, objectName) {
        if (!obj)
            qtest_fail("no obj given", 1);

        return findChildIn(obj, "children", objectName);
    }

    // Find an object with the given name in the children tree of "obj"
    // Including invisible children like animations, timers etc.
    // Note: you should use findChild if you're not sure you need this
    // as this tree is much bigger and might contain stuff that goes
    // away randomly.
    function findInvisibleChild(obj, objectName) {
        if (!obj)
            qtest_fail("no obj given", 1);

        return findChildIn(obj, "data", objectName);
    }

    // Find a child in the named property
    function findChildIn(obj, prop, objectName) {
        if (!obj)
            qtest_fail("no obj given", 1);

        var childs = new Array(0);
        childs.push(obj)
        while (childs.length > 0) {
            if (childs[0].objectName == objectName) {
                return childs[0]
            }
            for (var i in childs[0][prop]) {
                childs.push(childs[0][prop][i])
            }
            childs.splice(0, 1);
        }
        return null;
    }

    function findChildsByType(obj, typeName) {
        if (!obj)
            qtest_fail("no obj given", 1);

        var res = new Array(0);
        for (var i in obj.children) {
            var c = obj.children[i];
            if (UT.Util.isInstanceOf(c, typeName)) {
                res.push(c)
            }
            res = res.concat(findChildsByType(c, typeName));
        }
        return res;
    }

    // Type a full string instead of keyClick letter by letter
    function typeString(str) {
        for (var i = 0; i < str.length; i++) {
            keyClick(str[i])
        }
    }

    // Keeps executing a given parameter-less function until it returns the given
    // expected result or the timemout is reached (in which case a test failure
    // is generated)
    function tryCompareFunction(func, expectedResult, timeout) {
        var timeSpent = 0
        if (timeout === undefined)
            timeout = 5000;
        var success = false
        var actualResult
        while (timeSpent < timeout && !success) {
            actualResult = func()
            success = qtest_compareInternal(actualResult, expectedResult)
            if (success === false) {
                wait(50)
                timeSpent += 50
            }
        }

        var act = qtest_results.stringify(actualResult)
        var exp = qtest_results.stringify(expectedResult)
        if (!qtest_results.compare(success,
                                   "function returned unexpected result",
                                   act, exp,
                                   util.callerFile(), util.callerLine())) {
            throw new Error("QtQuickTest::fail")
        }
    }

    function flickToYEnd(item) {
        if (!item)
            qtest_fail("no item given", 1);

        var i = 0;
        var x = item.width / 2;
        var y = item.height - units.gu(1);
        var toY = units.gu(1);
        var maxIterations = 5 + item.contentHeight / item.height;
        while (i < maxIterations && !item.atYEnd) {
            touchFlick(item, x, y, x, toY);
            tryCompare(item, "moving", false);
            ++i;
        }
        tryCompare(item, "atYEnd", true);
    }

    function touchEvent(item) {
        return UT.Util.touchEvent(item)
    }

    // speed is in pixels/second
    function touchFlick(item, x, y, toX, toY, beginTouch, endTouch, speed, iterations) {
        if (!item)
            qtest_fail("no item given", 1);

        // Make sure the item is rendered
        waitForRendering(item);

        var root = fetchRootItem(item);
        var rootFrom = item.mapToItem(root, x, y);
        var rootTo = item.mapToItem(root, toX, toY);

        // Default to true for beginTouch if not present
        beginTouch = (beginTouch !== undefined) ? beginTouch : true

        // Default to true for endTouch if not present
        endTouch = (endTouch !== undefined) ? endTouch : true

        // Set a default speed if not specified
        speed = (speed !== undefined) ? speed : units.gu(10)

        // Set a default iterations if not specified
        var iterations = (iterations !== undefined) ? iterations : 10

        var distance = Math.sqrt(Math.pow(rootTo.x - rootFrom.x, 2) + Math.pow(rootTo.Y - rootFrom.y, 2))
        var totalTime = (distance / speed) * 1000 /* converting speed to pixels/ms */

        var timeStep = totalTime / iterations
        var diffX = (rootTo.x - rootFrom.x) / iterations
        var diffY = (rootTo.y - rootFrom.y) / iterations
        if (beginTouch) {
            fakeDateTime.currentTimeMs += timeStep

            var event = touchEvent(item)
            event.press(0 /* touchId */, rootFrom.x, rootFrom.y)
            event.commit()
        }
        for (var i = 0; i < iterations; ++i) {
            fakeDateTime.currentTimeMs += timeStep
            if (i === iterations - 1) {
                // Avoid any rounding errors by making the last move be at precisely
                // the point specified
                wait(iterations / speed)
                var event = touchEvent(item)
                event.move(0 /* touchId */, rootTo.x, rootTo.y)
                event.commit()
            } else {
                wait(iterations / speed)
                var event = touchEvent(item)
                event.move(0 /* touchId */, rootFrom.x + (i + 1) * diffX, rootFrom.y + (i + 1) * diffY)
                event.commit()
            }
        }
        if (endTouch) {
            fakeDateTime.currentTimeMs += timeStep
            var event = touchEvent(item)
            event.release(0 /* touchId */, rootTo.x, rootTo.y)
            event.commit()
        }
    }

    // perform a drag in the given direction until the given condition is true
    // The condition is a function to be evaluated after every step
    function touchDragUntil(item, startX, startY, stepX, stepY, condition) {
        if (!item)
            qtest_fail("no item given", 1);

        multiTouchDragUntil([0], item, startX, startY, stepX, stepY, condition);
    }

    function multiTouchDragUntil(touchIds, item, startX, startY, stepX, stepY, condition) {
        if (!item)
            qtest_fail("no item given", 1);

        var root = fetchRootItem(item);
        var pos = item.mapToItem(root, startX, startY);

        // convert step to scene coords
        {
            var stepStart = item.mapToItem(root, 0, 0);
            var stepEnd = item.mapToItem(root, stepX, stepY);
        }
        stepX = stepEnd.x - stepStart.x;
        stepY = stepEnd.y - stepStart.y;

        var event = touchEvent(item)
        for (var i = 0; i < touchIds.length; i++) {
            event.press(touchIds[i], pos.x, pos.y)
        }
        event.commit()

        // we have to stop at some point
        var maxSteps = 100;
        var stepsDone = 0;

        while (!condition() && stepsDone < maxSteps) {
            wait(25);
            fakeDateTime.currentTimeMs += 25;

            pos.x += stepX;
            pos.y += stepY;

            event = touchEvent(item);
            for (i = 0; i < touchIds.length; i++) {
                event.move(touchIds[i], pos.x, pos.y);
            }
            event.commit();

            stepsDone += 1;
        }

        event = touchEvent(item)
        for (i = 0; i < touchIds.length; i++) {
            event.release(touchIds[i], pos.x, pos.y)
        }
        event.commit()
    }

    function touchMove(item, tox, toy) {
        if (!item)
            qtest_fail("no item given", 1);

        multiTouchMove(0, item, tox, toy);
    }

    function multiTouchMove(touchId, item, tox, toy) {
        if (!item)
            qtest_fail("no item given", 1);

        if (typeof touchId !== "number") touchId = 0;
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, tox, toy)

        var event = touchEvent(item);
        event.move(touchId, rootPoint.x, rootPoint.y);
        event.commit();
    }

    function touchPinch(item, x1Start, y1Start, x1End, y1End, x2Start, y2Start, x2End, y2End) {
        if (!item)
            qtest_fail("no item given", 1);

        // Make sure the item is rendered
        waitForRendering(item);

        var event1 = touchEvent(item);
        // first finger
        event1.press(0, x1Start, y1Start);
        event1.commit();
        // second finger
        event1.move(0, x1Start, y1Start);
        event1.press(1, x2Start, y2Start);
        event1.commit();

        // pinch
        for (var i = 0.0; i < 1.0; i += 0.02) {
            event1.move(0, x1Start + (x1End - x1Start) * i, y1Start + (y1End - y1Start) * i);
            event1.move(1, x2Start + (x2End - x2Start) * i, y2Start + (y2End - y2Start) * i);
            event1.commit();
        }

        // release
        event1.release(0, x1End, y1End);
        event1.release(1, x2End, y2End);
        event1.commit();
    }

    function fetchRootItem(item) {
        if (!item)
            qtest_fail("no item given", 1);

        if (item.parent)
            return fetchRootItem(item.parent)
        else
            return item
    }

    function touchPress(item, x, y) {
        if (!item)
            qtest_fail("no item given", 1);

        multiTouchPress(0, item, x, y, []);
    }

    /*! \brief Release a touch point

      \param touchId The touchId to be pressed
      \param item The item
      \param x The x coordinate of the press, defaults to horizontal center
      \param y The y coordinate of the press, defaults to vertical center
      \param stationaryPoints An array of touchIds which are "already touched"
    */
    function multiTouchPress(touchId, item, x, y, stationaryPoints) {
        if (!item)
            qtest_fail("no item given", 1);

        if (typeof touchId !== "number") touchId = 0;
        if (typeof x !== "number") x = item.width / 2;
        if (typeof y !== "number") y = item.height / 2;
        if (typeof stationaryPoints !== "object") stationaryPoints = []
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent(item)
        event.press(touchId, rootPoint.x, rootPoint.y)
        for (var i = 0; i < stationaryPoints.length; i++) {
            event.stationary(stationaryPoints[i]);
        }
        event.commit()
    }

    function touchRelease(item, x, y) {
        if (!item)
            qtest_fail("no item given", 1);

        multiTouchRelease(0, item, x, y, []);
    }

    /*! \brief Release a touch point

      \param touchId The touchId to be released
      \param item The item
      \param x The x coordinate of the release, defaults to horizontal center
      \param y The y coordinate of the release, defaults to vertical center
      \param stationaryPoints An array of touchIds which are "still touched"
     */
    function multiTouchRelease(touchId, item, x, y, stationaryPoints) {
        if (!item)
            qtest_fail("no item given", 1);

        if (typeof touchId !== "number") touchId = 0;
        if (typeof x !== "number") x = item.width / 2;
        if (typeof y !== "number") y = item.height / 2;
        if (typeof stationaryPoints !== "object") stationaryPoints = []
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent(item)
        event.release(touchId, rootPoint.x, rootPoint.y)
        for (var i = 0; i < stationaryPoints.length; i++) {
            event.stationary(stationaryPoints[i]);
        }
        event.commit()
    }

    /*! \brief Tap the item with a touch event.

      \param item The item to be tapped
      \param x The x coordinate of the tap, defaults to horizontal center
      \param y The y coordinate of the tap, defaults to vertical center
     */
    function tap(item, x, y) {
        if (!item)
            qtest_fail("no item given", 1);

        multiTouchTap([0], item, x, y);
    }

    function multiTouchTap(touchIds, item, x, y) {
        if (!item)
            qtest_fail("no item given", 1);

        if (typeof touchIds !== "object") touchIds = [0];
        if (typeof x !== "number") x = item.width / 2;
        if (typeof y !== "number") y = item.height / 2;

        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent(item)
        for (var i = 0; i < touchIds.length; i++) {
            event.press(touchIds[i], rootPoint.x, rootPoint.y)
        }
        event.commit()

        event = touchEvent(item)
        for (i = 0; i < touchIds.length; i++) {
            event.release(touchIds[i], rootPoint.x, rootPoint.y)
        }
        event.commit()
    }


    Component.onCompleted: {
        var rootItem = parent;
        while (rootItem.parent != undefined) {
            rootItem = rootItem.parent;
        }
        removeTimeConstraintsFromSwipeAreas(rootItem);
    }

    /*
      In qmltests, sequences of touch events are sent all at once, unlike in "real life".
      Also qmltests might run really slowly, e.g. when run from inside virtual machines.
      Thus to remove a variable that qmltests cannot really control, namely time, this
      function removes all constraints from SwipeAreas that are sensible to
      elapsed time.

      This effectively makes SwipeAreas easier to fool.
     */
    function removeTimeConstraintsFromSwipeAreas(item) {
        if (!item)
            qtest_fail("no item given", 1);

        if (UT.Util.isInstanceOf(item, "UCSwipeArea")) {
            UbuntuTest.TestExtras.removeTimeConstraintsFromSwipeArea(item);
        } else {
            for (var i in item.children) {
                removeTimeConstraintsFromSwipeAreas(item.children[i]);
            }
        }
    }

    // TODO This function can be removed altogether once we use Qt 5.5 which has the same feature
    function waitForRendering(item, timeout) {
        if (timeout === undefined)
            timeout = 5000;
        if (!item)
            qtest_fail("No item given to waitForRendering", 1);
        return qtest_results.waitForRendering(item, timeout);
    }

    /*
      Wait until any transition animation has finished for the given StateGroup or Item
     */
    function waitUntilTransitionsEnd(stateGroup) {
        var transitions = stateGroup.transitions;
        for (var i = 0; i < transitions.length; ++i) {
            var transition = transitions[i];
            tryCompare(transition, "running", false, 2000);
        }
    }

    /*
         kill all (fake) running apps but unity8-dash, bringing Unity.Application back to its initial state
     */
    function killApps() {
        while (ApplicationManager.count > 1) {
            var appIndex = ApplicationManager.get(0).appId == "unity8-dash" ? 1 : 0
            var application = ApplicationManager.get(appIndex);
            ApplicationManager.stopApplication(application.appId);
            // wait until all zombie surfaces are gone. As MirSurfaceItems hold references over them.
            // They won't be gone until those surface items are destroyed.
            tryCompareFunction(function() { return application.surfaceList.count }, 0);
            tryCompare(application, "state", ApplicationInfo.Stopped);
        }
        compare(ApplicationManager.count, 1);
    }
}
