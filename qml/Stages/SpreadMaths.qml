import QtQuick 2.2
import Ubuntu.Components 1.1
import Utils 0.1

Item {
    id: root
    anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

    // Information about the transformed item
    property int itemIndex: 0
    property real itemHeight: units.gu(10)

    // Information about the environment
    property int totalItems: 0
    property Item flickable: null
    property int sceneHeight: units.gu(20)

    // Spread properties
    property real spreadHeight: sceneHeight * 0.35
    property int spreadBottomOffset: sceneHeight * 0.2
    property int foldingAreaWidth: flickableWidth * 0.2
    property int maxVisibleItems: 7
    property int margins: flickableWidth * 0.05
    property real stackScale: 0.04
    property int leftEndFoldedAngle: 70
    property int rightEndFoldedAngle: 65
    property int unfoldedAngle: 30
    property int stackWidth: flickableWidth * 0.01


    // Internal
    readonly property int flickableWidth: flickable ? flickable.width : 0
    readonly property int flickableContentWidth: flickable ? flickable.contentWidth: 0
    readonly property real flickableProgress: flickable ? flickable.contentX / (flickable.contentWidth -  flickableWidth) : 0

    readonly property int contentWidth: flickableWidth - root.margins * 2

    // The y offset we need to add because of scaled tiles in the stacks
    readonly property int yOffset: -spreadHeight * stackScale / 2

    readonly property int distance: (flickableContentWidth - (margins * 2) - (foldingAreaWidth * 2)) / totalItems
    readonly property int startPos: margins + foldingAreaWidth + itemIndex * distance
    readonly property int linearX: startPos - flickableProgress * (flickableContentWidth - flickableWidth)

    readonly property int leftFoldingAreaX: margins + foldingAreaWidth
    readonly property int rightFoldingAreaX: flickableWidth - foldingAreaWidth - margins

    readonly property real leftFoldingAreaProgress: linearAnimation(leftFoldingAreaX, margins, 0, 1, linearX)
    readonly property real rightFoldingAreaProgress: linearAnimation(rightFoldingAreaX, flickableWidth - margins, 0, 1, linearX)

    readonly property real limitedLeftProgress: Math.min(2, leftFoldingAreaProgress)
    readonly property real limitedRightProgress: Math.min(2, rightFoldingAreaProgress)

    // Output
    readonly property int animatedX: {
        if (leftFoldingAreaProgress > 4) {
            return margins;
        }
        if (leftFoldingAreaProgress > 2) {
            return linearAnimation(2, 4, margins + stackWidth, margins, leftFoldingAreaProgress)
        }
        if (leftFoldingAreaProgress > 0) {
            return linearAnimation(0, 1, leftFoldingAreaX, margins + stackWidth, leftEasing.value)
        }
        if (rightFoldingAreaProgress > 4) {
            return flickableWidth - margins
        }
        if (rightFoldingAreaProgress > 2) {
            return linearAnimation(2, 4, flickableWidth - margins - stackWidth, flickableWidth - margins, rightFoldingAreaProgress)
        }

        if (rightFoldingAreaProgress > 0) {
            return linearAnimation(0, 1, rightFoldingAreaX, flickableWidth - margins - stackWidth, rightEasing.value);
        }

        return linearX;
    }

    readonly property int animatedY: sceneHeight - itemHeight - spreadBottomOffset +
                                     (limitedLeftProgress > 0 ?
                                         linearAnimation(0, 1, yOffset, 0, leftEasing.value)
                                       : limitedRightProgress > 0 ?
                                             linearAnimation(0, 1, yOffset, 0, rightEasing.value)
                                           : yOffset)



    readonly property int animatedAngle: limitedLeftProgress > 0 ?
                                             linearAnimation(0, 2, unfoldedAngle, leftEndFoldedAngle, Math.min(2, leftFoldingAreaProgress))
                                           : limitedRightProgress > 0 ?
                                                 linearAnimation(0, 2, unfoldedAngle, rightEndFoldedAngle, Math.min(2, rightFoldingAreaProgress))
                                               : unfoldedAngle


    readonly property real scale: (limitedLeftProgress > 0 ?
                                      linearAnimation(0, 1, spreadHeight * (1 - stackScale), spreadHeight, leftEasing.value)
                                    : limitedRightProgress > 0 ?
                                          linearAnimation(0, 1, spreadHeight * (1 - stackScale), spreadHeight, rightEasing.value)
                                        : spreadHeight * (1 - stackScale)
                                   ) / itemHeight


    readonly property real tileInfoOpacity: leftFoldingAreaProgress > 0 ?
                                                      linearAnimation(1, 2, 1, 0, leftFoldingAreaProgress)
                                                    : rightFoldingAreaProgress > 0 ?
                                                          linearAnimation(1 ,2, 1, 0, rightFoldingAreaProgress)
                                                        : 1


    // Helpers
    function linearAnimation(startProgress, endProgress, startValue, endValue, progress) {
        // progress : progressDiff = value : valueDiff => value = progress * valueDiff / progressDiff
        return (progress - startProgress) * (endValue - startValue) / (endProgress - startProgress) + startValue;
    }

    EasingCurve {
        id: leftEasing
        type: EasingCurve.OutSine
        progress: limitedLeftProgress / 2 // OutSine starts with twice the speed. slow it down.
    }

    EasingCurve {
        id: rightEasing
        type: EasingCurve.OutSine
        progress: limitedRightProgress / 2 // OutSine starts with twice the speed. slow it down.
    }
}
