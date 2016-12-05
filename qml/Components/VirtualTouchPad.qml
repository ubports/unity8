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
import Qt.labs.settings 1.0
import Unity.Screens 0.1
import UInput 0.1
import "../Components"

Item {
    id: root
    property var uinput: UInput {
        Component.onCompleted: createMouse();
        Component.onDestruction: removeMouse();
    }

    Component.onCompleted: {
        if (!settings.touchpadTutorialHasRun) {
            root.runTutorial()
        }
    }

    function runTutorial() {
        // If the tutorial animation is started too early, e.g. in Component.onCompleted,
        // root width & height might be reported as 0x0 still. As animations read their
        // values at startup and won't update them, lets make sure to only start once
        // we have some actual size.
        if (root.width > 0 && root.height > 0) {
            tutorial.start();
        } else {
            tutorialTimer.start();
        }
    }

    Timer {
        id: tutorialTimer
        interval: 50
        repeat: false
        running: false
        onTriggered: root.runTutorial();
    }

    readonly property bool pressed: point1.pressed || point2.pressed || leftButton.pressed || rightButton.pressed

    property var settings: Settings {
        objectName: "virtualTouchPadSettings"
        property bool touchpadTutorialHasRun: false
        property bool oskEnabled: true
    }

    MultiPointTouchArea {
        objectName: "touchPadArea"
        anchors.fill: parent
        enabled: !tutorial.running || tutorial.paused

        // FIXME: Once we have Qt DPR support, this should be Qt.styleHints.startDragDistance
        readonly property int clickThreshold: internalGu * 1.5
        property bool isClick: false
        property bool isDoubleClick: false
        property bool isDrag: false

        onPressed: {
            if (tutorial.paused) {
                tutorial.resume();
                return;
            }

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
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: -internalGu * 1 }
        height: internalGu * 10
        spacing: internalGu * 1

        MouseArea {
            id: leftButton
            objectName: "leftButton"
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
            objectName: "rightButton"
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

    AbstractButton {
        id: oskButton
        objectName: "oskButton"
        anchors { right: parent.right; top: parent.top; margins: internalGu * 2 }
        height: internalGu * 6
        width: height

        onClicked: {
            settings.oskEnabled = !settings.oskEnabled
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: UbuntuColors.inkstone
        }

        Icon {
            anchors.fill: parent
            anchors.margins: internalGu * 1.5
            name: "input-keyboard-symbolic"
        }
    }

    Screens {
        id: screens
    }

    InputMethod {
        id: inputMethod
        // Don't resize when there is only one screen to avoid resize clashing with the InputMethod in the Shell.
        enabled: screens.count > 1 && settings.oskEnabled && !tutorial.running
        objectName: "inputMethod"
        anchors.fill: parent
    }

    Label {
        id: tutorialLabel
        objectName: "tutorialLabel"
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: internalGu * 4; topMargin: internalGu * 10 }
        opacity: 0
        visible: opacity > 0
        font.pixelSize: 2 * internalGu
        color: "white"
        wrapMode: Text.WordWrap
    }

    Icon {
        id: tutorialImage
        objectName: "tutorialImage"
        height: internalGu * 8
        width: height
        name: "input-touchpad-symbolic"
        color: "white"
        opacity: 0
        visible: opacity > 0
        anchors { top: tutorialLabel.bottom; horizontalCenter: parent.horizontalCenter; margins: internalGu * 2 }
    }

    Item {
        id: tutorialFinger1
        objectName: "tutorialFinger1"
        width: internalGu * 5
        height: width
        property real scale: 1
        opacity: 0
        visible: opacity > 0
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
        objectName: "tutorialFinger2"
        width: internalGu * 5
        height: width
        property real scale: 1
        opacity: 0
        visible: opacity > 0
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
        objectName: "tutorialAnimation"

        PropertyAction { targets: [leftButton, rightButton, oskButton]; property: "enabled"; value: false }
        PropertyAction { targets: [leftButton, rightButton, oskButton]; property: "opacity"; value: 0 }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Your device is now connected to an external display. Use this screen as a touch pad to interact with the pointer.") }
        UbuntuNumberAnimation { targets: [tutorialLabel, tutorialImage]; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        PropertyAction { target: tutorial; property: "paused"; value: true }
        PauseAnimation { duration: 500 } // it takes a bit until pausing actually takes effect
        UbuntuNumberAnimation { targets: [tutorialLabel, tutorialImage]; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }

        UbuntuNumberAnimation { target: leftButton; property: "opacity"; to: 1 }
        UbuntuNumberAnimation { target: rightButton; property: "opacity"; to: 1 }

        PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Tap left button to click.") }
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
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Tap right button to right click.") }
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
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Swipe with two fingers to scroll.") }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        PropertyAction { target: tutorialFinger1; property: "x"; value: root.width / 2 - tutorialFinger1.width - internalGu * 1 }
        PropertyAction { target: tutorialFinger2; property: "x"; value: root.width / 2 + tutorialFinger1.width + internalGu * 1 - tutorialFinger2.width }
        PropertyAction { target: tutorialFinger1; property: "y"; value: root.height / 2 - internalGu * 10 }
        PropertyAction { target: tutorialFinger2; property: "y"; value: root.height / 2 - internalGu * 10 }
        SequentialAnimation {
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 0; to: 1; duration: UbuntuAnimation.FastDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "y"; to: root.height / 2 + internalGu * 10; duration: UbuntuAnimation.SleepyDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "y"; to: root.height / 2 + internalGu * 10; duration: UbuntuAnimation.SleepyDuration }
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
                UbuntuNumberAnimation { target: tutorialFinger1; property: "y"; to: root.height / 2 - internalGu * 10; duration: UbuntuAnimation.SleepyDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "y"; to: root.height / 2 - internalGu * 10; duration: UbuntuAnimation.SleepyDuration }
            }
            ParallelAnimation {
                UbuntuNumberAnimation { target: tutorialFinger1; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger1; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
                UbuntuNumberAnimation { target: tutorialFinger2; property: "scale"; from: 1; to: 0; duration: UbuntuAnimation.FastDuration }
            }
            PauseAnimation { duration: UbuntuAnimation.SlowDuration }
        }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }

        PauseAnimation { duration: UbuntuAnimation.SleepyDuration }
        PropertyAction { target: tutorialLabel; property: "text"; value: i18n.tr("Find more settings in the system settings.") }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 1; duration: UbuntuAnimation.FastDuration }
        PauseAnimation { duration: 2000 }
        UbuntuNumberAnimation { target: tutorialLabel; property: "opacity"; to: 0; duration: UbuntuAnimation.FastDuration }

        UbuntuNumberAnimation { target: oskButton; property: "opacity"; to: 1 }
        PropertyAction { targets: [leftButton, rightButton, oskButton]; property: "enabled"; value: true }

        PropertyAction { target: settings; property: "touchpadTutorialHasRun"; value: true }
    }
}
