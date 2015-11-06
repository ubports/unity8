/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4

QtObject {
    id: root

    // to be set from outside
    property Item spreadDelegate
    property Item background
    property Item window
    property Item screenshot

    function start() {
        if (window.orientationAngle === 0) {
            if (spreadDelegate.shellOrientationAngle === 90) {
                chosenAnimation = simple90Animation;
            } else if (spreadDelegate.shellOrientationAngle === 180) {
                chosenAnimation = halfLoopAnimation;
            } else if (spreadDelegate.shellOrientationAngle === 270) {
                chosenAnimation = moving90Animation;
            } else {
                chosenAnimation = null;
            }
        } else if (window.orientationAngle === 90) {
            if (spreadDelegate.shellOrientationAngle === 0) {
                chosenAnimation = simple90Animation;
            } else if (spreadDelegate.shellOrientationAngle === 180) {
                chosenAnimation = moving90Animation;
            } else if (spreadDelegate.shellOrientationAngle === 270) {
                chosenAnimation = halfLoopAnimation;
            } else {
                chosenAnimation = null;
            }
        } else if (window.orientationAngle === 180) {
            if (spreadDelegate.shellOrientationAngle === 0) {
                chosenAnimation = halfLoopAnimation;
            } else if (spreadDelegate.shellOrientationAngle === 90) {
                chosenAnimation = moving90Animation;
            } else if (spreadDelegate.shellOrientationAngle === 270) {
                chosenAnimation = simple90Animation;
            } else {
                chosenAnimation = null;
            }
        } else if (window.orientationAngle === 270) {
            if (spreadDelegate.shellOrientationAngle === 0) {
                chosenAnimation = moving90Animation;
            } else if (spreadDelegate.shellOrientationAngle === 90) {
                chosenAnimation = halfLoopAnimation;
            } else if (spreadDelegate.shellOrientationAngle === 180) {
                chosenAnimation = simple90Animation;
            } else {
                chosenAnimation = null;
            }
        }

        if (chosenAnimation)
            chosenAnimation.start();
    }

    // to be read from outside
    property bool running: chosenAnimation ? chosenAnimation.running : false

    property int duration: 450
    property int easingType: Easing.InOutCubic

    property int shortestDimension: spreadDelegate.width < spreadDelegate.height
                                    ? spreadDelegate.width : spreadDelegate.height
    property int longestDimension: spreadDelegate.width > spreadDelegate.height
                                   ? spreadDelegate.width : spreadDelegate.height
    property string longestAxis: spreadDelegate.width > spreadDelegate.height ? "x" : "y"

    property QtObject chosenAnimation

    function setup90Animation() {
        background.visible = true;

        screenshot.width = window.width;
        screenshot.height = window.height;
        screenshot.window.anchors.topMargin = window.window.anchors.topMargin;
        screenshot.take();
        screenshot.transformOriginX = root.shortestDimension / 2;
        screenshot.transformOriginY = root.shortestDimension / 2;
        screenshot.visible = true;

        window.rotation = 0;
        window.width = spreadDelegate.width;
        window.height = spreadDelegate.height;
        window.transformOriginX = root.shortestDimension / 2;
        window.transformOriginY = root.shortestDimension / 2;
    }

    function tearDown90Animation() {
        window.orientationAngle = spreadDelegate.shellOrientationAngle;
        screenshot.discard();
        screenshot.visible = false;
        background.visible = false;
    }

    property QtObject simple90Animation: SequentialAnimation {
        id: simple90Animation

        ScriptAction { script: setup90Animation() }
        ParallelAnimation {
            RotationAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                from: window.orientationAngle - spreadDelegate.shellOrientationAngle
                to: 0
                property: "transformRotationAngle"
            }
            RotationAnimation {
                target: root.screenshot
                duration: root.duration
                easing.type: root.easingType
                from: window.orientationAngle - spreadDelegate.shellOrientationAngle
                to: 0
                property: "transformRotationAngle"
            }
            NumberAnimation {
                target: root.screenshot
                duration: root.duration
                easing.type: root.easingType
                property: "opacity"
                from: 1.0
                to: 0.0
            }
            NumberAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                property: "opacity"
                from: 0.0
                to: 1.0
            }
        }
        ScriptAction { script: tearDown90Animation() }
    }

    property QtObject moving90Animation: SequentialAnimation {
        id: moving90Animation

        ScriptAction { script: setup90Animation() }
        ParallelAnimation {
            RotationAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                direction: RotationAnimation.Shortest
                from: window.orientationAngle - spreadDelegate.shellOrientationAngle
                to: 0
                property: "transformRotationAngle"
            }
            RotationAnimation {
                target: root.screenshot
                duration: root.duration
                easing.type: root.easingType
                direction: RotationAnimation.Shortest
                from: window.orientationAngle - spreadDelegate.shellOrientationAngle
                to: 0
                property: "transformRotationAngle"
            }
            NumberAnimation {
                target: root.screenshot
                duration: root.duration
                easing.type: root.easingType
                property: "opacity"
                from: 1.0
                to: 0.0
            }
            NumberAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                property: "opacity"
                from: 0.0
                to: 1.0
            }
            NumberAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                property: root.longestAxis
                from: root.longestDimension - root.shortestDimension
                to: 0
            }
            NumberAnimation {
                target: root.screenshot
                duration: root.duration
                easing.type: root.easingType
                property: root.longestAxis
                from: root.longestDimension - root.shortestDimension
                to: 0
            }
        }
        ScriptAction { script: tearDown90Animation() }
    }

    property QtObject halfLoopAnimation: SequentialAnimation {
        id: halfLoopAnimation

        ScriptAction { script: {
            background.visible = true;

            window.rotation = 0;
            window.width = spreadDelegate.width;
            window.height = spreadDelegate.height;
            window.transformOriginX = window.width / 2
            window.transformOriginY = window.height / 2
        } }
        ParallelAnimation {
            RotationAnimation {
                target: root.window
                duration: root.duration
                easing.type: root.easingType
                from: window.orientationAngle - spreadDelegate.shellOrientationAngle
                to: 0
                property: "transformRotationAngle"
            }
        }
        ScriptAction { script: {
            window.orientationAngle = spreadDelegate.shellOrientationAngle;
            background.visible = false;
        } }
    }
}
