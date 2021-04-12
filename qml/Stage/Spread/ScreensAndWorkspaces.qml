import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import WindowManager 1.0
import Unity.Application 0.1
import ".."

Item {
    id: root

    property string background

    property var screensProxy: Screens.createProxy();

    property QtObject activeWorkspace: null

    signal closeSpread();

    Row {
        id: row
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: LomiriAnimation.SlowDuration } }
        spacing: units.gu(1)

        property var selectedIndex: undefined

        Repeater {
            model: screensProxy

            delegate: Item {
                height: root.height - units.gu(6)
                width: workspaces.width

                Item {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(7)
                    z: 1

                    property bool isCurrent: {
                        // another screen is selected.
                        if (row.selectedIndex != undefined && row.selectedIndex != index) return false;

                        // this screen is active.
                        if (WMScreen.active && WMScreen.isSameAs(model.screen) && WMScreen.currentWorkspace.isSameAs(activeWorkspace)) return true;
                        if (model.screen.workspaces.indexOf(activeWorkspace) >= 0) return true;

                        // not active.
                        return false;
                    }

                    property bool isSelected: screenMA.containsMouse
                    onIsSelectedChanged: {
                        if (isSelected) {
                            row.selectedIndex = Qt.binding(function() { return index; });
                        } else if (row.selectedIndex === index) {
                            row.selectedIndex = undefined;
                        }
                    }

                    LomiriShape {
                        anchors.fill: parent
                        backgroundColor: "white"
                        opacity: header.isCurrent || header.isSelected ? 1.0 : 0.5
                    }

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
                            color: header.isCurrent || header.isSelected ? "black" : "white"
                        }

                        Label {
                            text: model.screen.outputTypeName
                            color: header.isCurrent || header.isSelected ? "black" : "white"
                            fontSize: "x-small"
                        }

                        Label {
                            text: screen.availableModes[screen.currentModeIndex].size.width + "x" + screen.availableModes[screen.currentModeIndex].size.height
                            color: header.isCurrent || header.isSelected ? "black" : "white"
                            fontSize: "x-small"
                        }
                    }

                    Icon {
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: units.gu(1)
                        }
                        width: units.gu(3)
                        height: width
                        source: "image://theme/select"
                        color: header.isCurrent || header.isSelected ? "black" : "white"
                        visible: model.screen.active
                    }

                    MouseArea {
                        id: screenMA
                        hoverEnabled: true
                        anchors.fill: parent

                        onClicked: {
                            var obj = screensMenuComponent.createObject(header)
                            obj.open(mouseX, mouseY)
                        }
                    }

                    Component {
                        id: screensMenuComponent
                        LomiriShape {
                            id: screensMenu
                            width: units.gu(20)
                            height: contentColumn.childrenRect.height
                            backgroundColor: "white"

                            function open(mouseX, mouseY) {
                                x = Math.max(0, Math.min(mouseX - width / 2, parent.width - width))
                                y = mouseY + units.gu(1)
                            }

                            InverseMouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    screensMenu.destroy()
                                }
                            }

                            Column {
                                id: contentColumn
                                width: parent.width
                                ListItem {
                                    height: layout.height
                                    highlightColor: "transparent"
                                    ListItemLayout {
                                        id: layout
                                        title.text: qsTr("Add workspace")
                                        title.color: "black"
                                    }
                                    onClicked: {
                                        screen.workspaces.addWorkspace();
                                        Screens.sync(root.screensProxy);
                                        screensMenu.destroy();
                                    }
                                }
                            }
                        }
                    }
                }

                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: {
                        var width = 0;
                        if (screensProxy.count == 1) {
                            width = Math.min(implicitWidth, root.width - units.gu(8));
                        } else {
                            width = Math.min(implicitWidth, model.screen.active ? root.width - units.gu(48) : units.gu(40))
                        }
                        return Math.max(workspaces.minimumWidth, width);
                    }

                    Behavior on width { LomiriNumberAnimation {} }
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                    screen: model.screen
                    background: root.background

                    workspaceModel: model.screen.workspaces
                    activeWorkspace: root.activeWorkspace
                    readOnly: false

                    onCommitScreenSetup: Screens.sync(root.screensProxy)
                    onCloseSpread: root.closeSpread();

                    onClicked: {
                        root.activeWorkspace = workspace;
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
        DropArea {
            id: leftFakeDropArea
            anchors.fill: parent
            keys: ["application", "workspace"]
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
        DropArea {
            id: rightFakeDropArea
            anchors.fill: parent
            keys: ["application", "workspace"]
        }
    }
    Timer {
        repeat: true
        running: leftScrollArea.containsMouse || rightScrollArea.containsMouse || leftFakeDropArea.containsDrag || rightFakeDropArea.containsDrag
        interval: LomiriAnimation.SlowDuration
        triggeredOnStart: true
        onTriggered: {
            var newOffset = row.anchors.horizontalCenterOffset;
            var maxOffset = Math.max((row.width - root.width + units.gu(10)) / 2, 0);
            if (leftScrollArea.containsMouse || leftFakeDropArea.containsDrag) {
                newOffset += units.gu(20)
            } else {
                newOffset -= units.gu(20)
            }
            newOffset = Math.max(-maxOffset, Math.min(maxOffset, newOffset));
            row.anchors.horizontalCenterOffset = newOffset;
        }
    }
}
