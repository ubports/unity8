import QtQuick 2.4
import Ubuntu.Components 1.3
import "../../Components"

DraggingArea {
    id: root
    onPressed: mouse.accepted = true;
    hoverEnabled: true

    property bool closeable: true

    property bool moving: false
    property real distance: 0
    readonly property int threshold: units.gu(2)
    property int offset: 0

    readonly property real minSpeedToClose: units.gu(40)

    signal close();

    onMouseYChanged: {
        if (pressed) {
            appDelegate.y
        }
    }

    onDragValueChanged: {
        if (!dragging) {
            return;
        }
        moving = moving || Math.abs(dragValue) > threshold;
        if (moving) {
            distance = dragValue + offset;
        }
    }

    onMovingChanged: {
        if (moving) {
            offset = (dragValue > 0 ? -threshold: threshold)
        } else {
            offset = 0;
        }
    }

    onDragEnd: {
        if (!root.closeable) {
            animation.animate("center")
            return;
        }

        // velocity and distance values specified by design prototype
        if ((dragVelocity < -minSpeedToClose && distance < -units.gu(8)) || distance < -root.height / 2) {
            animation.animate("up")
        } else if ((dragVelocity > minSpeedToClose  && distance > units.gu(8)) || distance > root.height / 2) {
            animation.animate("down")
        } else {
            animation.animate("center")
        }
    }

    UbuntuNumberAnimation {
        id: animation
        objectName: "closeAnimation"
        target: dragArea
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
                dragArea.moving = false;
                if (requestClose) {
                    root.close();
                } else {
                    dragArea.distance = 0;
                }
            }
        }
    }
}

