/*
 * Copyright 2013,2015 Canonical Ltd.
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
import "../../../qml/Components"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import "tst_LazyImage"

Rectangle {
    width: units.gu(120)
    height: units.gu(70)

    Rectangle {
        id: baseRect
        anchors {
            fill: parent
            rightMargin: 2 * parent.width / 3
        }

        color: theme.palette.normal.baseText

        Column {
            anchors { fill: parent; margins: units.gu(5) }

            Label {
                height: units.gu(4)
                text: "Unbound"
                color: "white"
                verticalAlignment: Text.AlignBottom
            }

            LazyImage {
                id: lazy1
            }

            Label {
                height: units.gu(4)
                text: "Width-bound"
                color: "white"
                verticalAlignment: Text.AlignBottom
            }

            LazyImage {
                id: lazy2
                width: units.gu(30)
                scaleTo: "width"
            }

            Label {
                height: units.gu(4)
                text: "Height-bound"
                color: "white"
                verticalAlignment: Text.AlignBottom
            }

            LazyImage {
                id: lazy3
                height: units.gu(12)
                scaleTo: "height"
            }

            Label {
                height: units.gu(4)
                text: "Fit"
                color: "white"
                verticalAlignment: Text.AlignBottom
            }

            LazyImage {
                id: lazy4
                height: units.gu(12)
                width: units.gu(12)
                scaleTo: "fit"
            }
        }
    }

    Rectangle {
        id: controlsRect
        anchors {
            fill: parent
            leftMargin: parent.width / 3
        }

        color: "lightgrey"

        Column {
            id: controls
            spacing: units.gu(1)

            anchors { fill: parent; margins: units.gu(3) }

            ImageControls { id: controls1; image: lazy1 }
            ImageControls { id: controls2; image: lazy2 }
            ImageControls { id: controls3; image: lazy3 }
            ImageControls { id: controls4; image: lazy4 }
        }
    }

    SignalSpy {
        id: signalSpy
        signalName: "runningChanged"
    }

    UT.UnityTestCase {
        name: "LazyImage"
        when: windowShown

        function cleanup() {
            controls1.blank();
            tryCompare(lazy1, "width", units.gu(10));
            controls2.blank();
            tryCompare(lazy2, "height", units.gu(10));
            controls3.blank();
            tryCompare(lazy3, "width", units.gu(10));

            tryCompare(lazy1, "state", "default");
            var transition = findChildIn(lazy1, "transitions", "genericTransition");
            tryCompare(transition, "running", false);

            tryCompare(lazy2, "state", "default");
            transition = findChildIn(lazy2, "transitions", "genericTransition");
            tryCompare(transition, "running", false);

            tryCompare(lazy3, "state", "default");
            transition = findChildIn(lazy3, "transitions", "genericTransition");
            tryCompare(transition, "running", false);
        }

        function test_lazyimage_data() {
            return [
                {tag: "Unbound Blank", image: lazy1, func: controls1.blank, width: units.gu(10), height: units.gu(10), imageWidth: units.gu(10), imageHeight: units.gu(10), initialWidth: units.gu(10), initialHeight: units.gu(10), placeholder: true},
                {tag: "Unbound Wide", image: lazy1, func: controls1.wide, transition: "readyTransition", width: 160, height: 80, imageWidth: 160, imageHeight: 80, initialWidth: units.gu(10), initialHeight: units.gu(10)},
                {tag: "Unbound Square", image: lazy1, func: controls1.square, transition: "readyTransition", width: 160, height: 160, imageWidth: 160, imageHeight: 160, initialWidth: units.gu(10), initialHeight: units.gu(10)},
                {tag: "Unbound Portrait", image: lazy1, func: controls1.portrait, transition: "readyTransition", width: 80, height: 160, imageWidth: 80, imageHeight: 160, initialWidth: units.gu(10), initialHeight: units.gu(10)},
                {tag: "Unbound Bad path", image: lazy1, func: controls1.badpath, transition: "genericTransition", state: "error", width: units.gu(10), height: units.gu(10), imageWidth: units.gu(10), imageHeight: units.gu(10), initialWidth: units.gu(10), initialHeight: units.gu(10), placeholder: true, error: true},
                {tag: "Width-bound Blank", image: lazy2, func: controls2.blank, width: units.gu(30), height: units.gu(10), imageWidth: units.gu(30), imageHeight: units.gu(10), initialWidth: units.gu(30), initialHeight: units.gu(10), placeholder: true},
                {tag: "Width-bound Wide", image: lazy2, func: controls2.wide, transition: "readyTransition", width: units.gu(30), height: units.gu(15), imageWidth: units.gu(30), imageHeight: units.gu(15), initialWidth: units.gu(30), initialHeight: units.gu(10)},
                {tag: "Width-bound Square", image: lazy2, func: controls2.square, transition: "readyTransition", width: units.gu(30), height: units.gu(30), imageWidth: units.gu(30), imageHeight: units.gu(30), initialWidth: units.gu(30), initialHeight: units.gu(10)},
                {tag: "Width-bound Portrait", image: lazy2, func: controls2.portrait, transition: "readyTransition", width: units.gu(30), height: units.gu(60), imageWidth: units.gu(30), imageHeight: units.gu(60), initialWidth: units.gu(30), initialHeight: units.gu(10)},
                {tag: "Width-bound Bad path", image: lazy2, func: controls2.badpath, transition: "genericTransition", state: "error", width: units.gu(30), height: units.gu(10), imageWidth: units.gu(30), imageHeight: units.gu(10), initialWidth: units.gu(30), initialHeight: units.gu(10), placeholder: true, error: true},
                {tag: "Height-bound Blank", image: lazy3, func: controls3.blank, width: units.gu(10), height: units.gu(12), imageWidth: units.gu(10), imageHeight: units.gu(12), initialWidth: units.gu(10), initialHeight: units.gu(12), placeholder: true},
                {tag: "Height-bound Wide", image: lazy3, func: controls3.wide, transition: "readyTransition", width: units.gu(24), height: units.gu(12), imageWidth: units.gu(24), imageHeight: units.gu(12), initialWidth: units.gu(10), initialHeight: units.gu(12)},
                {tag: "Height-bound Square", image: lazy3, func: controls3.square, transition: "readyTransition", width: units.gu(12), height: units.gu(12), imageWidth: units.gu(12), imageHeight: units.gu(12), initialWidth: units.gu(10), initialHeight: units.gu(12)},
                {tag: "Height-bound Portrait", image: lazy3, func: controls3.portrait, transition: "readyTransition", width: units.gu(6), height: units.gu(12), imageWidth: units.gu(6), imageHeight: units.gu(12), initialWidth: units.gu(10), initialHeight: units.gu(12)},
                {tag: "Height-bound Bad path", image: lazy3, func: controls3.badpath, transition: "genericTransition", state: "error", width: units.gu(10), height: units.gu(12), imageWidth: units.gu(10), imageHeight: units.gu(12), initialWidth: units.gu(10), initialHeight: units.gu(12), placeholder: true, error: true},
                {tag: "Fit Blank", image: lazy4, func: controls4.blank, width: units.gu(12), height: units.gu(12), imageWidth: units.gu(12), imageHeight: units.gu(12), initialWidth: units.gu(12), initialHeight: units.gu(12), placeholder: true},
                {tag: "Fit Wide", image: lazy4, func: controls4.wide, transition: "readyTransition", width: units.gu(12), height: units.gu(12), imageWidth: units.gu(12), imageHeight: units.gu(6), initialWidth: units.gu(12), initialHeight: units.gu(12)},
                {tag: "Fit Square", image: lazy4, func: controls4.square, transition: "readyTransition", width: units.gu(12), height: units.gu(12), imageWidth: units.gu(12), imageHeight: units.gu(12), initialWidth: units.gu(12), initialHeight: units.gu(12)},
                {tag: "Fit Portrait", image: lazy4, func: controls4.portrait, transition: "readyTransition", width: units.gu(12), height: units.gu(12), imageWidth: units.gu(6), imageHeight: units.gu(12), initialWidth: units.gu(12), initialHeight: units.gu(12)},
                {tag: "Fit Bad path", image: lazy4, func: controls4.badpath, transition: "genericTransition", state: "error", width: units.gu(12), height: units.gu(12), imageWidth: units.gu(12), imageHeight: units.gu(12), initialWidth: units.gu(12), initialHeight: units.gu(12), placeholder: true, error: true},
            ]
        }

        function test_lazyimage(data) {
            var transition = findChildIn(data.image, "transitions", data.transition);
            signalSpy.target = transition;
            signalSpy.clear();

            data.func();

            if (data.transition) {
                tryCompare(data.image, "state", data.state ? data.state : "ready");
                tryCompare(transition, "running", false);
            }

            // check the dimensions
            compare(data.image.width, data.width);
            compare(data.image.height, data.height);

            // check initial dimensions
            compare(data.image.initialHeight, data.initialHeight);
            compare(data.image.initialWidth, data.initialWidth);

            // check the sourceSize
            var sourceHeight = (data.image.scaleTo === "height" || (data.image.scaleTo === "fit" && data.height <= data.width)) ? data.height : 0
            var sourceWidth = (data.image.scaleTo === "width" || (data.image.scaleTo === "fit" && data.width <= data.height)) ? data.width : 0
            compare(data.image.sourceSize.height, sourceHeight);
            compare(data.image.sourceSize.width, sourceWidth);

            // check the shape dimensions
            var shape = findChild(data.image, "shape");
            compare(shape.width, data.imageWidth);
            compare(shape.height, data.imageHeight);

            // check the placeholder
            var placeholder = findChild(data.image, "placeholder");
            compare(placeholder.visible, data.placeholder ? true : false);

            // check the error image
            var error = findChild(data.image, "errorImage");
            tryCompare(error, "visible", data.error ? true : false);
        }
    }
}
