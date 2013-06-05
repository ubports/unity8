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
import "../../../Components"

TestCase {
    id: testCase
    name: "AnimationControllerWithSignals"

    property real someNumber: 0.0

    NumberAnimation {
        id: someNumberAnimation
        target: testCase
        properties: "someNumber"
        from: 1.0
        to: 100.0
    }

    Component {
        id: testSubjectComponent
        AnimationControllerWithSignals {}
    }

    Loader {
        id: loader
        asynchronous: false
    }

    SignalSpy {
        id: signalSpy
    }

    function test_completeToEndWithSignal() {
        loader.sourceComponent = testSubjectComponent;
        var testSubject = loader.item;

        testSubject.animation = someNumberAnimation;
        testSubject.progress = 0;

        signalSpy.signalName = "animationCompletedAtEnd";
        signalSpy.target = testSubject;
        signalSpy.clear();

        compare(testSubject.completing, false)
        compare(testSubject.completed, true)

        testSubject.completeToEndWithSignal();
        compare(testSubject.completing, true)
        compare(testSubject.completed, true)
        compare(signalSpy.count, 0);

        testSubject.progress = 0.5;
        compare(testSubject.completing, true)
        compare(testSubject.completed, false)
        compare(signalSpy.count, 0);

        testSubject.progress = 1.0;
        compare(testSubject.completing, false)
        compare(testSubject.completed, true)
        compare(signalSpy.count, 1);

        testSubject.animation = null
        loader.sourceComponent = undefined;
    }

    function test_completeToBeginningWithSignal() {
        loader.sourceComponent = testSubjectComponent;
        var testSubject = loader.item;

        testSubject.animation = someNumberAnimation;
        testSubject.progress = 1;

        signalSpy.signalName = "animationCompletedAtBeginning";
        signalSpy.target = testSubject;
        signalSpy.clear();

        compare(testSubject.completing, false)
        compare(testSubject.completed, true)

        testSubject.completeToBeginningWithSignal();
        compare(testSubject.completing, true)
        compare(testSubject.completed, true)
        compare(signalSpy.count, 0);

        testSubject.progress = 0.5;
        compare(testSubject.completing, true)
        compare(testSubject.completed, false)
        compare(signalSpy.count, 0);

        testSubject.progress = 0;
        compare(testSubject.completing, false)
        compare(testSubject.completed, true)
        compare(signalSpy.count, 1);

        testSubject.animation = null
        loader.sourceComponent = undefined;
    }

    function test_settingProgressWithoutCallingCompleteWithSignal() {
        loader.sourceComponent = testSubjectComponent;
        var testSubject = loader.item;

        testSubject.animation = someNumberAnimation;
        testSubject.progress = 0;

        signalSpy.signalName = "animationCompletedAtEnd";
        signalSpy.target = testSubject;
        signalSpy.clear();

        compare(testSubject.completing, false)
        compare(testSubject.completed, true)

        testSubject.progress = 0.5;
        compare(testSubject.completing, false)
        compare(testSubject.completed, false)
        compare(signalSpy.count, 0);

        testSubject.progress = 1;
        compare(testSubject.completing, false)
        compare(testSubject.completed, true)
        compare(signalSpy.count, 0);

        testSubject.animation = null
        loader.sourceComponent = undefined;
    }
}
