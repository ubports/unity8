import QtQuick 2.4
import Lomiri.Components 1.3
import Unity.Application 0.1
import WindowManager 1.0
import ".."
import "../../Components"

Item {
    id: previewSpace
    clip: true

    property var workspace

    property string background
    property int screenHeight

    property real previewScale: previewSpace.height / previewSpace.screenHeight

    property bool containsDragLeft: false
    property bool containsDragRight: false
    property bool isActive: false
    property bool isSelected: false

    Image {
        source: previewSpace.background
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: height

        Repeater {
            id: topLevelSurfaceRepeater
            model: visible ? workspace.windowModel : null
            delegate: Item {
                width: surfaceItem.width
                height: surfaceItem.height + decorationHeight * previewScale
                x: model.window.position.x * previewScale
                y: (model.window.position.y - decorationHeight) * previewScale
                z: topLevelSurfaceRepeater.count - index
                visible: model.window.state !== Mir.MinimizedState && model.window.state !== Mir.HiddenState

                property int decorationHeight: units.gu(3)

                WindowDecoration {
                    width: surfaceItem.implicitWidth
                    height: parent.decorationHeight
                    transform: Scale {
                        origin.x: 0
                        origin.y: 0
                        xScale: previewScale
                        yScale: previewScale
                    }
                    title: model.window && model.window.surface ? model.window.surface.name : ""
                    z: 3
                }

                MirSurfaceItem {
                    id: surfaceItem
                    y: parent.decorationHeight * previewScale
                    width: implicitWidth * previewScale
                    height: implicitHeight * previewScale
                    surfaceWidth: -1
                    surfaceHeight: -1
                    surface: model.window.surface
                }
            }
        }

    }

    Rectangle {
        anchors.fill: parent
        border.color: LomiriColors.ash
        border.width: units.gu(.5)
        color: "transparent"
        visible: previewSpace.isActive
    }

    Rectangle {
        anchors.fill: parent
        border.color: LomiriColors.blue
        border.width: units.gu(.5)
        color: "transparent"
        visible: previewSpace.isSelected
    }

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: parent.width / 2
        color: "#55000000"
        visible: previewSpace.containsDragLeft

        Column {
            anchors.centerIn: parent
            spacing: units.gu(1)
            Icon {
                source: "../graphics/multi-monitor_drop-here.png"
                height: units.gu(4)
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                text: qsTr("Drop here")
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: parent.width / 2
        color: "#55000000"
        visible: previewSpace.containsDragRight

        Column {
            anchors.centerIn: parent
            spacing: units.gu(1)
            Icon {
                source: "../graphics/multi-monitor_leave.png"
                height: units.gu(4)
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                text: qsTr("Drop and go")
            }
        }
    }
}
