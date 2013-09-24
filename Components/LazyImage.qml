import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root

    property url source

    property real initialWidth: units.gu(5)
    property real initialHeight: units.gu(5)

    property alias sourceSize: image.sourceSize
    property alias fillMode: image.fillMode
    property alias asynchronous: image.asynchronous
    property alias cache: image.cache
    property alias horizontalAlignment: image.horizontalAlignment
    property alias verticalAlignment: image.verticalAlignment

    state: "default"

    onSourceChanged: {
        if (state === "ready") {
            state = "default";
            image.nextSource = source;
        } else {
            image.source = source;
        }
    }

    UbuntuShape {
        id: placeholder
        color: "#22000000"
        anchors.fill: parent

        ActivityIndicator {
            id: activity
            objectName: "activity"
            anchors.centerIn: parent
            opacity: 0
            visible: opacity != 0

            running: visible
        }

        Image {
            id: errorImage
            objectName: "errorImage"
            anchors.centerIn: parent
            opacity: 0
            visible: opacity != 0

            source: "graphics/close.png"
            sourceSize { width: units.gu(3); height: units.gu(3) }
        }
    }

    UbuntuShape {
        id: shape
        objectName: "shape"
        anchors.fill: parent
        opacity: 0
        visible: opacity != 0

        image: Image {
            id: image

            property url nextSource

            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }
    }

    states: [
        State {
            name: "default"
            when: image.source == ""
            PropertyChanges { target: root; implicitWidth: root.initialWidth; implicitHeight: root.initialHeight }
            PropertyChanges { target: errorImage; opacity: 0 }
        },
        State {
            name: "loading"
            extend: "default"
            when: image.status === Image.Loading
            PropertyChanges { target: root; implicitWidth: root.initialWidth; implicitHeight: root.initialHeight }
            PropertyChanges { target: activity; opacity: 1 }
        },
        State {
            name: "ready"
            when: image.status === Image.Ready && image.source != ""
            PropertyChanges { target: root; implicitWidth: image.width; implicitHeight: image.height }
            PropertyChanges { target: shape; opacity: 1 }
            PropertyChanges { target: placeholder; visible: false }
        },
        State {
            name: "error"
            extend: "default"
            when: image.status === Image.Error
            PropertyChanges { target: errorImage; opacity: 1.0 }
        }
    ]

    transitions: [
        Transition {
            to: "ready"
            SequentialAnimation {
                PropertyAction { target: shape; property: "visible" }
                ParallelAnimation {
                    NumberAnimation { target: shape; property: "opacity"; easing.type: Easing.Linear }
                    UbuntuNumberAnimation { target: root; properties: "implicitWidth,implicitHeight" }
                }
                PropertyAction { target: placeholder; property: "visible" }
            }
        },

        Transition {
            to: "*"
            SequentialAnimation {
                PropertyAction { target: placeholder; property: "visible" }
                ParallelAnimation {
                    NumberAnimation { target: shape; property: "opacity"; easing.type: Easing.Linear }
                    NumberAnimation {
                        targets: [activity, errorImage]; property: "opacity";
                        easing.type: Easing.Linear; duration: UbuntuAnimation.SnapDuration
                    }
                    UbuntuNumberAnimation { target: root; properties: "implicitWidth,implicitHeight" }
                }
                PropertyAction { target: shape; property: "visible" }
            }

            onRunningChanged: {
                if (!running && state === "default" && image.nextSource !== "") {
                    image.source = image.nextSource;
                    image.nextSource = "";
                }
            }
        }
    ]
}
