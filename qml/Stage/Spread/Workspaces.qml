import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root
    implicitWidth: listView.count * (height * 16/9)

    property var screen: null

    ListView {
        id: listView
        anchors.fill: parent
        anchors.leftMargin: -itemWidth
        anchors.rightMargin: -itemWidth

        model: 5

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
            width: dndArea.draggedIndex == index ? units.gu(5) : listView.itemWidth
            Behavior on width { UbuntuNumberAnimation {} }

            property int itemX: -listView.contentX - listView.leftMargin + index * (listView.itemWidth + listView.spacing)
            property int distanceFromLeft: itemX
            property int distanceFromRight: listView.width - listView.leftMargin - listView.rightMargin - itemX - listView.itemWidth

            property int maxAngle: 40

            property int itemAngle: {
                if (index == 0) {
                    if (distanceFromLeft < 0) {
                        var progress = (distanceFromLeft + listView.foldingAreaWidth) / listView.foldingAreaWidth
                        return linearAnimation(1, -1, 0, maxAngle, Math.max(-1, Math.min(1, progress)));
                    }
                    return 0
                }
                if (index == listView.count - 1) {
                    if (distanceFromRight < 0) {
                        var progress = (distanceFromRight + listView.foldingAreaWidth) / listView.foldingAreaWidth
                        return linearAnimation(1, -1, 0, -maxAngle, Math.max(-1, Math.min(1, progress)));
                    }
                    return 0
                }

                if (distanceFromLeft < listView.foldingAreaWidth) {
                    // itemX : 10gu = p : 100
                    var progress = distanceFromLeft / listView.foldingAreaWidth
                    return linearAnimation(1, -1, 0, maxAngle, Math.max(-1, Math.min(1, progress)));
                }
                if (distanceFromRight < listView.foldingAreaWidth) {
                    var progress = distanceFromRight / listView.foldingAreaWidth
                    return linearAnimation(1, -1, 0, -maxAngle, Math.max(-1, Math.min(1, progress)));
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

            }

        }
    }
}
