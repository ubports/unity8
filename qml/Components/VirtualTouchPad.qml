/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import UInput 0.1

Item {
    id: root
    property var uinput: UInput {
        Component.onCompleted: createMouse();
        Component.onDestruction: removeMouse();
    }

    function runTutorial() {
        tutorial.start()
    }

    readonly property bool pressed: point1.pressed || point2.pressed || leftButton.pressed || rightButton.pressed

    MultiPointTouchArea {
        objectName: "touchPadArea"
        anchors.fill: parent

        // FIXME: Once we have Qt DPR support, this should be Qt.styleHints.startDragDistance
        readonly property int clickThreshold: internalGu * 1.5
        property bool isClick: false
        property bool isDoubleClick: false
        property bool isDrag: false

        onPressed: {
            // If double-tapping *really* fast, it could happen that we end up having only point2 pressed
            // Make sure we check for both combos, only point1 or only point2
            if (((point1.pressed && !point2.pressed) || (!point1.pressed && point2.pressed))
                    && clickTimer.running) {
                clickTimer.stop();
                uinput.pressMouse(UInput.ButtonLeft)
                isDoubleClick = true;
            }
            isClick = true;
        }

        onUpdated: {
            switch (touchPoints.length) {
            case 1:
                moveMouse(touchPoints);
                return;
            case 2:
                scroll(touchPoints);
                return;
            }
        }

        onReleased: {
            if (isDoubleClick || isDrag) {
                uinput.releaseMouse(UInput.ButtonLeft)
                isDoubleClick = false;
            }
            if (isClick) {
                clickTimer.scheduleClick(point1.pressed ? UInput.ButtonRight : UInput.ButtonLeft)
            }
            isClick = false;
            isDrag = false;
        }

        Timer {
            id: clickTimer
            repeat: false
            interval: 200
            property int button: UInput.ButtonLeft
            onTriggered: {
                uinput.pressMouse(button);
                uinput.releaseMouse(button);
            }
            function scheduleClick(button) {
                clickTimer.button = button;
                clickTimer.start();
            }
        }

        function moveMouse(touchPoints) {
            var tp = touchPoints[0];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
                isDrag = true;
            }

            uinput.moveMouse(tp.x - tp.previousX, tp.y - tp.previousY);
        }

        function scroll(touchPoints) {
            var dh = 0;
            var dv = 0;
            var tp = touchPoints[0];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
            }
            dh += tp.x - tp.previousX;
            dv += tp.y - tp.previousY;

            tp = touchPoints[1];
            if (isClick &&
                    (Math.abs(tp.x - tp.startX) > clickThreshold ||
                     Math.abs(tp.y - tp.startY) > clickThreshold)) {
                isClick = false;
            }
            dh += tp.x - tp.previousX;
            dv += tp.y - tp.previousY;

            // As we added up the movement of the two fingers, let's divide it again by 2
            dh /= 2;
            dv /= 2;

            uinput.scrollMouse(dh, dv);
        }

        touchPoints: [
            TouchPoint {
                id: point1
            },
            TouchPoint {
                id: point2
            }
        ]
    }

    RowLayout {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: -units.gu(1) }
        height: units.gu(10)
        spacing: units.gu(1)

        MouseArea {
            id: leftButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPressed: uinput.pressMouse(UInput.ButtonLeft);
            onReleased: uinput.releaseMouse(UInput.ButtonLeft);
            property bool highlight: false
            UbuntuShape {
                anchors.fill: parent
                backgroundColor: leftButton.highlight || leftButton.pressed ? UbuntuColors.ash : UbuntuColors.inkstone
                Behavior on backgroundColor { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
            }
        }

        MouseArea {
            id: rightButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPressed: uinput.pressMouse(UInput.ButtonRight);
            onReleased: uinput.releaseMouse(UInput.ButtonRight);
            property bool highlight: false
            UbuntuShape {
                anchors.fill: parent
                backgroundColor: rightButton.highlight || rightButton.pressed ? UbuntuColors.ash : UbuntuColors.inkstone
                Behavior on backgroundColor { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
            }
        }
    }

    Label {
        id: tutorialLabel
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(4); topMargin: units.gu(10) }
        opacity: 0
        fontSize: "large"
        color: "white"
        wrapMode: Text.WordWrap
    }

    Item {
        id: tutorialFinger1
        width: units.gu(5)
        height: width
        property real scale: 1
        opacity: 0
        Rectangle {
            width: parent.width * parent.scale
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: UbuntuColors.inkstone
        }
    }

    Item {
        id: tutorialFinger2
        width: units.gu(5)
        height: width
        property real scale: 1
        opacity: 0
        Rectangle {
            width: parent.width * parent.scale
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: UbuntuColors.inkstone
        }
    }

    SequentialAnimation {
        id: tutorial
        PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Tap left button to click") }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        SequentialAnimation {
            loops: 2
            PropertyAction { target: leftButton; property: "highlight"; value: true }
            PauseAnimation { duration: UbuntuAnimation.FastDuration }
            PropertyAction { target: leftButton; property: "highlight"; value: false }
            PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }

        PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Tap right button to right click") }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        SequentialAnimation {
            loops: 2
            PropertyAction { target: rightButton; property: "highlight"; value: true }
            PauseAnimation { duration: UbuntuAnimation.FastDuration }
            PropertyAction { target: rightButton; property: "highlight"; value: false }
            PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }

        PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Swipe with two fingers to scroll") }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        PropertyAction { target: tutorialFinger1; property: "x"; value: root.width / 2 - tutorialFinger1.width - units.gu(1) }
        PropertyAction { target: tutorialFinger2; property: "x"; value: root.width / 2 + tutorialFinger1.width + units.gu(1) - tutorialFinger2.width }
        PropertyAction { target: tutorialFinger1; property: "y"; value: root.height / 2 - units.gu(10) }
        PropertyAction { target: tutorialFinger2; property: "y"; value: root.height / 2 - units.gu(10) }
        SequentialAnimation {
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "y"; to: root.height / 2 + units.gu(10); duration: UbuntuAnimation.SleepyDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "y"; to: root.height / 2 + units.gu(10); duration: UbuntuAnimation.SleepyDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
            }
            PauseAnimation { duration: UbuntuAnimation.SlowDuration }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "y"; to: root.height / 2 - units.gu(10); duration: UbuntuAnimation.SleepyDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "y"; to: root.height / 2 - units.gu(10); duration: UbuntuAnimation.SleepyDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
            }
            PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
    }
}
