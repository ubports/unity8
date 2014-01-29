import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import Unity.Application 0.1
import Utils 0.1
import "../Components"

/*

*/

Item {
    id: root

    // Controls to be set from outside
    property bool shown: false
    property bool moving: false
    property int dragAreaWidth

    // State information propagated to the outside
    readonly property bool painting: mainScreenshotImage.visible || fadeInScreenshotImage.visible || appSplash.visible
    onPaintingChanged: print("**********************+ painting changed", painting)

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
            priv.switchToApp(appId);
        }

        onFocusedApplicationIdChanged: {
            if (ApplicationManager.focusedApplicationId.length > 0) {
                if (priv.secondApplicationStarting || priv.applicationStarting) {
                    appSplashTimer.start();
                } else {
                    mainScreenshotImage.src = ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).screenshot
                }
            }
        }

        onApplicationAdded: {
            if (!priv.focusedApplication) {
                mainScreenshotImage.src = "";
                mainScreenshotImage.visible = false;
                priv.applicationStarting = true;
            } else {
                mainScreenshotImage.src = "foobar";
                priv.newFocusedAppId = appId;
                priv.secondApplicationStarting = true;
                priv.requestNewScreenshot();
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

        property string newFocusedAppId

        onFocusedScreenshotChanged: {
            if (root.moving && priv.waitingForScreenshot) {
                mainScreenshotImage.anchors.leftMargin = 0;
                mainScreenshotImage.src = ApplicationManager.findApplication(ApplicationManager.focusedApplicationId).screenshot;
                mainScreenshotImage.visible = true;
            } else if (priv.secondApplicationStarting && priv.waitingForScreenshot) {
                applicationSwitchingAnimation.start();
            }
            waitingForScreenshot = false;
        }

        function requestNewScreenshot() {
            waitingForScreenshot = true;
            ApplicationManager.updateScreenshot(ApplicationManager.focusedApplicationId);
        }

        function switchToApp(appId) {
            priv.newFocusedAppId = appId;
            applicationSwitchingAnimation.start();
            grantFocusTimer.start();
        }

    }

    // FIXME: the signal connection seems to get lost with the fake application manager.
    // Check with Qt 5.2, see if we can remove this Connections object
    Connections {
        target: priv.focusedApplication
        onScreenshotChanged: priv.focusedScreenshot = priv.focusedApplication.screenshot
    }

    Timer {
        id: grantFocusTimer
        // Delay the actual switch to be covered by the animation for sure.
        // 1) If we switch before starting the animation, the Mir event loop paints before the Qt event loop => flickering
        // 2) If we do the switch after the animation, the panel wouldn't fade in early enough.
        interval: UbuntuAnimation.SlowDuration / 4
        repeat: false
        onTriggered: {
            ApplicationManager.focusApplication(priv.newFocusedAppId);
        }
    }

    Timer {
        id: appSplashTimer
        // This is to show the splash screen a bit longer.
        // Mir signals us that the newly started app has gotten focus before it paints something on the screen
        // This would result in the old app surface becoming visible for a bit.
        // FIXME: change appManager to only change the focusedApplicationId when the surface is ready to be shown.
        interval: 1500
        repeat: false
        onTriggered: {
            priv.applicationStarting = false;
            priv.secondApplicationStarting = false;
        }
    }

    SequentialAnimation {
        id: applicationSwitchingAnimation
        // setup
        PropertyAction { target: mainScreenshotImage; property: "anchors.leftMargin"; value: 0 }
        // PropertyAction seems to fail when secondApplicationStarting and we didn't have another screenshot before
        ScriptAction { script: mainScreenshotImage.src = priv.focusedScreenshot }
        PropertyAction { target: mainScreenshotImage; property: "visible"; value: true }
        PropertyAction { target: fadeInScreenshotImage; property: "source"; value: ApplicationManager.findApplication(priv.newFocusedAppId).screenshot }
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
        id: appSplash2
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
    }

    Rectangle {
        id: appSplash
        anchors.fill: parent
        color: "white"
        visible: priv.applicationStarting
    }
    Image {
        id: mainScreenshotImage
        anchors { left: parent.left; bottom: parent.bottom }
        width: parent.width

        property string src
        source: src
        visible: false
    }

    EdgeDragArea {
        id: spreadDragArea
        direction: Direction.Leftwards

        //enabled: root.available
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

        property bool attachedToView: true

        onTouchXChanged: {
            if (!dragging && !priv.waitingForScreenshot) {
                priv.requestNewScreenshot();
                spreadView.stage = 0;
                attachedToView = true;
            }
            if (dragging && !priv.waitingForScreenshot && attachedToView) {
                spreadView.contentX = -touchX
            }
            if (attachedToView && spreadView.contentX >= spreadView.width * spreadView.positionMarker3) {
                attachedToView = false;
                spreadView.snap();
            }
        }

        onDraggingChanged: {
            print("Dragging changed", dragging)
            if (!dragging && attachedToView) {
                spreadView.snap();
            }
        }
    }

    Rectangle {
        id: coverFlipBackground
        anchors.fill: parent
        color: "black"
        visible: spreadView.visible
    }

    InputFilterArea {
        anchors.fill: root
        blockInput: spreadView.visible
    }

    Flickable {
        id: spreadView
        anchors.fill: parent
        visible: contentX > 0
        contentWidth: spreadRow.width

        property int tileDistance: width / 4

        property real positionMarker1: 0.35
        property real positionMarker2: 0.45
        property real positionMarker3: 0.6
        property real positionMarker4: .9

        // This is where the first app snaps to when bringing it in to the right.
        property real snapPosition: 0.75

        // Stage of the animation:
        // 0: Starting from right edge, a new app (index 1) comes in from the right
        // 1: The app has reached the first snap position.
        // 2: The list is dragged further and snaps into the spread view when entering stage 2
        property int stage: 0

        onStageChanged: print("*******stage cahnged", stage)

        onContentXChanged: {
            switch (stage) {
            case 0:
                if (contentX > width * positionMarker2) {
                    stage = 1;
                }
                break;
            case 1:
                if (contentX < width * positionMarker2) {
                    stage = 0;
                } else if (contentX >= width * positionMarker4) {
                    stage = 2;
                }
            }
        }

        function snap() {
            if (contentX < positionMarker1 * width) {
                snapAnimation.targetContentX = 0;
                snapAnimation.start();
            } else if (contentX < positionMarker2 * width) {
                snapTo(1)
            } else if (contentX < positionMarker3 * width) {
                print("snappoing to stage1")
                snapAnimation.targetContentX = width * positionMarker2 + 1;
                snapAnimation.start();
            } else if (stage < 2){
                print("snappoing to stage2")
                snapAnimation.targetContentX = width * positionMarker4;
                snapAnimation.start();
            }
        }
        function snapTo(index) {
            snapAnimation.targetContentX = width * positionMarker2;
            snapAnimation.toIndex = index;
            snapAnimation.start();
        }

        SequentialAnimation {
            id: snapAnimation
            property int targetContentX: 0
            property int toIndex: -1

            UbuntuNumberAnimation {
                target: spreadView
                property: "contentX"
                to: snapAnimation.targetContentX
                duration: UbuntuAnimation.FastDuration
            }
            ScriptAction {
                script: {
                    print("animation finished: stage", spreadView.stage, "contentX", spreadView.contentX, "focused app", ApplicationManager.get(0).appId, ApplicationManager.get(1).appId)
                    if (snapAnimation.toIndex >= 0) {
                        print("switching to app", snapAnimation.toIndex, ApplicationManager.get(snapAnimation.toIndex).name)
                        ApplicationManager.focusApplication(ApplicationManager.get(snapAnimation.toIndex).appId);
                        snapAnimation.toIndex = -1;
                        spreadView.contentX = 0;
                    }
                    if (spreadView.contentX == spreadView.width * spreadView.positionMarker2) {
                        spreadView.stage = 0;
                        spreadView.contentX = 0;
                    }
                    print("snapping done. stage:", spreadView.stage)
                }
            }
        }


        Item {
            id: spreadRow
            width: ApplicationManager.count * spreadView.tileDistance + (spreadView.width - spreadView.tileDistance) * 1.5 //(spreadView.width * spreadView.positionMarker2) + (spreadView.width - spreadView.tileDistance)

            x: spreadView.contentX

            Repeater {
                model: ApplicationManager
                delegate: TransformedSpreadDelegate {
                    startAngle: 45
                    endAngle: 10
                    startScale: 1
                    endScale: 0.7
                    startDistance: spreadView.tileDistance
                    endDistance: units.gu(.5)
                    height: spreadView.height

                    z: index
                    x: index == 0 ? 0 : spreadView.width + (index - 1) * spreadView.tileDistance

                    width: {
                        switch (index) {
                        case 0:
                            return spreadView.width;
                        case 1:
                            if (spreadView.stage == 0) {
                                return spreadView.width * spreadView.positionMarker2;
                            }
                        default:
                            return spreadView.tileDistance;
                        }
                    }

                    progress: {
                        switch (index) {
                        case 0:
                            return spreadView.contentX / spreadView.width;
                        case 1:
                            var progress = spreadView.contentX / spreadView.width;
                            if (spreadView.stage == 2) {
                                progress -= spreadView.tileDistance / spreadView.width;
                            }
                            return Math.max(0, progress);
                        }
                        // This delays the progress for all tiles > 1 for the duration of stage 1
                        var stage1Distance = spreadView.positionMarker2 * spreadView.width;
                        var tileDistance = (index - 2) * spreadView.tileDistance;
                        return (spreadView.contentX - stage1Distance - tileDistance) / spreadView.width;
                    }

                    animatedProgress: {
                        if (spreadView.stage < 2 && index < 2) {
                            if (spreadView.contentX < spreadView.width * spreadView.positionMarker1) {
                                return spreadView.contentX / spreadView.width
                            } else if (spreadView.stage == 0){
                                return spreadView.positionMarker2
                            }
                        }
                        return progress;
                    }

                    onClicked: {
                        spreadView.snapTo(index);
                    }

                    // This timer is to decouple the application reordering with the enabling of the SmoothedAnimation
                    // If both are done in same event loop pass, the reordering would animate.
                    Connections {
                        target: spreadView
                        onStageChanged: {
                            if (spreadView.stage == 0) {
                                enableAnimationTimer.start();
                            } else {
                                stage1Animation.enabled = false;
                            }
                        }
                    }
                    Timer {
                        id: enableAnimationTimer
                        interval: 1
                        onTriggered: {
                            stage1Animation.enabled = true;
                        }
                    }

                    Behavior on animatedProgress {
                        id: stage1Animation
                        SequentialAnimation {
                            SmoothedAnimation {
                                velocity: 2;
                                duration: UbuntuAnimation.BriskDuration;
                                easing: UbuntuAnimation.StandardEasing
                            }
                        }
                    }
                }
            }
        }
    }
}
