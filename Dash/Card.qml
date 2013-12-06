import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property var template
    property var components
    property var cardData

    width: {
       if (template !== undefined) {
           switch (template['card-size']) {
               case "small": return units.gu(12);
               case "large": return units.gu(38);
           }
       }
       return units.gu(18.5);
    }
    height: childrenRect.height

    UbuntuShape {
        id: artShape
        objectName: "artShape"
        width: image.fillMode === Image.PreserveAspectCrop || aspect < image.aspect ? image.width : height * image.aspect
        height: image.fillMode === Image.PreserveAspectCrop || aspect > image.aspect ? image.height : width / image.aspect
        anchors.horizontalCenter: parent.horizontalCenter

        property real aspect: components !== undefined ? components["art"]["aspect-ratio"] : 1

        image: Image {
            width: root.width
            height: width / artShape.aspect
            objectName: "artImage"
            // FIXME should be no need for "icon"
            source: cardData && cardData["art"] || cardData["icon"] || ""
            // FIXME uncomment when having investigated / fixed the crash
            //sourceSize.width: width > height ? width : 0
            //sourceSize.height: height > width ? height : 0
            fillMode: components["art"]["fill-mode"] == "fit" ? Image.PreserveAspectFit: Image.PreserveAspectCrop

            property real aspect: implicitWidth / implicitHeight
        }
    }

    CardHeader {
        id: header
        objectName: "cardHeader"
        anchors {
            top: artShape.bottom
            left: parent.left
            right: parent.right
        }

        mascot: cardData && cardData["mascot"] || ""
        title: cardData && cardData["title"] || ""
        subtitle: cardData && cardData["subtitle"] || ""
    }

    Label {
        objectName: "summaryLabel"
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        maximumLineCount: 5
        elide: Text.ElideRight
        text: cardData && cardData["summary"] || ""
    }
}
