import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Screens 0.1
import Unity.Application 0.1
import ".."

Item {
    id: root
    property string background

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(1)
//        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        spacing: units.gu(1)

        Repeater {
            model: Screens

            delegate: Item {
                height: root.height - units.gu(6)
                width: workspaces.implicitWidth


                Rectangle { anchors.fill: parent; color: "blue" }

                Rectangle {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(7)
                    color: "white"

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


                Workspaces {
                    id: workspaces
                    height: parent.height - header.height
                    anchors.bottom: parent.bottom
                }

//                WorkspacePreview {
//                    height: root.height - units.gu(6)
//                    background: root.background
//                }
            }
        }
    }
}
