import QtQuick 2.4
import Ubuntu.Components 1.3
import GSettings  1.0

AbstractButton {
    id: root

    GSettings {
        id: settings
        schema.id: "com.canonical.Unity8"
    }

    onClicked: {
        Qt.openUrlExternally(settings.appstoreUri)
    }

    UbuntuShape {
        width: parent.width
        height: parent.height - units.gu(1)
        color: "#20ffffff"
        aspect: UbuntuShape.Flat

        Row {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(1)

            Icon {
                height: units.gu(2.2)
                width: height
                name: "stock_application"
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
            }

            Label {
                text: i18n.tr("More apps in the store")
                anchors.verticalCenter: parent.verticalCenter
                fontSize: "small"
            }

            Icon {
                height: units.gu(2.5)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                name: "go-next"
                color: "white"
            }
        }
    }
}
