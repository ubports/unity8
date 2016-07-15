import QtQuick 2.4
import Ubuntu.Components 1.3
import "MathUtils.js" as MathUtils

QtObject {
    id: root

    // Input
    property int itemIndex: 0
    property real progress: 0
    property int sceneWidth: 0
    property int sceneHeight: 0
    property int targetX: 0
    property int startY: 0
    property int targetY: 0
    property real startAngle: 40
    property real targetAngle: 0
    property int targetHeight: 0
    property real startScale: 1.3
    property real targetScale: 0


    onProgressChanged: if (itemIndex == 0) { print("progress", progress) }

    // Config
    property real breakPoint: 0.4
    property int tileDistance: units.gu(10)

    // Output

    readonly property real scaleToPreviewProgress: {
        print("scaleProg:", progress < breakPoint ? 0 : MathUtils.linearAnimation(breakPoint, 1.0, 0.0, 1.0, progress))
        return progress < breakPoint ? 0 : MathUtils.linearAnimation(0.5, 1.0, 0.0, 1.0, progress)
    }
    readonly property int animatedWidth: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneWidth, targetHeight, progress)
    }

    readonly property int animatedHeight: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneHeight, targetHeight, progress)
    }

    readonly property int animatedX: {
        if (itemIndex == 0) {
            return root.targetX * root.progress
        }
        var startX = sceneWidth //+ (itemIndex - 1) * tileDistance
        if (itemIndex == 1) {
            if (root.progress < breakPoint) {
                return MathUtils.linearAnimation(0, breakPoint, startX, startX / 2 + (itemIndex - 1) * tileDistance, progress)
            }
            return MathUtils.linearAnimation(breakPoint, 1, startX / 2 + (itemIndex - 1) * tileDistance, targetX, progress)
        }
        if (progress < breakPoint) {
            return startX
        }
        return MathUtils.linearAnimation(breakPoint, 1, startX, targetX, progress)
    }

    readonly property int animatedY: progress < breakPoint ? startY : MathUtils.linearAnimation(breakPoint, 1, startY, targetY, progress)

    readonly property real animatedAngle: itemIndex == 0 ? MathUtils.linearAnimation(0, 1, 0, targetAngle, progress)
                                        : Math.max(MathUtils.linearAnimation(0, breakPoint, startAngle, targetAngle, progress), targetAngle)

    readonly property real animatedScale: itemIndex == 0 ? MathUtils.linearAnimation(0, 1, 1, targetScale, progress)
                                                         : MathUtils.linearAnimation(0, 1, startScale, targetScale, progress)
}
