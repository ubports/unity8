import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Application 0.1
import "../Components"

/*

*/

Item {
    id: root

    // Controls to be set from outside
    property bool shown: false
    property bool moving: false

    // State information propagated to the outside
    readonly property bool painting: mainScreenshotImage.visible || fadeInScreenshotImage.visible

    onMovingChanged: {
        if (moving) {
            priv.requestNewScreenshot();
        } else {
            mainScreenshotImage.visible = false;
        }
    }

    Connections {
        target: ApplicationManager

        onFocusRequested: {
            print("******focus requested*********", appId, "currently focused:", priv.focusedAppId, priv.focusedScreenshot)
            mainScreenshotImage.src = priv.focusedScreenshot;
            mainScreenshotImage.visible = true;
            mainScreenshotImage.anchors.leftMargin = 0;
            priv.grantFocus(appId);
        }

        onFocusedApplicationIdChanged: {
            print("*** ApplicationManager.focusedAppId changed appId:", priv.focusedAppId, "shown:", root.shown)

            if (ApplicationManager.focusedApplicationId.length > 0) {
                priv.applicationStarting = false;
                priv.secondApplicationStarting = false;

                // There is a new focused one
                if (root.shown){
                    print("starting applicationSwitchingAnimation");
                    applicationSwitchingAnimation.start();
                }
            }
        }

        onApplicationAdded: {
            if (!priv.focusedApplication) {
                print("*** applicationStarting")
                priv.applicationStarting = true;
            } else {
                print("*** SECONDapplicationStarting")
                priv.secondApplicationStarting = true;
            }
        }
    }

    QtObject {
        id: priv

        property string focusedAppId: ApplicationManager.focusedApplicationId
        property var focusedApplication: ApplicationManager.findApplication(focusedAppId)
        property url focusedScreenshot: focusedApplication ? focusedApplication.screenshot : ""

        property bool waitingForScreenshot: false

        property bool applicationStarting: false
        property bool secondApplicationStarting: false

        onFocusedScreenshotChanged: {
            waitingForScreenshot = false;
            if (root.moving) {
                print("*** moving app", ApplicationManager.focusedApplicationId, "setting screenshot to", ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).screenshot)
                mainScreenshotImage.src = ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).screenshot;
                mainScreenshotImage.visible = true;
            }
        }

        function requestNewScreenshot() {
            print("requesting new screenshot for", ApplicationManager.focusedApplicationId);
            waitingForScreenshot = true;
            ApplicationManager.updateScreenshot(ApplicationManager.focusedApplicationId);
        }

        function grantFocus(appId) {
            grantFocusTimer.appId = appId;
            grantFocusTimer.start();
        }

    }

    Timer {
        id: grantFocusTimer
        interval: 1
        repeat: false
        property string appId
        onTriggered: {
            print("*** Calling AppManager.focusApplication(", appId, "). Image is visible:", mainScreenshotImage.visible)
            ApplicationManager.focusApplication(appId);
        }
    }

    SequentialAnimation {
        id: applicationSwitchingAnimation
        // setup
        PropertyAction { target: mainScreenshotImage; property: "anchors.leftMargin"; value: 0 }
        PropertyAction { target: fadeInScreenshotImage; property: "source"; value: priv.focusedScreenshot }
        PropertyAction { target: fadeInScreenshotImage; property: "visible"; value: true }
        PropertyAction { target: fadeInScreenshotImage; property: "opacity"; value: 0 }
        PropertyAction { target: fadeInScreenshotImage; property: "scale"; value: .8 }

        // The actual animation
        ParallelAnimation {
            UbuntuNumberAnimation { target: mainScreenshotImage; property: "anchors.leftMargin"; to: root.width; duration: UbuntuAnimation.SlowDuration }
            UbuntuNumberAnimation { target: fadeInScreenshotImage; property: "opacity"; to: 1; duration: UbuntuAnimation.SlowDuration }
            UbuntuNumberAnimation { target: fadeInScreenshotImage; property: "scale"; to: 1; duration: UbuntuAnimation.SlowDuration }
        }

        // restore stuff
        PropertyAction { target: fadeInScreenshotImage; property: "visible"; value: false }
        PropertyAction { target: mainScreenshotImage; property: "visible"; value: false }
    }

    // FIXME: Drop this and make the imageprovider show a splashscreen instead
    Rectangle {
        id: appSplash
        anchors.fill: parent
        color: "white"
        visible: priv.secondApplicationStarting
    }
    Image {
        id: fadeInScreenshotImage
        anchors { left: parent.left; bottom: parent.bottom }
        width: parent.width
        scale: .7
        visible: false
//        Rectangle { anchors.fill: mainScreenshotImage; color: "green"; opacity: .5 }
    }

    Rectangle {
        id: appSplash2
        anchors.fill: parent
        color: "red"
        visible: priv.applicationStarting
    }
    Image {
        id: mainScreenshotImage
        anchors { left: parent.left; bottom: parent.bottom }
        width: parent.width

        property string src
        source: src
        visible: false

        onVisibleChanged: {
            print("------------------------ image visible", visible)
        }

        onSrcChanged: {
            print("*** Main image source changed", src, "visible:", visible)
        }

        onStatusChanged: {
            print("*** Main image status changed", status, source)
        }
    }
//    Rectangle { anchors.fill: mainScreenshotImage; color: "blue"; opacity: .5 }

    Image {
        anchors { top: parent.top; right: parent.right }
        height: parent.height / 4
        width: parent.width / 4
        source: ApplicationManager.findApplication(priv.focusedAppId).screenshot
    }
    Image {
        anchors { bottom: parent.bottom; right: parent.right }
        height: parent.height / 4
        width: parent.width / 4
        source: mainScreenshotImage.src
    }
}
