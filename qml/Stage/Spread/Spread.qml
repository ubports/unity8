import QtQuick 2.4
import Ubuntu.Components 1.3
import "MathUtils.js" as MathUtils

Item {
    id: root

    // Information about the environment
    property int highlightedIndex: 1
    property var model: null
    property int leftMargin: 0

    // some config options
    property real contentMargin: 0.16 * root.height
    property real contentTopMargin: contentMargin
    property real contentBottomMargin: 0.35 * contentMargin
    property real windowTitleTopMargin: 3/4 * (contentTopMargin - windowTitle.height)
    property int stackItemCount: 3
    property real leftRotationAngle: 22
    property real rightRotationAngle: 32
    property real leftStackScale: .82
    property real rightStackScale: 1

    signal leaveSpread()

    // Calculated stuff
    readonly property int totalItemCount: model.count
    readonly property real leftStackXPos: 0.03 * root.width + leftMargin
    readonly property real rightStackXPos: root.width - 1.5 * leftStackXPos + leftMargin

    readonly property real stackHeight: spreadItemHeight - appInfoHeight
    readonly property real stackWidth: Math.min(leftStackXPos/3, units.gu(1.5))

    readonly property real spreadWidth: rightStackXPos - leftStackXPos
    readonly property real spreadHeight: root.height
    readonly property real spreadItemHeight: spreadHeight - contentTopMargin - contentBottomMargin
    readonly property real spreadItemWidth: stackHeight

    readonly property real dynamicLeftRotationAngle: leftRotationAngle * rotationAngleFactor
    readonly property real dynamicRightRotationAngle: rightRotationAngle * rotationAngleFactor

    readonly property real appInfoHeight: {
        var screenHeightReferencePoint = 40 // ref screen height in gu
        var valueAtReferencePoint = 0.17 // of screen height at the reference point
        var appInfoHeightValueChange = -0.0014 // units / gu
        var minAppInfoHeight = 0.08
        var maxAppInfoHeight = 0.2
        var screenHeightInGU = root.height / units.gu(1) // screenHeight in gu

        return MathUtils.clamp(valueAtReferencePoint + appInfoHeightValueChange * (screenHeightInGU - screenHeightReferencePoint), minAppInfoHeight, maxAppInfoHeight) * root.height
    }

    property real rotationAngleFactor: {
        var spreadHeightReferencePoint = 28 // reference spread height in gu
        var valueAtReferencePoint = 1.3
        var rotationAngleValueChange = -0.008 // units / gu
        var minRotationAngleFactor = 0.6
        var maxRotationAngleFactor = 1.5
        var spreadHeightInGU = spreadHeight / units.gu(1)

        return MathUtils.clamp(valueAtReferencePoint + rotationAngleValueChange * (spreadHeightInGU - spreadHeightReferencePoint), minRotationAngleFactor, maxRotationAngleFactor)
    }
    readonly property real itemOverlap: {
        var spreadAspectRatioReferencePoint = 1.0 // ref screen height in gu
        var valueAtReferencePoint = 0.74 // of screen height at the reference point
        var itemOverlapValueChange = -0.068
        var minOverlap = 0.55
        var maxOverlap = 0.82
        var spreadAspectRatio = spreadWidth / stackHeight // spread stack aspect ratio (app info not included)

        return MathUtils.clamp(valueAtReferencePoint + itemOverlapValueChange * (spreadAspectRatio - spreadAspectRatioReferencePoint), minOverlap, maxOverlap)
    }

    readonly property real visibleItemCount: (spreadWidth / spreadItemWidth) / (1 - itemOverlap)

    readonly property real spreadTotalWidth: totalItemCount * spreadWidth / visibleItemCount

    readonly property real centeringOffset: Math.max(spreadWidth - spreadTotalWidth ,0) / (2 * spreadWidth)


    readonly property var curve: BezierCurve {
        controlPoint2: {'x': 0.19, 'y': 0.00}
        controlPoint3: {'x': 0.91, 'y': 1.00}
    }

    Label {
        id: windowTitle

        width: Math.min(implicitWidth, 0.5*root.width)
        elide: Qt.ElideMiddle
        anchors.horizontalCenter: parent.horizontalCenter
        y: windowTitleTopMargin
//        //y: priv.spreadTopMargin + priv.contentTopMargin + settings.spreadOffset + settings.titleOffset - height -  (priv.contentTopMargin - height) / 4
//        visible: height < priv.contentTopMargin
        property var highlightedSurface: root.model ? root.model.surfaceAt(root.highlightedIndex) : null
        text: root.highlightedIndex >= 0 && highlightedSurface ? highlightedSurface.name : ""
        fontSize: root.height < units.gu(85) ? 'medium' : 'large'
        color: "white"
        opacity: root.highlightedIndex >= 0 ? 1 : 0
        Behavior on opacity { UbuntuNumberAnimation { } }
    }

//    Label {
//        anchors { left: parent.left; top: parent.top; margins: units.gu(4) }
//        text: "spreadWidth: " + spreadWidth
//              + "\n spreadItemWidth: " + spreadItemWidth
//              + "\n flickableContentWidth: " + spreadTotalWidth
//              + "\n visibleItemCount: " + visibleItemCount
//              + "\n contentTopMargin: " + contentTopMargin
//    }


    Keys.onPressed: {
        print("key pressed")
        switch (event.key) {
        case Qt.Key_Left:
        case Qt.Key_Backtab:
            selectPrevious(event.isAutoRepeat)
            event.accepted = true;
            break;
        case Qt.Key_Right:
        case Qt.Key_Tab:
            selectNext(event.isAutoRepeat)
            event.accepted = true;
            break;
        case Qt.Key_Escape:
            highlightedIndex = -1
            // Falling through intentionally
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Space:
            root.leaveSpread();
            event.accepted = true;
        }
    }


    function selectNext(isAutoRepeat) {
        if (isAutoRepeat && highlightedIndex >= totalItemCount -1) {
            return; // AutoRepeat is not allowed to wrap around
        }

        highlightedIndex = (highlightedIndex + 1) % totalItemCount;
        var newContentX = ((spreadTotalWidth) / (totalItemCount + 1)) * Math.max(0, Math.min(totalItemCount - 5, highlightedIndex - 3));
//        if (spreadFlickable.contentX < newContentX || spreadRepeater.highlightedIndex == 0) {
//            spreadFlickable.snapTo(newContentX)
//        }
    }

    function selectPrevious(isAutoRepeat) {
        if (isAutoRepeat && highlightedIndex == 0) {
            return; // AutoRepeat is not allowed to wrap around
        }

        var newIndex = highlightedIndex - 1 >= 0 ? highlightedIndex - 1 : totalItemCount - 1;
        highlightedIndex = newIndex;
//        var newContentX = ((spreadFlickable.contentWidth) / (topLevelSurfaceList.count + 1)) * Math.max(0, Math.min(topLevelSurfaceList.count - 5, spreadRepeater.highlightedIndex - 1));
//        if (spreadFlickable.contentX > newContentX || newIndex == topLevelSurfaceList.count -1) {
//            spreadFlickable.snapTo(newContentX)
//        }
    }

}
