import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.2
import Ubuntu.Components.Popups 1.2

Dialog {
    id: root

    property alias model: appRepeater.model

    signal forceClose();

    Label {
        text: i18n.tr("Apps may have unsaved data:")
        fontSize: "large"
    }

    Repeater {
        id: appRepeater
        RowLayout {
            spacing: units.gu(2)
            Image {
                Layout.preferredHeight: units.gu(2)
                Layout.preferredWidth: units.gu(2)
                source: model.icon
                sourceSize.width: width
                sourceSize.height: height
            }
            Label {
                Layout.fillWidth: true
                text: model.name
            }
        }
    }

    Label {
        text: i18n.tr("Re-dock, save your work and close these apps to continue.")
        wrapMode: Text.WordWrap
    }

    Label {
        text: i18n.tr("Or force close now (unsaved data will be lost).")
        wrapMode: Text.WordWrap
    }

    ThinDivider {}

    RowLayout {
        Label {
            objectName: "reconnectLabel"
            Layout.fillWidth: true
            property bool clicked: false
            property string notClickedText: i18n.tr("OK, I will reconnect")
            property string clickedText: i18n.tr("Reconnect now!")
            text: clicked ? clickedText : notClickedText

            MouseArea {
                anchors.fill: parent
                onClicked: parent.clicked = true;
            }
        }

        Button {
            objectName: "forceCloseButton"
            text: i18n.tr("Close all")
            color: UbuntuColors.red
            onClicked: {
                root.forceClose();
                PopupUtils.close(root);
            }
        }
    }
}
