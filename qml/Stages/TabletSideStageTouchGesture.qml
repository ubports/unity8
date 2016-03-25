/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1

TouchGestureArea {
    id: root
    minimumTouchPoints: 3
    maximumTouchPoints: 3

    property bool enableDrag: true
    property Component dragComponent
    property var dragComponentProperties: undefined

    readonly property bool recognisedPress: status == TouchGestureArea.Recognized &&
                                            touchPoints.length >= minimumTouchPoints &&
                                            touchPoints.length <= maximumTouchPoints
    readonly property bool recognisedDrag: priv.wasRecognisedPress && dragging

    signal pressed(int x, int y)
    signal clicked
    signal dragStarted
    signal dropped
    signal cancelled

    onEnabledChanged: {
        if (!enabled) {
            if (priv.dragObject) root.cancelled();
            priv.wasRecognisedDrag = false;
            priv.wasRecognisedPress = false;
        }
    }

    onRecognisedPressChanged: {
        if (recognisedPress) {
            // get the app at the center of the gesture
            var centerX = 0;
            var centerY = 0;
            for (var i = 0; i < touchPoints.length; i++) {
                centerX += touchPoints[i].x;
                centerY += touchPoints[i].y;
            }
            centerX = centerX/touchPoints.length;
            centerY = centerY/touchPoints.length;

            pressed(centerX, centerY);
            priv.wasRecognisedPress = true;
        }
    }

    onStatusChanged: {
        if (status != TouchGestureArea.Recognized) {
            if (status == TouchGestureArea.Rejected) {
                root.cancelled();
            } else if (status == TouchGestureArea.WaitingForTouch) {
                if (priv.wasRecognisedPress) {
                    if (!priv.wasRecognisedDrag) {
                        root.clicked();
                    } else {
                        root.dropped();
                    }
                }
            }
            priv.wasRecognisedDrag = false;
            priv.wasRecognisedPress = false;
        }
    }

    onRecognisedDragChanged: {
        if (enableDrag && recognisedDrag) {
            priv.wasRecognisedDrag = true;
            root.dragStarted()
        }
    }

    QtObject {
        id: priv
        property var dragObject: null

        property bool wasRecognisedPress: false
        property bool wasRecognisedDrag: false
    }

    onCancelled: {
        if (priv.dragObject) {
            var obj = priv.dragObject;
            priv.dragObject = null;

            obj.Drag.cancel();
            obj.destroy();
        }
    }

    onDragStarted: {
        if (dragComponentProperties) {
            priv.dragObject = dragComponent.createObject(root, dragComponentProperties);
        } else {
            priv.dragObject = dragComponent.createObject(root);
        }
        priv.dragObject.Drag.start();
    }

    onDropped: {
        if (priv.dragObject) {
            var obj = priv.dragObject;
            priv.dragObject = null;

            obj.Drag.drop();
            obj.destroy();
        }
    }

    Binding {
        target: priv.dragObject
        when: priv.dragObject && priv.wasRecognisedDrag
        property: "x"
        value: {
            if (!priv.dragObject) return 0;
            var sum = 0;
            for (var i = 0; i < root.touchPoints.length; i++) {
                sum += root.touchPoints[i].x;
            }
            return sum/root.touchPoints.length - priv.dragObject.width/2;
        }
    }

    Binding {
        target: priv.dragObject
        when: priv.dragObject && priv.wasRecognisedDrag
        property: "y"
        value: {
            if (!priv.dragObject) return 0;
            var sum = 0;
            for (var i = 0; i < root.touchPoints.length; i++) {
                sum += root.touchPoints[i].y;
            }
            return sum/root.touchPoints.length - priv.dragObject.height/2;
        }
    }
}
