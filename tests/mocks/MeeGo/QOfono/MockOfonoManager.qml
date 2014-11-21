import QtQuick 2.3
import MeeGo.QOfono 0.2

Item {
    readonly property var modems: MockQOfono.modems
    readonly property bool available: MockQOfono.available
}
