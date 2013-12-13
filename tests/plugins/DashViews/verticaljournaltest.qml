
import QtQuick 2.1
import Journals 0.1

Item {

    VerticalJournal {
        id: vj
        anchors.fill: parent
        columnWidth: 150
        horizontalSpacing: 10
        verticalSpacing: 10

        delegate: Rectangle {
            property real randomValue: Math.random()
            width: 150
            color: randomValue < 0.3 ? "green" : randomValue < 0.6 ? "blue" : "red";
            height: modelHeight
            border.width: 3

            Text {
                text: index + "\ny: " + parent.y + "\nheight: " + parent.height
                x: 10
                y: 10
            }
        }
    }
}
