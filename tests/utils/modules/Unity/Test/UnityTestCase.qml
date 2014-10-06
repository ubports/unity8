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
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

TestCase {
    TestUtil {id:util}

    // Fake implementation to be provided to items under test
    property var fakeDateTime: new function() {
        this.currentTimeMs = 0
        this.getCurrentTimeMs = function() {return this.currentTimeMs}
    }

    // Flickable won't recognise a single mouse move as dragging the flickable.
    // Use 5 steps because it's what
    // Qt uses in QQuickViewTestUtil::flick
    // speed is in pixels/second
    function mouseFlick(item, x, y, toX, toY, pressMouse, releaseMouse,
                        speed, iterations) {
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
        return findChildIn(obj, "children", objectName);
    }

    // Find an object with the given name in the children tree of "obj"
    // Including invisible children like animations, timers etc.
    // Note: you should use findChild if you're not sure you need this
    // as this tree is much bigger and might contain stuff that goes
    // away randomly.
    function findInvisibleChild(obj, objectName) {
        return findChildIn(obj, "data", objectName);
    }

    // Find a child in the named property
    function findChildIn(obj, prop, objectName) {
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

    // Type a full string instead of keyClick letter by letter
    // TODO: this is not ugly, this is uber-ugly and does not support
    // any special character. Remove the keyMap once keyClick(obj, char)
    // has landed in upstream Qt.
    function typeString(str) {
        var keyMap = {
            "a": Qt.Key_A,
            "b": Qt.Key_B,
            "c": Qt.Key_C,
            "d": Qt.Key_D,
            "e": Qt.Key_E,
            "f": Qt.Key_F,
            "g": Qt.Key_G,
            "h": Qt.Key_H,
            "i": Qt.Key_I,
            "j": Qt.Key_J,
            "k": Qt.Key_K,
            "l": Qt.Key_L,
            "m": Qt.Key_M,
            "n": Qt.Key_N,
            "o": Qt.Key_O,
            "p": Qt.Key_P,
            "q": Qt.Key_Q,
            "r": Qt.Key_R,
            "s": Qt.Key_S,
            "t": Qt.Key_T,
            "u": Qt.Key_U,
            "v": Qt.Key_V,
            "w": Qt.Key_W,
            "x": Qt.Key_X,
            "y": Qt.Key_Y,
            "z": Qt.Key_Z,
            "A": Qt.Key_A,
            "B": Qt.Key_B,
            "C": Qt.Key_C,
            "D": Qt.Key_D,
            "E": Qt.Key_E,
            "F": Qt.Key_F,
            "G": Qt.Key_G,
            "H": Qt.Key_H,
            "I": Qt.Key_I,
            "J": Qt.Key_J,
            "K": Qt.Key_K,
            "L": Qt.Key_L,
            "M": Qt.Key_M,
            "N": Qt.Key_N,
            "O": Qt.Key_O,
            "P": Qt.Key_P,
            "Q": Qt.Key_Q,
            "R": Qt.Key_R,
            "S": Qt.Key_S,
            "T": Qt.Key_T,
            "U": Qt.Key_U,
            "V": Qt.Key_V,
            "W": Qt.Key_W,
            "X": Qt.Key_X,
            "Y": Qt.Key_Y,
            "Z": Qt.Key_Z,
            "0": Qt.Key_0,
            "1": Qt.Key_1,
            "2": Qt.Key_2,
            "3": Qt.Key_3,
            "4": Qt.Key_4,
            "5": Qt.Key_5,
            "6": Qt.Key_6,
            "7": Qt.Key_7,
            "8": Qt.Key_8,
            "9": Qt.Key_9,
            " ": Qt.Key_Space,
        }
        for (var i = 0; i < str.length; i++) {
            keyClick(keyMap[str[i]])
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

    function touchEvent() {
        return UT.Util.touchEvent()
    }

    // speed is in pixels/second
    function touchFlick(item, x, y, toX, toY, beginTouch, endTouch, speed, iterations) {
        // Make sure the item is rendered
        waitForRendering(item);

        // Default to true for beginTouch if not present
        beginTouch = (beginTouch !== undefined) ? beginTouch : true

        // Default to true for endTouch if not present
        endTouch = (endTouch !== undefined) ? endTouch : true

        // Set a default speed if not specified
        speed = (speed !== undefined) ? speed : units.gu(10)

        // Set a default iterations if not specified
        var iterations = (iterations !== undefined) ? iterations : 5

        var distance = Math.sqrt(Math.pow(toX - x, 2) + Math.pow(toY - y, 2))
        var totalTime = (distance / speed) * 1000 /* converting speed to pixels/ms */

        var timeStep = totalTime / iterations
        var diffX = (toX - x) / iterations
        var diffY = (toY - y) / iterations
        if (beginTouch) {
            fakeDateTime.currentTimeMs += timeStep

            var event = touchEvent()
            event.press(0 /* touchId */, x, y)
            event.commit()
        }
        for (var i = 0; i < iterations; ++i) {
            fakeDateTime.currentTimeMs += timeStep
            if (i === iterations - 1) {
                // Avoid any rounding errors by making the last move be at precisely
                // the point specified
                wait(iterations / speed)
                var event = touchEvent()
                event.move(0 /* touchId */, toX, toY)
                event.commit()
            } else {
                wait(iterations / speed)
                var event = touchEvent()
                event.move(0 /* touchId */, x + (i + 1) * diffX, y + (i + 1) * diffY)
                event.commit()
            }
        }
        if (endTouch) {
            fakeDateTime.currentTimeMs += timeStep
            var event = touchEvent()
            event.release(0 /* touchId */, toX, toY)
            event.commit()
        }
    }

    function touchPinch(item, x1Start, y1Start, x1End, y1End, x2Start, y2Start, x2End, y2End) {
        // Make sure the item is rendered
        waitForRendering(item);

        var event1 = touchEvent();
        // first finger
        event1.press(0, x1Start, y1Start);
        event1.commit();
        // second finger
        event1.stationary(0);
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
        if (item.parent)
            return fetchRootItem(item.parent)
        else
            return item
    }

    function touchPress(item, x, y) {
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent()
        event.press(0 /* touchId */, rootPoint.x, rootPoint.y)
        event.commit()
    }

    function touchRelease(item, x, y) {
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent()
        event.release(0 /* touchId */, rootPoint.x, rootPoint.y)
        event.commit()
    }

    function tap(item, x, y) {
        var root = fetchRootItem(item)
        var rootPoint = item.mapToItem(root, x, y)

        var event = touchEvent()
        event.press(0 /* touchId */, rootPoint.x, rootPoint.y)
        event.commit()

        event = touchEvent()
        event.release(0 /* touchId */, rootPoint.x, rootPoint.y)
        event.commit()
    }

    Component.onCompleted: {
        UT.Util.ensureTouchRegistryInstalled();

        var rootItem = parent;
        while (rootItem.parent != undefined) {
            rootItem = rootItem.parent;
        }
        removeTimeConstraintsFromDirectionalDragAreas(rootItem);
    }

    /*
      In qmltests, sequences of touch events are sent all at once, unlike in "real life".
      Also qmltests might run really slowly, e.g. when run from inside virtual machines.
      Thus to remove a variable that qmltests cannot really control, namely time, this
      function removes all constraints from DirectionalDragAreas that are sensible to
      elapsed time.

      This effectively makes DirectionalDragAreas easier to fool.
     */
    function removeTimeConstraintsFromDirectionalDragAreas(item) {

        // use duck-typing to identify a DirectionalDragArea
        if (item.minSpeed != undefined
                && item.maxSilenceTime != undefined
                && item.compositionTime != undefined) {
            item.minSpeed = 0;
            item.maxSilenceTime = 60 * 60 * 1000;
            item.compositionTime = 0;
        } else {
            for (var i in item.children) {
                removeTimeConstraintsFromDirectionalDragAreas(item.children[i]);
            }
        }
    }
}
