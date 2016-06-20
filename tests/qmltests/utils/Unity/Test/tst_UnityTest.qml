/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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
import Unity.Test 0.1

TestCase {
    name: "UnityTest"

    Rectangle {
        id: rect
    }

    MockObjectForInstanceOfTestChild {
        id: testObject
    }

    Item {
        id: item
        Behavior on height {
            NumberAnimation {
                duration: 500
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 100
            }
        }
    }

    function test_direct() {
        compare(Util.isInstanceOf(rect, "QQuickRectangle"), true, "rect should be an instance of QQuickRectangle");
        compare(Util.isInstanceOf(Util, "TestUtil"), true, "Util should be an instance of TestUtil");
        compare(Util.isInstanceOf(testObject, "MockObjectForInstanceOfTestChild"), true, "testObject should be an instance of MockObjectForInstanceOfTestChild");
    }

    function test_inherited() {
        compare(Util.isInstanceOf(rect, "QQuickItem"), true, "rect should be an instance of QQuickItem");
        compare(Util.isInstanceOf(rect, "QObject"), true, "rect should be an instance of QObject");
        compare(Util.isInstanceOf(Util, "QObject"), true, "Util should be an instance of QObject");
        compare(Util.isInstanceOf(testObject, "MockObjectForInstanceOfTest"), true, "testObject should be an instance of MockObjectForInstanceOfTest");
        compare(Util.isInstanceOf(testObject, "QQuickRectangle"), true, "testObject should be an instance of QQuickRectangle");
    }

    function test_negative() {
        compare(Util.isInstanceOf(rect, "QQuickMouseArea"), false, "rect should not be an instance of MouseArea");
        compare(Util.isInstanceOf(Util, "QQuickItem"), false, "Util should not be an instance of QQuickItem");
    }

    function test_undefined() {
        compare(Util.isInstanceOf(undefined, "QObject"), false, "passing undefined should fail");
    }

    function test_behavior_waiting() {
        item.height = 100;
        verify(item.height != 100);

        item.width = 100;
        verify(item.width != 100);

        var date1 = new Date();
        Util.waitForBehaviors(item);
        var date2 = new Date();

        compare(item.height, 100);
        compare(item.width, 100);

        verify(date2 - date1 >= 500);
    }
}
