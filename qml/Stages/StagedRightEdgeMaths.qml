import QtQuick 2.4
import Ubuntu.Components 1.3

QtObject {
    id: root

    // Input
    property int itemIndex: 0
    property real progress: 0
    property int sceneWidth: 0
    property int sceneHeight: 0
    property int targetX: 0
    property int targetAngle: 0

    // Output
    readonly property int animtedWidth: {
        return root.sceneWidth
    }

    readonly property int animatedHeight: {
        return root.sceneHeight
    }

    readonly property int animatedX: {
        if (itemIndex == 0) {
            // aX : tX = p : 1
            return root.targetX * root.progress
        }
        var startX = sceneWidth + (root.itemIndex - 1) * units.gu(10)
        var distance = startX - root.targetX
        return startX - distance * root.progress;
    }

    readonly property real animatedAngle: {
        // a : tA = p : 1
        return root.targetAngle * root.progress
    }
}
