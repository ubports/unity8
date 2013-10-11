import QtQuick 2.0
import QMenuModel 0.1

QtObject {
    property string name
    property UnityMenuModel model
    property int index

    readonly property var state: undefined
    readonly property bool valid: false
}
