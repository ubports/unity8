import QtQuick 2.0
import ListViewWithPageHeader 0.1

Rectangle {
    width: 300
    height: 542
    color: "lightblue"

    focus: true
    Keys.onPressed: {
        if (event.key == Qt.Key_B) {
            listView.positionAtBeginning()
        } else if (event.key == Qt.Key_1) {
            animalsModel.setProperty(0, "size", 400);
        } else if (event.key == Qt.Key_2) {
            animalsModel.setProperty(1, "size", 400);
        } else if (event.key == Qt.Key_3) {
            animalsModel.setProperty(1, "size", 10);
        } else if (event.key == Qt.Key_H) {
            listView.headerItem.height = 100
        } else if (event.key == Qt.Key_D) {
            listView.delegate = otherRect
        } else if (event.key == Qt.Key_F) {
            listView.header = null
        }
    }


    ListModel {
        id: model

        function insertItem(index, size) {
            insert(index, { size: size });
        }

        function removeItems(index, count) {
            remove(index, count);
        }

        function moveItems(indexFrom, indexTo, count) {
            move(indexFrom, indexTo, count);
        }

        ListElement { size: 150 }
        ListElement { size: 200 }
        ListElement { size: 350 }
        ListElement { size: 350 }
        ListElement { size: 350 }
        ListElement { size: 350 }
    }

    Component {
        id: otherRect
        Rectangle {
            height: 35
            width: parent.width
            color: index % 2 == 0 ? "yellow" : "purple"
        }
    }

    ListViewWithPageHeader {
        id: listView
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: model
        delegate: Rectangle {
            property bool timerDone: false
            width: parent.width - 20
            x: 10
            color: index % 2 == 0 ? "red" : "blue"
            height: timerDone ? size : 350
            Text {
                text: index
            }
            Timer {
                id: sizeTimer
                interval: 10;
                onTriggered: {
                    timerDone = true
                }
            }
            Component.onCompleted: {
                sizeTimer.start()
            }
        }

        pageHeader: Rectangle {
            color: "transparent"
            width: parent.width
            height: 50
            Text {
                anchors.fill: parent
                text: "APPS"
                font.pixelSize: 40
            }
        }
    }
}
