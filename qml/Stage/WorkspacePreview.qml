import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1

UbuntuShape {
    id: previewSpace

    // Set the height. this preview will then automatically adjust the width, keeping aspect ratio of the screen
    width: model.geometry.width * previewScale
    color: "white"

    property int screenWidth: model.geometry.width
    property int screenHeight: model.geometry.height
    property real previewScale: previewSpace.height / previewSpace.screenHeight

    Label {
        text: model.name + "," + model.geometry.width
        color: "black"
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: units.gu(4)

        Repeater {
            id: topLevelSurfaceRepeater
            model: topLevelSurfaceList
            delegate: Rectangle {
                width: surfaceItem.width
                height: surfaceItem.height
                x: model.window.position.x * previewSpace.previewScale
                y: model.window.position.y * previewSpace.previewScale
                color: "blue"
                z: topLevelSurfaceRepeater.count - index


                MirSurfaceItem {
                    id: surfaceItem

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
