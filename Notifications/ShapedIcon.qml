import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property string fileSource
    property bool shaped

    UbuntuShape {
        anchors.fill: parent
        visible: shaped
        image: Image {
            source: fileSource
            fillMode: Image.PreserveAspectCrop
        }
    }

    Image {
        anchors.fill: parent
        visible: !shaped
        source: fileSource
        fillMode: Image.PreserveAspectCrop
    }
}
