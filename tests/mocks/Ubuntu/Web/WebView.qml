import QtQuick 2.0

Item {
    property url url
    property int loadProgress: 0

    onUrlChanged: loadProgress = 100
}
