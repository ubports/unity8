import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "MathUtils.js" as MathUtils

QtObject {
    id: root

    // Input
    property int itemIndex: 0
    property real progress: 0
    property int sceneWidth: 0
    property int sideStageWidth: 0
    property int sceneHeight: 0
    property int targetX: 0
    property int startY: 0
    property int targetY: 0
    property real startAngle: 40
    property real targetAngle: 0
    property int targetHeight: 0
    property real startScale: 1.3
    property real targetScale: 0

    property bool isMainStageApp: false
    property bool isSideStageApp: false
    property int nextInStack: 0


//    onProgressChanged: if (itemIndex == 0) { print("progress", progress) }

    // Config
    property real breakPoint: 0.4
    property int tileDistance: units.gu(10)

    // Output

    readonly property real scaleToPreviewProgress: {
//        print("scaleProg:", progress < breakPoint ? 0 : MathUtils.linearAnimation(breakPoint, 1.0, 0.0, 1.0, progress))
        return progress < breakPoint ? 0 : MathUtils.linearAnimation(0.5, 1.0, 0.0, 1.0, progress)
    }
    readonly property int animatedWidth: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneWidth, targetHeight, progress)
    }

    readonly property int animatedHeight: {
        return progress < breakPoint ? root.sceneHeight : MathUtils.linearAnimation(breakPoint, 1, root.sceneHeight, targetHeight, progress)
    }

    readonly property int animatedX: {
        var stageCount = (priv.mainStageDelegate ? 1 : 0) + (priv.sideStageDelegate ? 1 : 0)

        if (appRepeater.count <= nextInStack) return 0;

        var nextStage = appRepeater.itemAt(nextInStack).stage;

        var startX = 0;
        if (isMainStageApp) {
            startX = 0;
        } else if (isSideStageApp) {
            startX = sceneWidth - sideStageWidth;
        } else if (itemIndex == nextInStack && itemIndex < 2 && priv.sideStageDelegate && nextStage == ApplicationInfoInterface.MainStage) {
            startX = sceneWidth - sideStageWidth;
        } else {
            startX = sceneWidth + Math.max(0, itemIndex - stageCount - 1) * tileDistance;
        }

        if (itemIndex == nextInStack) {
            if (progress < breakPoint) {
                return MathUtils.linearAnimation(0, breakPoint, startX, sceneWidth / 2, progress)
            }
            return MathUtils.linearAnimation(breakPoint, 1, sceneWidth / 2, targetX, progress)
        }

        if (progress < breakPoint) {
            return startX;
        }

        return MathUtils.linearAnimation(breakPoint, 1, startX, targetX, progress)

    }

    readonly property int animatedY: progress < breakPoint ? startY : MathUtils.linearAnimation(breakPoint, 1, startY, targetY, progress)

    readonly property real animatedAngle: {
        var startAngle = 0;
        if (isMainStageApp) {
            startAngle = 0;
        } else if (isSideStageApp) {
            startAngle = 0;
        } else {
            startAngle = root.startAngle;
        }

        return MathUtils.linearAnimation(0, 1, startAngle, targetAngle, progress);
    }

    readonly property real animatedScale: {
        var startScale = 1;
        if (isMainStageApp) {
            startScale = 1;
        } else if (isSideStageApp) {
            startScale = 1;
        } else {
            startScale = root.startScale;
        }

//        print("main stage delegate:", priv.mainStageDelegate, "side delegate", priv.sideStageDelegate, "this", appDelegate, "scale:", startScale)
//        return startScale;
        if (itemIndex == nextInStack) {
            return MathUtils.linearAnimation(0, 1, startScale, targetScale, progress)
        }
        if (progress < breakPoint) {
            return startScale;
        }

        return MathUtils.linearAnimation(breakPoint, 1, startScale, targetScale, progress)
    }

    readonly property bool itemVisible: true //animatedX < sceneWidth
}
