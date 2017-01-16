import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Screens 0.1
import Unity.Application 0.1
import "../Components"

UbuntuShape {
    id: previewSpace

    // Set the height. this preview will then automatically adjust the width, keeping aspect ratio of the screen
    width: model.geometry.width * previewScale
    color: "white"
    property string background

    property int screenWidth: model.geometry.width
    property int screenHeight: model.geometry.height
    property real previewScale: (previewSpace.height - header.height) / previewSpace.screenHeight

    Item {
        id: header
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(7)
        Column {
            anchors.fill: parent
            anchors.margins: units.gu(1)

            Label {
                text: model.name
                color: "black"
            }

            Label {
                text: model.outputType === Screens.LVDS ? "Built-in" : "Clone"
                color: "black"
                fontSize: "x-small"
            }

            Label {
                text: model.geometry.width + "x" + model.geometry.height
                color: "black"
                fontSize: "x-small"
            }
        }
    }


    Wallpaper {
        anchors.fill: parent
        anchors.topMargin: header.height
        source: previewSpace.background
        clip: true

        Repeater {
            id: topLevelSurfaceRepeater
            model: topLevelSurfaceList
            delegate: Rectangle {
                width: surfaceItem.width
                height: surfaceItem.height + decorationHeight * previewScale
                x: model.window.position.x * previewScale
                y: (model.window.position.y - decorationHeight) * previewScale
                color: "blue"
                z: topLevelSurfaceRepeater.count - index

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
                    onImplicitHeightChanged: print("item", surfaceItem, "height changed", implicitHeight)
                    surface: model.window.surface
                }
            }
        }
    }
}
