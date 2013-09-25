import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../../../Components"

Row {
    property LazyImage image

    anchors { left: parent.left; right: parent.right }
    spacing: units.gu(1)

    function blank() { blankButton.clicked() }
    function wide() { wideButton.clicked() }
    function square() { squareButton.clicked() }
    function portrait() { portraitButton.clicked() }
    function badpath() { badpathButton.clicked() }

    Button {
        id: blankButton
        width: parent / 5
        text: "Blank"
        onClicked: image.source = ""
    }

    Button {
        id: wideButton
        width: parent / 5
        text: "Wide"
        onClicked: image.source = "wide.png"
    }

    Button {
        id: squareButton
        width: parent / 5
        text: "Square"
        onClicked: image.source = "square.png"
    }

    Button {
        id: portraitButton
        width: parent / 5
        text: "Portrait"
        onClicked: image.source = "portrait.png"
    }

    Button {
        id: badpathButton
        width: parent / 5
        text: "Bad path"
        onClicked: image.source = "bad/path"
    }
}
