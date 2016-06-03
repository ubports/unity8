import QtQuick 2.4
import Ubuntu.Components 1.3

Column {
    id: root
    property alias title: titleLabel.text
    property alias iconSource: icon.source


    Image {
        id: icon
        width: units.gu(5)
        height: width
    }
    Label {
        id: titleLabel
    }
}
