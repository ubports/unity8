import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import Unity.Application 0.1
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
        id: coverFlipDragArea
        direction: Direction.Rightwards

        //enabled: root.available
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
        width: root.dragAreaWidth

        onTouchXChanged: {
//            print("touchX changed", touchX)
            coverFlip.progress = -(touchX - root.dragAreaWidth) / root.width
        }

        onDraggingChanged: {
            if (!dragging) {
                coverFlip.snap();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "green"
            opacity: .4
        }
    }

    Rectangle {
        id: coverFlipBackground
        anchors.fill: parent
        color: "black"
        visible: coverFlip.visible
    }

    InputFilterArea {
        anchors.fill: root
        blockInput: coverFlip.visible
    }
    MouseArea {
        anchors.fill: root
        enabled: coverFlip.visible
        property int oldMouseX
        property int startX

        property bool isDrag: false

        onPressed: {
            isDrag = false
            oldMouseX = mouseX
            startX = mouseX
        }

        onMouseXChanged: {
            var diff = (oldMouseX - mouseX) * .001;
            coverFlip.progress = Math.max(.8, coverFlip.progress + diff);
            oldMouseX = mouseX
            print("mousex changed", mouseX - startX)
            if (Math.abs(mouseX - startX) > units.gu(.5)) {
                isDrag = true;
            }
        }
        onClicked: {
            // From Qt docs:
            // "A click is defined as a press followed by a release, both inside the
            // MouseArea (pressing, moving outside the MouseArea, and then moving back
            // inside and releasing is also considered a click)."
            // This means, that pressing, moving the coverFlip around and then releasing
            // will still be threated as a click. Let's add our own logic to not activate
            // a tile if the user just wants to drag stuff around.
            if (isDrag) {
                return;
            }

            var index = Math.floor(mouseX / coverFlip.tileWidth)
            index = Math.min(tileRepeater.count - 1, index)
            print("clicked item", index)
            coverFlip.selectItem(index);
        }
    }

    Row {
        id: coverFlip
        height: parent.height
        x: 0
        visible: progress > 0

        property real progress: 0
        property int maxAngle: 45
        property real minScale: .6
        property bool animatingBack: false

        property real tileWidth: Math.max(units.gu(2), root.width - (coverFlip.progress * root.width))

//        onProgressChanged: print("CoverFlip progress changed", progress)
        onXChanged: print("coverflip x changed", x)

        function snap() {
            if (coverFlip.progress < 0.25) {
                snapAnimation.targetProgress = 0
            } else if (coverFlip.progress < 0.6) {
                snapAnimation.targetProgress = 0.5
            } else {
                snapAnimation.targetProgress = .8;
            }
            snapAnimation.start();
        }

        function selectItem(index) {
            tileRepeater.itemAt(index).select();
        }

        SequentialAnimation {
            id: snapAnimation
            property var targetProgress

            UbuntuNumberAnimation {
                target: coverFlip
                properties: "progress"
                to: snapAnimation.targetProgress
            }
            ScriptAction {
                script: {
                    if (snapAnimation.targetProgress == 0.5) {
                        ApplicationManager.focusApplication(ApplicationManager.get(1).appId);
                        coverFlip.progress = 0;
                    }
                }
            }
        }

        Repeater {
            id: tileRepeater
            model: ApplicationManager

            Item {
                height: parent.height
                width: coverFlip.tileWidth

                function select() {
                    switchToAppAnimation.start();
                }

                Image {
                    id: appImage
                    anchors { left: parent.left; bottom: parent.bottom }
                    width: root.width
                    source: ApplicationManager.get(index).screenshot
                    scale: 1

                    property real progress: coverFlip.progress

                    transform: [
                        Rotation {
                            origin { x: units.gu(5); y: height / 2 }
                            axis { x: 0; y: 1; z: 0 }
                            angle: {
                                var newAngle = 0;
                                if (coverFlip.animatingBack) {
                                    newAngle = Math.min(appImage.progress, .75) * coverFlip.maxAngle;
                                } else {
                                    switch (index) {
                                    case 0:
                                        if (appImage.progress < .5) {
                                            newAngle = appImage.progress * coverFlip.maxAngle;
                                        } else {
                                            newAngle = (appImage.progress - .5) * coverFlip.maxAngle * 2;
                                        }
                                        break;
                                    case 1:
                                        if (appImage.progress < .5) {
                                            newAngle = coverFlip.maxAngle - (appImage.progress * coverFlip.maxAngle * 2);
                                        } else {
                                            newAngle = (appImage.progress - .5) * coverFlip.maxAngle * 2;
                                        }
                                        break;
                                    default:
                                        newAngle = Math.min(appImage.progress, .75) * coverFlip.maxAngle;
                                    }
                                }
                                return Math.min(newAngle, coverFlip.maxAngle);
                            }
                        },
                        Translate {
                            x: {
                                if (coverFlip.animatingBack) {
                                    return 0;
                                }

                                switch (index) {
                                case 1:
                                    if (appImage.progress < .5) {
                                        return -root.width * appImage.progress;
                                    } else if (appImage.progress < .75) {
                                        // relation equation: x : width/2 = progress-.5 : 0.25
                                        return (-root.width * .5) + (root.width/2) * (appImage.progress - .5) / 0.25
                                    }
                                }
                                return 0;
                            }
                        },
                        Scale {
                            origin { x: 0; y: root.height / 2 }
                            xScale: {
                                var scale = 1;
                                // progress : 1 = x : root.width
                                var progress = root.width / (root.width - x)
                                if (appImage.progress > .5) {
                                    // relation equation: scale : (1-minScale) = progress-.5 : 0.5
                                    scale = 1 - (1 - coverFlip.minScale) * (appImage.progress - 0.5) / 0.5
                                }
                                scale = Math.max(coverFlip.minScale, scale);
                                return scale;
                            }
                            yScale: xScale
                        }
                    ]

                }

                SequentialAnimation {
                    id: switchToAppAnimation
                    PropertyAction { target: coverFlip; property: "animatingBack"; value: true }
                    ParallelAnimation {
                        UbuntuNumberAnimation { target: coverFlip; property: "progress"; to: 0 }
                        UbuntuNumberAnimation { target: coverFlip; property: "x"; to: -root.width * index }
                    }
                    ScriptAction {
                        script: {
                            ApplicationManager.focusApplication(ApplicationManager.get(index).appId);
                            coverFlip.progress = 0;
                            coverFlip.x = 0;
                            coverFlip.animatingBack = false;
                            appImage.x = 0;
                        }
                    }
                }
            }
        }
    }
}
