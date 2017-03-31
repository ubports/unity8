import QtQuick 2.4
import Ubuntu.Components 1.3
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
                    onImplicitHeightChanged: print("item", surfaceItem, "height changed", implicitHeight)
                    surface: model.window.surface
                }
            }
        }

    }

    Rectangle {
        anchors.fill: parent
        border.color: UbuntuColors.ash
        border.width: units.gu(.5)
        color: "transparent"
        visible: previewSpace.isActive
    }

    Rectangle {
        anchors.fill: parent
        border.color: UbuntuColors.blue
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

    //                Repeater {
    //                    id: topLevelSurfaceRepeater
    //                    model: visible ? topLevelSurfaceList : null
    //                    delegate: Rectangle {
    //                        width: surfaceItem.width
    //                        height: surfaceItem.height + decorationHeight * previewScale
    //                        x: model.window.position.x * previewScale
    //                        y: (model.window.position.y - decorationHeight) * previewScale
    //                        color: "blue"
    //                        z: topLevelSurfaceRepeater.count - index

    //                        property int decorationHeight: units.gu(3)

    //                        WindowDecoration {
    //                            width: surfaceItem.implicitWidth
    //                            height: parent.decorationHeight
    //                            transform: Scale {
    //                                origin.x: 0
    //                                origin.y: 0
    //                                xScale: previewScale
    //                                yScale: previewScale
    //                            }
    //                            title: model.window && model.window.surface ? model.window.surface.name : ""
    //                            z: 3
    //                        }

    //                        MirSurfaceItem {
    //                            id: surfaceItem
    //                            y: parent.decorationHeight * previewScale
    //                            width: implicitWidth * previewScale
    //                            height: implicitHeight * previewScale
    //                            surfaceWidth: -1
    //                            surfaceHeight: -1
    //                            onImplicitHeightChanged: print("item", surfaceItem, "height changed", implicitHeight)
    //                            surface: model.window.surface
    //                        }
    //                    }
    //                }
//                }
//            }


//            MouseArea {
//                id: mouseArea
//                anchors.centerIn: parent
//                anchors.verticalCenterOffset: header.height / 2
//                width: units.gu(8)
//                height: width
//                hoverEnabled: true
//                opacity: containsMouse ? 1 : 0

//                Rectangle {
//                    anchors.fill: parent
//                    color: "#80000000"
//                    radius: height / 2
//                }

//                NumberAnimation {
//                    target: canvas
//                    property: "progress"
//                    duration: 2000
//                    running: mouseArea.containsMouse
//                    from: 0
//                    to: 1
//                }

//                Canvas {
//                    id: canvas
//                    height: parent.height
//                    width: height
//                    anchors.centerIn: parent

//                    property real progress: 0.5
//                    property int lineWidth: units.dp(4)
//                    onProgressChanged: {
//                        requestPaint();
//                        if (progress == 1) {
//                            Screens.activateScreen(index);
//                        }
//                    }

//                    rotation: -90

//                    onPaint: {
//                        var ctx = canvas.getContext("2d");
//                        ctx.save();
//                        ctx.reset();

//                        ctx.lineWidth = lineWidth;

//                        ctx.strokeStyle = "#3bffffff"
//                        ctx.beginPath();
//                        ctx.arc(canvas.width/2,canvas.height/2, (canvas.height - ctx.lineWidth) / 2, 0, (Math.PI*2),false);
//                        ctx.stroke();
//                        ctx.closePath();

//                        ctx.strokeStyle = "white"
//                        ctx.beginPath();
//                        ctx.arc(canvas.width/2,canvas.height/2, (canvas.height - ctx.lineWidth) / 2, 0, (Math.PI*2*(progress)),false);
//                        ctx.stroke();
//                        ctx.closePath();

//                        ctx.restore();
//                    }
//                }

//                Icon {
//                    source: "graphics/multi-monitor_leave.png"
//                    height: units.gu(4)
//                    width: height
//                    anchors.centerIn: parent
//                }
//            }
//        }

//        FloatingFlickable {
//            id: flickable
//            anchors.fill: parent
//            contentWidth: workspaceRepeater.count * previewSpace.screenWidth * previewScale
//            property real progress: contentX / contentWidth
//            onContentXChanged: print("contentX:", contentX, "progress:", progress)
//        }

//        MouseArea {
//            anchors.fill: parent
//            hoverEnabled: true
//            property int scrollAreaWidth: width / 3

//            onMouseXChanged: {
//                var margins = flickable.width * 0.05;

//                // do we need to scroll?
//                if (mouseX < scrollAreaWidth + margins) {
//                    var progress = Math.min(1, (scrollAreaWidth + margins - mouseX) / (scrollAreaWidth - margins));
//                    var contentX = (1 - progress) * (flickable.contentWidth - flickable.width)
//                    flickable.contentX = Math.max(0, Math.min(flickable.contentX, contentX))
//                }
//                if (mouseX > flickable.width - scrollAreaWidth) {
//                    var progress = Math.min(1, (mouseX - (flickable.width - scrollAreaWidth)) / (scrollAreaWidth - margins))
//                    var contentX = progress * (flickable.contentWidth - flickable.width)
//                    flickable.contentX = Math.min(flickable.contentWidth - flickable.width, Math.max(flickable.contentX, contentX))
//                }
//            }
//        }
//    }
//}
