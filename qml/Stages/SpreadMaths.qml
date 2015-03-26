import QtQuick 2.2
import Ubuntu.Components 1.1
import Utils 0.1
import Unity.Application 0.1

Item {

    Label {
        anchors {left: parent.left; top: parent.top }
        text: "prog:" + transitionCurve.progress.toFixed(2)
        color: isInLeftFoldingArea ? "red" : "black"
    }

    id: root
    anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

    property int itemIndex: 0
    property int totalItems: 0
    property Item flickable: null
    property int margins: units.gu(5)
    property int foldingAreaWidth: units.gu(5)

    property int maxVisibleItems: 5

    readonly property int flickableWidth: flickable ? flickable.width : 0
    readonly property int flickableContentWidth: flickable ? flickable.contentWidth: 0
    readonly property real flickableProgress: flickable ? flickable.contentX / (flickable.contentWidth -  flickableWidth) : 0

    readonly property int contentWidth: flickableWidth - root.margins * 2

    readonly property int unfoldedDistance: (contentWidth - foldingAreaWidth) / maxVisibleItems

    // Internal
    readonly property real progressSlice: 1 / totalItems;
    readonly property real startProgress: Math.max(0, index - 2) * progressSlice
    readonly property real endProgress: (index + 3) * progressSlice

    readonly property real startX: index < maxVisibleItems ?
                                       margins + index * unfoldedDistance
                                     : contentWidth - foldingAreaWidth + (startLayout.value * foldingAreaWidth)

    readonly property real endX: totalItems - maxVisibleItems < index ?
                                     contentWidth - (totalItems - index) * unfoldedDistance
                                   : margins + foldingAreaWidth - (endLayout.value * foldingAreaWidth)

    readonly property int animatedX: transitionCurve.value * (endX - startX) + startX

    function desktopY(sceneHeight, itemHeight) {
        return sceneHeight - itemHeight - (sceneHeight * 0.2);
    }

    property int leftEndFoldedAngle: 80
    property int rightEndFoldedAngle: 60
    property int unfoldedAngle: 30

    property bool isInLeftFoldingArea: animatedX < foldingAreaWidth +  margins

    // x : foldingAreaWidth = leftEndFoldedAngle: unfoldedAngle:

    readonly property int animatedAngle: isInLeftFoldingArea ?
                                             ((foldingAreaWidth + margins) - x) * unfoldedAngle / leftEndFoldedAngle
                                           : unfoldedAngle


    function desktopScale(sceneHeight, itemHeight) {
        var maxHeight = sceneHeight * 0.35;
        if (itemHeight > maxHeight) {
            return maxHeight / itemHeight
        }
        return 1;
    }

    function desktopTitleInfoShown(index, flickableX) {
        return true;
    }

    EasingCurve {
        id: transitionCurve
        type: easingCurve.InOutSine

        readonly property real normalizedEndProgress: endProgress - startProgress
        readonly property real normalizedProgress: (root.flickableProgress - root.startProgress) / normalizedEndProgress
        progress: normalizedProgress
    }

    EasingCurve {
        id: startLayout
        type: EasingCurve.OutSine
        // total : 1 = index : p
        progress: 1.0 * index / root.totalItems
    }

    EasingCurve {
        id: endLayout
        type: EasingCurve.OutSine
        // total : 1 = index : p
        progress: 1 - (1.0 * index / root.totalItems)
    }
}
