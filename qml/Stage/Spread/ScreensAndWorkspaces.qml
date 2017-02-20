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
        id: row
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: UbuntuAnimation.SlowDuration } }
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

                    DropArea {
                        anchors.fill: parent
                        keys: ["workspace"]

                        onEntered: {
                            workspaces.workspaceModel.insert(workspaces.workspaceModel.count, {text: drag.source.text})
                            drag.source.inDropArea = true;
                        }

                        onExited: {
                            workspaces.workspaceModel.remove(workspaces.workspaceModel.count - 1, 1)
                            drag.source.inDropArea = false;
                        }

                        onDropped: {
                            drag.source.inDropArea = false;
                        }
                    }

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
                                    onTriggered: workspaces.workspaceModel.append({text: "" + (workspaces.workspaceModel.count + 1)})
                                }
                            }
                        }
                    }
                }


                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: Math.min(implicitWidth, index == 0 ? units.gu(80) : units.gu(40), root.width)
                    Behavior on width { UbuntuNumberAnimation {} }
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                    screen: model.screen
                    background: root.background

                    workspaceModel: ListModel {
                        onCountChanged: print("model count changed to", count)
                        ListElement {text: "1"}
                        ListElement {text: "2"}
                        ListElement {text: "3"}
                        ListElement {text: "4"}
                        ListElement {text: "5"}
                        ListElement {text: "6"}
//                        ListElement {text: "7"}
//                        ListElement {text: "8"}
//                        ListElement {text: "9"}
                    }
                }
            }
        }
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: units.gu(6); bottomMargin: units.gu(1) }
        width: units.gu(5)
        color: "#33000000"
        visible: (row.width - root.width + units.gu(10)) / 2 - row.anchors.horizontalCenterOffset > units.gu(5)
        MouseArea {
            id: leftScrollArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: mouse.accepted = false;
        }
    }
    Rectangle {
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: units.gu(6); bottomMargin: units.gu(1) }
        width: units.gu(5)
        color: "#33000000"
        visible: (row.width - root.width + units.gu(10)) / 2 + row.anchors.horizontalCenterOffset > units.gu(5)
        MouseArea {
            id: rightScrollArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: mouse.accepted = false;
        }
    }
    Timer {
        repeat: true
        running: leftScrollArea.containsMouse || rightScrollArea.containsMouse
        interval: UbuntuAnimation.SlowDuration
        triggeredOnStart: true
        onTriggered: {
            var newOffset = row.anchors.horizontalCenterOffset;
            var maxOffset = Math.max((row.width - root.width + units.gu(10)) / 2, 0);
            if (leftScrollArea.containsMouse) {
                newOffset += units.gu(20)
            } else {
                newOffset -= units.gu(20)
            }
            newOffset = Math.max(-maxOffset, Math.min(maxOffset, newOffset));
            row.anchors.horizontalCenterOffset = newOffset;
        }
    }
}
