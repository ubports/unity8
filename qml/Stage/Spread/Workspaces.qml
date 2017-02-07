import QtQuick 2.4
import Ubuntu.Components 1.3
import "MathUtils.js" as MathUtils

Rectangle {
    id: root
    implicitWidth: listView.count * (height * 16/9)
    color: "blue"

    property var screen: null
    property var background // TODO: should be stored in the workspace data

//    Rectangle { anchors.fill: parent; color: "green" }
    ListView {
        id: listView
        anchors.fill: parent
        anchors.leftMargin: -itemWidth
        anchors.rightMargin: -itemWidth
        interactive: false

        model: ListModel {
            ListElement {text: "1"}
            ListElement {text: "2"}
            ListElement {text: "3"}
            ListElement {text: "4"}
            ListElement {text: "5"}
            ListElement {text: "6"}
            ListElement {text: "7"}
            ListElement {text: "8"}
            ListElement {text: "9"}
        }


        orientation: ListView.Horizontal
        spacing: units.gu(1)
        leftMargin: itemWidth
        rightMargin: itemWidth

        property int itemWidth: height * 16 / 9
        property int foldingAreaWidth: units.gu(10)
        property real realContentX: contentX - originX + leftMargin

        displaced: Transition { UbuntuNumberAnimation { properties: "x" } }

        delegate: Item {
            objectName: "delegate" + index
            height: parent.height
            width: /*dndArea.draggedIndex == index ? units.gu(5) :*/ listView.itemWidth
            Behavior on width { UbuntuNumberAnimation {} }

            property int itemX: -listView.realContentX + index * (listView.itemWidth + listView.spacing)
            property int distanceFromLeft: itemX //- listView.leftMargin
            property int distanceFromRight: listView.width - listView.leftMargin - listView.rightMargin - itemX - listView.itemWidth

            property int maxAngle: 40

            property int itemAngle: {
                if (index == 0) {
                    if (distanceFromLeft < 0) {
                        var progress = (distanceFromLeft + listView.foldingAreaWidth) / listView.foldingAreaWidth
                        return MathUtils.linearAnimation(1, -1, 0, maxAngle, Math.max(-1, Math.min(1, progress)));
                    }
                    return 0
                }
                if (index == listView.count - 1) {
                    if (distanceFromRight < 0) {
                        var progress = (distanceFromRight + listView.foldingAreaWidth) / listView.foldingAreaWidth
                        return MathUtils.linearAnimation(1, -1, 0, -maxAngle, Math.max(-1, Math.min(1, progress)));
                    }
                    return 0
                }

                if (distanceFromLeft < listView.foldingAreaWidth) {
                    // itemX : 10gu = p : 100
                    var progress = distanceFromLeft / listView.foldingAreaWidth
                    return MathUtils.linearAnimation(1, -1, 0, maxAngle, Math.max(-1, Math.min(1, progress)));
                }
                if (distanceFromRight < listView.foldingAreaWidth) {
                    var progress = distanceFromRight / listView.foldingAreaWidth
                    return MathUtils.linearAnimation(1, -1, 0, -maxAngle, Math.max(-1, Math.min(1, progress)));
                }
                return 0
            }

            property int itemOffset: {
                if (index == 0) {
                    if (distanceFromLeft < 0) {
                        return -distanceFromLeft
                    }
                    return 0
                }
                if (index == listView.count - 1) {
                    if (distanceFromRight < 0) {
                        return distanceFromRight
                    }
                    return 0
                }

                if (itemX < -listView.foldingAreaWidth) {
                    return -itemX
                }
                if (distanceFromLeft < listView.foldingAreaWidth) {
                    var progress = distanceFromLeft / listView.foldingAreaWidth
                    return (listView.foldingAreaWidth - distanceFromLeft) / 2
                }

                if (distanceFromRight < -listView.foldingAreaWidth) {
                    return distanceFromRight
                }

                if (distanceFromRight < listView.foldingAreaWidth) {
                    var progress = distanceFromRight / listView.foldingAreaWidth;
                    return -(listView.foldingAreaWidth - distanceFromRight) / 2
                }

                return 0
            }

//            onItemXChanged: if (index == 1) print("x", itemX, listView.contentX)

            z: itemOffset < 0 ? itemOffset : -itemOffset
            transform: [
                Rotation {
                    angle: itemAngle
                    axis { x: 0; y: 1; z: 0 }
                    origin { x: /*itemAngle > 0 ? 0 : listView.itemWidth*/ listView.itemWidth / 2; y: height / 2 }
                },
                Translate {
                    x: itemOffset
                }

            ]

            WorkspacePreview {
                height: listView.height
                width: listView.itemWidth
                background: root.background
                screenHeight: screen.physicalSize.height
            }

            Label {
                anchors.centerIn: parent
                text: model.text
                fontSize: "large"
                color: "red"
            }
        }

        MouseArea {
            id: dndArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            anchors.leftMargin: listView.leftMargin
            anchors.rightMargin: listView.rightMargin


            property int draggedIndex: -1

            onMouseXChanged: {
                var progress = Math.max(0, Math.min(1, (mouseX - listView.foldingAreaWidth*2) / (width - listView.foldingAreaWidth * 4)))
//                var progress = mouseX / width
//                print("p:", progress)
                listView.contentX = listView.originX + (listView.contentWidth - listView.width + listView.leftMargin + listView.rightMargin) * progress - listView.leftMargin


                if (draggedIndex == -1) {
                    return;
                }

//                var newIndex = (listView.realContentX) / listView.itemWidth
                var coords = mapToItem(listView.contentItem, mouseX + listView.itemWidth, mouseY)
                var newIndex = (coords.x + listView.leftMargin) / (listView.itemWidth + listView.spacing)
                print("newIndex", newIndex)
//                var newIndex = listView.indexAt(coords.x, coords.y)
//                if (newIndex == -1) return;

                if (newIndex > draggedIndex + 1) {
                    newIndex = draggedIndex + 1
                } else if (newIndex < draggedIndex) {
                    newIndex = draggedIndex - 1
                } else {
                    return
                }

                if (newIndex >= 0 && newIndex < listView.count) {
                    listView.model.move(draggedIndex, newIndex, 1)
                    draggedIndex = newIndex
                }
            }

            onReleased: {
                draggedIndex = -1
            }

            onPressAndHold: {
//                var clickedItem = listView.itemAt(mouseX /*+ listView.realContentX*/, mouseY)
//                var clickedIndex = listView.indexAt(mouseX /*- listView.realContentX*/, mouseY)

                for (var i = 0; i < listView.count; i++) {
                    var x = -listView.leftMargin + i * listView.itemWidth - units.gu(1);
                    print("x:", x, "index:", listView.indexAt(x, listView.height / 2))
                }

                var coords = mapToItem(listView.contentItem, mouseX, mouseY)
                var clickedIndex = listView.indexAt(coords.x, coords.y)

                draggedIndex = clickedIndex

                print("index:", mouseX, clickedIndex)
            }

        }
    }
}
