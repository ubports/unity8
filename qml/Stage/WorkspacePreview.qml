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
            model: visible ? topLevelSurfaceList : null
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

    MouseArea {
        id: mouseArea
        anchors.centerIn: parent
        anchors.verticalCenterOffset: header.height / 2
        width: units.gu(10)
        height: width
        hoverEnabled: true
        opacity: containsMouse ? 1 : 0

        Rectangle {
            anchors.fill: parent
            color: "#55000000"
            radius: height / 2
        }

        NumberAnimation {
            target: canvas
            property: "progress"
            duration: 2000
            running: mouseArea.containsMouse
            from: 0
            to: 1
        }

        Canvas {
            id: canvas
            height: parent.height
            width: height
            anchors.centerIn: parent

            property real progress: 0.5
            property int lineWidth: units.dp(4)
            onProgressChanged: {
                requestPaint();
            }

            rotation: -90

            onPaint: {
                var ctx = canvas.getContext("2d");
                ctx.save();
                ctx.reset();

                ctx.lineWidth = lineWidth;

                ctx.strokeStyle = "#55ffffff"
                ctx.beginPath();
                ctx.arc(canvas.width/2,canvas.height/2, (canvas.height - ctx.lineWidth) / 2, 0, (Math.PI*2),false);
                ctx.stroke();
                ctx.closePath();

                ctx.strokeStyle = "white"
                ctx.beginPath();
                ctx.arc(canvas.width/2,canvas.height/2, (canvas.height - ctx.lineWidth) / 2, 0, (Math.PI*2*(progress)),false);
                ctx.stroke();
                ctx.closePath();

                ctx.restore();
            }
        }
    }
}
