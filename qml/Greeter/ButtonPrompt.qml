import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"

FocusScope {
    id: root
    objectName: "promptButton"

    property alias text: buttonLabel.text
    property alias interactive: root.enabled
    property bool isSecret
    property bool loginError: false
    property bool hasKeyboard: false
    property string enteredText: ""

    signal clicked()
    signal canceled()
    signal accepted(string response)

    Keys.onSpacePressed: clicked();
    Keys.onReturnPressed: clicked();
    Keys.onEnterPressed: clicked();

    anchors.fill: parent

    activeFocusOnTab: true

    Rectangle {
        anchors.fill: parent
        radius: units.gu(0.5)
        color: "#7A111111"
        Behavior on border.color {
            ColorAnimation{}
        }
        border {
            color: root.loginError ? theme.palette.normal.negative : theme.palette.normal.raisedSecondaryText
            width: root.loginError ? units.dp(2): units.dp(1)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked();
    }

    Label {
        id: buttonLabel
        anchors.centerIn: parent
        color: theme.palette.normal.raisedSecondaryText
    }
}
