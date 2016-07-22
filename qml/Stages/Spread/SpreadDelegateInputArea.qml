import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import "../../Components"

Item {
    id: root

    property bool closeable: true
    readonly property real minSpeedToClose: units.gu(40)
    property bool zeroVelocityCounts: false

    readonly property alias containsMouse: mouseArea.containsMouse
    readonly property alias distance: d.distance

    signal clicked()
    signal close()

    QtObject {
        id: d
        property real distance: 0
        property bool moving: false
        property var dragEvents: []
        property real dragVelocity: 0

        // Can be replaced with a fake implementation during tests
        // property var __getCurrentTimeMs: function () { return new Date().getTime() }
        property var __dateTime: new function() {
            this.getCurrentTimeMs = function() {return new Date().getTime()}
        }

        function pushDragEvent(event) {
            var currentTime = __dateTime.getCurrentTimeMs()
            dragEvents.push([currentTime, event.x, event.y, getEventSpeed(currentTime, event)])
            cullOldDragEvents(currentTime)
            updateSpeed()
        }

        function cullOldDragEvents(currentTime) {
            // cull events older than 50 ms but always keep the latest 2 events
            for (var numberOfCulledEvents = 0; numberOfCulledEvents < dragEvents.length-2; numberOfCulledEvents++) {
                // dragEvents[numberOfCulledEvents][0] is the dragTime
                if (currentTime - dragEvents[numberOfCulledEvents][0] <= 50) break
            }

            dragEvents.splice(0, numberOfCulledEvents)
        }

        function updateSpeed() {
            var totalSpeed = 0
            for (var i = 0; i < dragEvents.length; i++) {
                totalSpeed += dragEvents[i][3]
            }
            print("total speed", totalSpeed)

            if (zeroVelocityCounts || Math.abs(totalSpeed) > 0.001) {
                dragVelocity = totalSpeed / dragEvents.length * 1000
            }
        }

        function getEventSpeed(currentTime, event) {
            if (dragEvents.length != 0) {
                var lastDrag = dragEvents[dragEvents.length-1]
                var duration = Math.max(1, currentTime - lastDrag[0])
                return (event.y - lastDrag[2]) / duration
            } else {
                return 0
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    MultiPointTouchArea {
        anchors.fill: parent
        mouseEnabled: false
        maximumTouchPoints: 1

        onGestureStarted: {
            if (!d.moving) {
                d.moving = true
                gesture.grab();
                d.dragEvents = []
            }
        }

        onCanceled: {
            d.moving = false
            animation.animate("center");
        }

        onTouchUpdated: {
            if (touchPoints.length == 0 || !d.moving) {
                return;
            }

            var touchPoint = touchPoints[0];
            d.distance = touchPoint.y - touchPoint.startY
            d.pushDragEvent(touchPoint);
            print("pushed event", touchPoint.y, "velocity is now", d.dragVelocity)
        }

        onReleased: {
            print("released", d.moving)
            if (!d.moving) {
                root.clicked()
            }

            if (!root.closeable) {
                animation.animate("center")
                return;
            }

            var touchPoint = touchPoints[0];

            print("released velocity is", d.dragVelocity, "min velocity", root.minSpeedToClose)
            if ((d.dragVelocity < -root.minSpeedToClose && d.distance < -units.gu(8)) || d.distance < -root.height / 2) {
                animation.animate("up")
            } else if ((d.dragVelocity > root.minSpeedToClose  && d.distance > units.gu(8)) || d.distance > root.height / 2) {
                animation.animate("down")
            } else {
                animation.animate("center")
            }
        }
    }

    UbuntuNumberAnimation {
        id: animation
        objectName: "closeAnimation"
        target: d
        property: "distance"
        property bool requestClose: false

        function animate(direction) {
            animation.from = dragArea.distance;
            switch (direction) {
            case "up":
                animation.to = -root.height * 1.5;
                requestClose = true;
                break;
            case "down":
                animation.to = root.height * 1.5;
                requestClose = true;
                break;
            default:
                animation.to = 0
            }
            animation.start();
        }

        onRunningChanged: {
            if (!running) {
                d.moving = false;
                if (requestClose) {
                    root.close();
                } else {
                    d.distance = 0;
                }
            }
        }
    }
}

//DraggingArea {
//    id: root
//    onPressed: mouse.accepted = true;
//    hoverEnabled: true


//    property bool closeable: true

//    property bool moving: false
//    property real distance: 0
//    readonly property int threshold: units.gu(2)
//    property int offset: 0

//    readonly property real minSpeedToClose: units.gu(40)

//    signal close();

//    onMouseYChanged: {
//        if (pressed) {
//            appDelegate.y
//        }
//    }

//    onDragValueChanged: {
//        if (!dragging) {
//            return;
//        }
//        moving = moving || Math.abs(dragValue) > threshold;
//        if (moving) {
//            distance = dragValue + offset;
//        }
//    }

//    onMovingChanged: {
//        if (moving) {
//            offset = (dragValue > 0 ? -threshold: threshold)
//        } else {
//            offset = 0;
//        }
//    }

//    onDragEnd: {
//        if (!root.closeable) {
//            animation.animate("center")
//            return;
//        }

//        // velocity and distance values specified by design prototype
//        if ((dragVelocity < -minSpeedToClose && distance < -units.gu(8)) || distance < -root.height / 2) {
//            animation.animate("up")
//        } else if ((dragVelocity > minSpeedToClose  && distance > units.gu(8)) || distance > root.height / 2) {
//            animation.animate("down")
//        } else {
//            animation.animate("center")
//        }
//    }

//    UbuntuNumberAnimation {
//        id: animation
//        objectName: "closeAnimation"
//        target: dragArea
//        property: "distance"
//        property bool requestClose: false

//        function animate(direction) {
//            animation.from = dragArea.distance;
//            switch (direction) {
//            case "up":
//                animation.to = -root.height * 1.5;
//                requestClose = true;
//                break;
//            case "down":
//                animation.to = root.height * 1.5;
//                requestClose = true;
//                break;
//            default:
//                animation.to = 0
//            }
//            animation.start();
//        }

//        onRunningChanged: {
//            if (!running) {
//                dragArea.moving = false;
//                if (requestClose) {
//                    root.close();
//                } else {
//                    dragArea.distance = 0;
//                }
//            }
//        }
//    }
//}

