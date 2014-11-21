import QtQuick 2.3
import MeeGo.QOfono 0.2

Item {
    id: simManager

    property string modemPath
    readonly property alias present: d.present

    ////

    QtObject {
        id: d

        property bool present: false

        function updatePresence() {
            d.present = MockQOfono.isModemPresent(simManager.modemPath)
        }
    }

    onModemPathChanged: d.updatePresence()

    Connections {
        target: MockQOfono
        onModemsChanged: d.updatePresence()
    }
}
