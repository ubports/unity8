import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    id: root
    clip: true

    property alias title: titleLabel.text

    signal close()
    signal minimize()
    signal maximize()

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: -radius
        radius: units.gu(.5)
        gradient: Gradient {
            GradientStop { color: "#626055"; position: 0 }
            GradientStop { color: "#3C3B37"; position: 1 }
        }
    }

    Row {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: units.gu(0.7) }
        spacing: units.gu(0.5)
        Rectangle {
            height: parent.height; width: height; radius: height / 2
            gradient: Gradient {
                GradientStop { color: "#F49073"; position: 0 }
                GradientStop { color: "#DF4F1C"; position: 1 }
            }
            border.width: units.dp(.5)
            border.color: "black"
            MouseArea { anchors.fill: parent; onClicked: root.close() }
        }
        Rectangle {
            height: parent.height; width: height; radius: height / 2
            gradient: Gradient {
                GradientStop { color: "#92918C"; position: 0 }
                GradientStop { color: "#5E5D58"; position: 1 }
            }
            border.width: units.dp(.5)
            border.color: "black"
            MouseArea { anchors.fill: parent; onClicked: root.minimize() }
        }
        Rectangle {
            height: parent.height; width: height; radius: height / 2
            gradient: Gradient {
                GradientStop { color: "#92918C"; position: 0 }
                GradientStop { color: "#5E5D58"; position: 1 }
            }
            border.width: units.dp(.5)
            border.color: "black"
            MouseArea { anchors.fill: parent; onClicked: root.maximize() }
        }

        Label {
            id: titleLabel
            color: "#DFDBD2"
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            fontSize: "small"
            font.bold: true
        }
    }
}
