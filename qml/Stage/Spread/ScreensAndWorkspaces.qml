import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Screens 0.1
import Unity.Application 0.1
import ".."

Item {
    id: root


    Rectangle { anchors.fill: parent; color: "blue"; opacity: .3 }

    Row {
        anchors.centerIn: parent
        spacing: units.gu(1)

        Repeater {
            model: Screens

            delegate: Rectangle {
                id: previewSpace
                height: root.height * .5
                width: height * 1.4
                color: "red"

                property int screenWidth: model.geometry.width
                property int screenHeight: model.geometry.height

                Label {
                    text: model.name + "," + model.geometry.width
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
                            x: model.window.position.x * surfaceItem.previewScale
                            y: model.window.position.y * surfaceItem.previewScale
                            color: "blue"
                            z: topLevelSurfaceRepeater.count - index


                            MirSurfaceItem {
                                id: surfaceItem

                                property real previewScale: previewSpace.width / previewSpace.screenWidth

                                width: implicitWidth * previewScale
                                height: implicitHeight * previewScale
//                                fillMode: MirSurfaceItem.Stretch
                                surfaceWidth: -1
                                surfaceHeight: -1
                                onImplicitHeightChanged: print("item", surfaceItem, "height changed", implicitHeight)
    //                            surfaceWidth: 100
    //                            surfaceHeight: 100
    //                            requestedHeight: 100// -1// !counterRotate ? root.requestedHeight - d.requestedDecorationHeight : root.requestedWidth
    //                            requestedWidth: 100// -1// !counterRotate ? root.requestedWidth : root.requestedHeight - d.requestedDecorationHeight

    //                            application: model.application
                                surface: model.window.surface
                            }
                        }
                    }
                }

            }
        }
    }
}
