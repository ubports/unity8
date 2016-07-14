import QtQuick 2.4
import Ubuntu.Components 1.3
import "MathUtils.js" as MathUtils

Item {
    id: root

    // Information about the environment
    property int totalItemCount: 0

    // some config options
    property real contentMargin: 0.16 * root.height
    property real contentTopMargin: 0.65 * contentMargin
    property real contentBottomMargin: 0.35 * contentMargin
    property real windowTitleTopMargin: 3/4 * (contentTopMargin - windowTitle.height)
    property int stackItemCount: 3
    property real leftRotationAngle: 22
    property real rightRotationAngle: 32
    property real leftStackScale: .82
    property real rightStackScale: 1


    // Calculated stuff
    readonly property real leftStackXPos: 0.03 * root.width
    readonly property real rightStackXPos: root.width - 1.5 * leftStackXPos

    readonly property real stackHeight: spreadItemHeight - appInfoHeight
    readonly property real stackWidth: Math.min(leftStackXPos/3, units.gu(1.5))

    readonly property real spreadWidth: rightStackXPos - leftStackXPos
    readonly property real spreadHeight: root.height
    readonly property real spreadItemHeight: 0.84 * spreadHeight
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
        text: "focused window title"
        fontSize: root.height < units.gu(85) ? 'medium' : 'large'
        color: "white"
    }

//    Label {
//        anchors { left: parent.left; top: parent.top; margins: units.gu(4) }
//        text: "spreadWidth: " + spreadWidth
//              + "\n spreadItemWidth: " + spreadItemWidth
//              + "\n flickableContentWidth: " + spreadTotalWidth
//              + "\n visibleItemCount: " + visibleItemCount
//              + "\n contentTopMargin: " + contentTopMargin
//    }

}
