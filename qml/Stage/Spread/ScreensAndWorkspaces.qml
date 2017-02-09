import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Unity.Screens 0.1
import Unity.Application 0.1
import ".."

Item {
    id: root

    property string background

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.left: parent.left
        spacing: units.gu(1)

        Repeater {
            model: Screens

            delegate: Item {
                height: root.height - units.gu(6)
                width: workspaces.width
                clip: true

                UbuntuShape {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(7)
                    backgroundColor: "white"
                    z: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)

                        Label {
                            text: model.screen.name
                            color: "black"
                        }

                        Label {
                            text: model.screen.outputType === Screens.LVDS ? "Built-in" : "Clone"
                            color: "black"
                            fontSize: "x-small"
                        }

                        Label {
                            text: model.screen.physicalSize.width + "x" + model.screen.physicalSize.height
                            color: "black"
                            fontSize: "x-small"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
//                        acceptedButtons: Qt.RightButton


                        onClicked: {
                            print("should open popup")
                            PopupUtils.open(contextMenu)
                        }
                    }

                    Component {
                        id: contextMenu
                        ActionSelectionPopover {
                            actions: ActionList {
                                Action {
                                    text: "Add workspace"
                                    onTriggered: workspaces.workspaceModel.append({text: "" + workspaces.workspaceModel.count})
                                }
                            }
                        }
                    }
                }


                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: Math.min(implicitWidth, units.gu(80), root.width)
                    Behavior on width { UbuntuNumberAnimation {} }
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                    screen: model.screen
                    background: root.background

                    workspaceModel: ListModel {
                        onCountChanged: print("model count changed to", count)
                        ListElement {text: "1"}
//                        ListElement {text: "2"}
//                        ListElement {text: "3"}
//                        ListElement {text: "4"}
//                        ListElement {text: "5"}
//                        ListElement {text: "6"}
//                        ListElement {text: "7"}
//                        ListElement {text: "8"}
//                        ListElement {text: "9"}
                    }
                }
            }
        }
    }
}
