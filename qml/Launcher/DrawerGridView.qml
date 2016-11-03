import QtQuick 2.4

Item {
    id: root

    property int delegateWidth: units.gu(10)
    property int delegateHeight: units.gu(10)
    property alias delegate: gridView.delegate
    property alias model: gridView.model
    property alias interactive: gridView.interactive

    property alias header: gridView.header
    property alias topMargin: gridView.topMargin
    property alias bottomMargin: gridView.bottomMargin

    readonly property int columns: width / delegateWidth
    readonly property int rows: Math.ceil(gridView.model.count / root.columns)

    GridView {
        id: gridView
        anchors.fill: parent
        leftMargin: spacing

        readonly property int overflow: width - (root.columns * root.delegateWidth)
        readonly property real spacing: overflow / (root.columns)

        cellWidth: root.delegateWidth + spacing
        cellHeight: root.delegateHeight
    }
}

