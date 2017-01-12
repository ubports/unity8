import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.InputInfo 0.1

Rectangle {
    id: rect
    color: "white"
    width: parent.width
    height: parent.height

    Action {
        id: mouseAction
        text: checked ? "Remove Mouse" : "Add Mouse"
        onTriggered: {
            if (checked) {
                console.log("ADD")
                MockInputDeviceBackend.addMockDevice("/mouse0", InputInfo.Mouse);
            } else {
                console.log("REMOVE")
                MockInputDeviceBackend.removeDevice("/mouse0");
            }
        }
        iconName: "input-mouse-symbolic"
        checkable: true
        checked: false
    }

    Action {
        id: kbAction
        text: checked ? "Remove Keyboard" : "Add Keyboard"
        onTriggered: {
            if (checked) {
                MockInputDeviceBackend.addMockDevice("/kbd0", InputInfo.Keyboard);
            } else {
                MockInputDeviceBackend.removeDevice("/kbd0");
            }
        }
        iconName: "input-keyboard-symbolic"
        checkable: true
        checked: false
    }

    Column {
        anchors {
            fill: parent
            margins: units.gu(1)
        }
        spacing: units.gu(1)

        Button {
            anchors {
                left: parent.left
                right: parent.right
            }
            action: mouseAction
            color: mouseAction.checked ? UbuntuColors.red : UbuntuColors.green
        }

        Button {
            anchors {
                left: parent.left
                right: parent.right
            }
            action: kbAction
            color: kbAction.checked ? UbuntuColors.red : UbuntuColors.green
        }
    }
}
