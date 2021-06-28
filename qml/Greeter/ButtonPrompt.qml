import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"

FocusScope {
    id: root
    objectName: "promptButton"
    focus: true

    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false
    property string enteredText: ""
    property bool inputFocus

    signal clicked()
    signal canceled()
    signal accepted()

    Keys.onSpacePressed: triggered();
    Keys.onReturnPressed: triggered();
    Keys.onEnterPressed: triggered();

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
            color: loginError ? theme.palette.normal.negative : theme.palette.normal.raisedSecondaryText
            width: loginError ? units.dp(3): units.dp(2)
        }
    }

    function triggered() {
        if (root.interactive) {
            root.clicked();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.triggered();
    }

    Label {
        anchors.centerIn: parent
        color: theme.palette.normal.raisedSecondaryText
        text: root.text
    }
}
