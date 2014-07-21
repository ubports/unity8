import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Settings.Components 0.1

GridLayout {
    id: grid
    anchors {
        left: parent.left;
        right: parent.right;
    }
    columns: 2 + repeater.count % 2
    property alias model: repeater.model
    Repeater {
        id: repeater
        delegate: Row {
            spacing: units.gu(0.5)
            readonly property int column: index % grid.columns;
            Layout.alignment: {
                if (column == 0) return Qt.AlignLeft;
                if (column == grid.columns - 1 || index == repeater.count - 1) return Qt.AlignRight;
                if (column == 1) return Qt.AlignHCenter;
            }
            Layout.columnSpan: index == repeater.count - 1 && grid.columns == 3 && column == 1 ? 2 : 1
            Layout.maximumWidth: Math.max(icon.width, label.x + label.implicitWidth)
            Layout.fillWidth: true
            StatusIcon {
                id: icon
                height: units.gu(2)
                sets: ["actions", "status", "apps"]
                source: "icon" in modelData ? modelData["icon"] : ""
            }
            Label {
                id: label
                width: parent.width - x
                anchors.verticalCenter: parent.verticalCenter
                text: "value" in modelData ? modelData["value"] : "";
                elide: Text.ElideRight
                maximumLineCount: 1
                font.weight: "style" in modelData && modelData["style"] == "highlighted" ? Font.DemiBold : Font.Light
            }
        }
    }
}
