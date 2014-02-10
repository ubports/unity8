import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    implicitHeight: image.implicitHeight
    implicitWidth: image.implicitWidth

    property var application
    onApplicationChanged: print("setting app to", application.appId, application.screenshot)

    function switchTo(application) {
        if (root.application == application) {
            root.switched();
            return;
        }

        priv.newApplication = application
        root.visible = true;
        switchToAnimation.start()
    }

    signal switched()

    QtObject {
        id: priv
        property var newApplication
    }

    Image {
        id: newImage
        visible: true
        anchors.bottom: parent.bottom
        width: root.width
//        height: sourceSize.height
        source: priv.newApplication ? priv.newApplication.screenshot : ""
    }

    Image {
        id: image
        visible: true
        source: root.application ? root.application.screenshot : ""
        width: root.width
        height: sourceSize.height

    }
//    Rectangle { anchors.fill: parent; color: "yellow" }

    SequentialAnimation {
        id: switchToAnimation
        ParallelAnimation {
            UbuntuNumberAnimation { target: image; property: "x"; from: 0; to: root.width; duration: UbuntuAnimation.SlowDuration }
            UbuntuNumberAnimation { target: newImage; property: "scale"; from: 0.7; to: 1; duration: UbuntuAnimation.SlowDuration }
        }
        ScriptAction {
            script: {
                image.x = 0
                root.application = priv.newApplication
                root.visible = false;
                priv.newApplication = null
                root.switched();
            }
        }
    }
}
