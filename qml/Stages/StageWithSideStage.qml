import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
import "../SideStage"
import Unity.Application 0.1
import Ubuntu.Gestures 0.1

Item {
    id: root
    objectName: "stages"
    anchors.fill: parent

    // Controls to be set from outside
    property bool shown: false
    property bool moving: false
    property int dragAreaWidth

    // State information propagated to the outside
    readonly property bool painting: mainStageImage.visible || sideStageImage.visible || sideStageSnapAnimation.running
    property bool fullscreen: priv.focusedApplication ? priv.focusedApplication.fullscreen : false
    property bool overlayMode: (sideStageImage.shown && priv.mainStageAppId.length == 0) || priv.overlayOverride

    readonly property int overlayWidth: priv.overlayOverride ? 0 : priv.sideStageWidth

    onPaintingChanged: print(":::::::::::::::::::::::::::::::: painting changed:", painting, "overlayMode:", overlayMode)
    onOverlayModeChanged: print(";;;;;;;;;;;;;;;;;;;;;;;;;; overlayModeChanged:", overlayWidth)

    onShownChanged: {
//        print("shown", shown)
        if (!shown) {
            priv.mainStageAppId = "";
        }
    }

    onMovingChanged: {
//        print("moving", moving, priv.haveMainStageApp, priv.haveSideStageApp)
        if (moving) {
            if (!priv.mainStageAppId && !priv.sideStageAppId) {
                // Pulling in from the right, make the last used (topmost) app visible
                var application = ApplicationManager.get(0);
                if (application.stage == ApplicationInfoInterface.SideStage) {
                    sideStageImage.application = application;
                    sideStageImage.x = root.width - sideStageImage.width
                    sideStageImage.visible = true;
                } else {
                    mainStageImage.application = application;
                    mainStageImage.visible = true;
                }
            } else {
                priv.requestNewScreenshot(ApplicationInfoInterface.MainStage)
                if (priv.focusedApplicationId == priv.sideStageAppId) {
                    priv.requestNewScreenshot(ApplicationInfoInterface.SideStage)
                }
            }
        } else {
            mainStageImage.visible = false;
            sideStageImage.visible = false;
        }
    }

//    Rectangle { anchors.fill: parent; color: "blue"; opacity: 0.5 }

    QtObject {
        id: priv

        property int sideStageWidth: units.gu(40)


        property string sideStageAppId
        property string mainStageAppId


        property var sideStageApp: ApplicationManager.findApplication(sideStageAppId)
        property var mainStageApp: ApplicationManager.findApplication(mainStageAppId)

        property string sideStageScreenshot: sideStageApp ? sideStageApp.screenshot : ""
        property string mainStageScreenshot: mainStageApp ? mainStageApp.screenshot : ""

        property string focusedApplicationId: ApplicationManager.focusedApplicationId
        property var focusedApplication: ApplicationManager.findApplication(focusedApplicationId)
        property url focusedScreenshot: focusedApplication ? focusedApplication.screenshot : ""

        property bool waitingForMainScreenshot: false
        property bool waitingForSideScreenshot: false
        property bool waitingForScreenshots: waitingForMainScreenshot || waitingForSideScreenshot


        // Keep overlayMode even if there is no focused app (to allow pulling in the sidestage from the right)
        property bool overlayOverride: false

        onFocusedApplicationChanged: {
            if (focusedApplication) {
                if (focusedApplication.stage == ApplicationInfoInterface.MainStage) {
                    mainStageAppId = focusedApplicationId;
                } else if (focusedApplication.stage == ApplicationInfoInterface.SideStage) {
                    sideStageAppId = focusedApplicationId;
                }
            }
        }

        onMainStageScreenshotChanged: {
            print("------------------------------------------0")
            waitingForMainScreenshot = false;
        }

        onSideStageScreenshotChanged: {
            print("------------------------------------------1")
            waitingForSideScreenshot = false;
        }

        onFocusedScreenshotChanged: {
            print("##########################################", root.overlayMode)
            waitingForSideScreenshot = false;
        }

        onWaitingForScreenshotsChanged: {
            print("********************++ waitingForScreenshotsChanged:", waitingForScreenshots);
            if (waitingForScreenshots) {
                return;
            }

            if (root.moving) {
                if (mainStageAppId) {
                    mainStageImage.application = mainStageApp
                    mainStageImage.visible = true;
                }
                if (sideStageAppId && focusedApplicationId == sideStageAppId) {
                    sideStageImage.application = sideStageApp;
                    sideStageImage.x = root.width - sideStageImage.width
                    print("setting side stage screenshot visiblr")
                    sideStageImage.visible = true;
                }
            }
            if (sideStageHandleMouseArea.pressed) {
                if (sideStageAppId) {
                    print("setting side stage screenshot to", sideStageAppId)
                    sideStageImage.application = sideStageApp;
                    sideStageImage.x = root.width - sideStageImage.width
                    print("setting side stage screenshot visiblr")
                    sideStageImage.visible = true;
                }
                if (mainStageAppId) {
                    mainStageImage.application = mainStageApp
                    mainStageImage.visible = true;
                }
            }
        }

        function requestNewScreenshot(stage) {
            print("** requestNewScreenshot called for stage", stage, mainStageAppId, sideStageAppId)
            if (stage == ApplicationInfoInterface.MainStage && mainStageAppId) {
                print("requesting new MainStage screenshot")
                waitingForMainScreenshot = true;
                ApplicationManager.updateScreenshot(mainStageAppId);
            } else if (stage == ApplicationInfoInterface.SideStage && sideStageAppId) {
                print("requesting new SideStage screenshot")
                waitingForSideScreenshot = true;
                ApplicationManager.updateScreenshot(sideStageAppId);
            }
        }

    }
    // FIXME: the signal connection seems to get lost with the fake application manager.
    // Check with Qt 5.2, see if we can remove this Connections object
    Connections {
        target: priv.sideStageApp
        onScreenshotChanged: priv.sideStageScreenshot = priv.sideStageApp.screenshot
    }
    Connections {
        target: priv.mainStageApp
        onScreenshotChanged: priv.mainStageScreenshot = priv.mainStageApp.screenshot
    }

    Connections {
        target: ApplicationManager

//        onApplicationAdded: {
//            var application = ApplicationManager.findApplication(appId)
//            print("Application added:", appId, application.state)
//            if (application.stage == ApplicationInfoInterface.SideStage) {
//                priv.sideStageAppId = appId;
//                mainStageImage.switchTo(application)
//                mainStageImage.visible = true;
//            } else if (application.stage == ApplicationInfoInterface.MainStage) {
//                priv.mainStageAppId = appId;
//                sideStageImage.switchTo(application)
//                sideStageImage.visible = true;
//            }
//        }

        onFocusRequested: {
            print("focus requested by", appId)

            var application = ApplicationManager.findApplication(appId)
            if (application.stage == ApplicationInfoInterface.SideStage) {
                if (sideStageImage.shown) {
                    print("switching to:", appId)
                    sideStageImage.switchTo(application)
                    mainStageImage.visible = true;
                    ApplicationManager.focusApplication(appId)
                } else {
                    sideStageImage.application = application
                    sideStageImage.snapToApp(application)
                }
            } else if (application.stage == ApplicationInfoInterface.MainStage) {
                if (root.shown) {
                    priv.mainStageAppId = application.appId;
                    mainStageImage.switchTo(application)
                    if (sideStageImage.shown) {
                        sideStageImage.snapTo(root.width)
                    } else {
                        ApplicationManager.focusApplication(appId)
                    }
                } else {
                    ApplicationManager.focusApplication(appId)
                }
            }
            priv.overlayOverride = false;
        }

        onApplicationRemoved: {
            if (priv.mainStageAppId == appId) {
                priv.mainStageAppId = "";
            }
            if (priv.sideStageAppId == appId) {
                priv.sideStageAppId = "";
            }
        }

    }

    SwitchingApplicationImage {
        id: mainStageImage
        height: parent.height
        width: parent.width
        visible: false

        onSwitched: {
            sideStageImage.visible = false;
        }

//        Rectangle { anchors.fill: parent; color: "red"; opacity: 0.5 }
    }

    SidestageHandle {
        id: sideStageHandle
        anchors { top: parent.top; right: sideStageImage.left; bottom: parent.bottom }
        width: root.dragAreaWidth
        visible: root.shown && priv.sideStageAppId

    }
    MouseArea {
        id: sideStageHandleMouseArea
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom; rightMargin: sideStageImage.shown ? sideStageImage.width : 0}
        width: root.dragAreaWidth
        visible: priv.sideStageAppId

        property var dragPoints: new Array()

        onPressed: {
            print("sidestagehandle pressed. shown:", shown, "sidestageAppId:", priv.sideStageAppId)
            priv.requestNewScreenshot(ApplicationInfoInterface.SideStage)
        }

        onMouseXChanged: {
            dragPoints.push(mouseX)
            var dragPoint = root.width + mouseX;
            if (sideStageImage.shown) {
                dragPoint -= sideStageImage.width
            }
            sideStageImage.x = Math.max(root.width - sideStageImage.width, dragPoint)
        }

        onReleased: {
            var distance = 0;
            var lastX = dragPoints[0];
            var oneWayFlick = true;
            for (var i = 0; i < dragPoints.length; ++i) {
                if (dragPoints[i] < lastX) {
                    oneWayFlick = false;
                }
                distance += dragPoints[i] - lastX;
                lastX = dragPoints[i];
            }
            dragPoints = [];

            if (oneWayFlick || distance > sideStageImage.width / 2) {
                sideStageImage.snapTo(root.width)
            } else {
                print("should snap to:", priv.sideStageAppId)
                sideStageImage.snapToApp(priv.sideStageApp)
            }
        }
//        Rectangle { anchors.fill: parent; color: "purple"; opacity: .5 }
    }


    SwitchingApplicationImage {
        id: sideStageImage
        width: priv.sideStageWidth
//        height: root.height
        x: root.width - width
        anchors.bottom: parent.bottom
        visible: true
        property bool shown: false

//        Rectangle { anchors.fill: parent; color: "green"; opacity: 0.5 }

        onSwitched: {
            mainStageImage.visible = false;
        }

        function snapTo(targetX) {
            print("snapping to... app:", sideStageImage.application.appId)
            sideStageSnapAnimation.targetX = targetX
            sideStageImage.visible = true;
            if (priv.mainStageAppId) {
                mainStageImage.application = priv.mainStageApp
                mainStageImage.visible = true;
            }
            sideStageSnapAnimation.start();
        }

        function snapToApp(application) {
            sideStageImage.application = application
            sideStageSnapAnimation.snapToId = application.appId;
            snapTo(root.width - sideStageImage.width);
        }

        SequentialAnimation {
            id: sideStageSnapAnimation
            property int targetX: root.width
            property string snapToId

            onRunningChanged: print("sideStageSnapAnimation running changed:", running, sideStageImage.visible, mainStageImage.visible, root.painting, mainStageImage.visible || sideStageImage.visible || sideStageSnapAnimation.running)

            UbuntuNumberAnimation { target: sideStageImage; property: "x"; to: sideStageSnapAnimation.targetX; duration: UbuntuAnimation.SlowDuration }
            ScriptAction {
                script: {
                    if (sideStageSnapAnimation.targetX == root.width) {
                        if (priv.mainStageAppId) {
                            ApplicationManager.focusApplication(priv.mainStageAppId)
                        } else {
                            print("unfocusing current app")
                            priv.overlayOverride = true;
                            ApplicationManager.unfocusCurrentApplication();
                        }
                        sideStageImage.shown = false;
                    }
                    print("snapped sidestage to app", sideStageSnapAnimation.snapToId)
                    if (sideStageSnapAnimation.snapToId) {
                        print("focusing id", sideStageSnapAnimation.snapToId)
                        ApplicationManager.focusApplication(sideStageSnapAnimation.snapToId)
                        sideStageSnapAnimation.snapToId = "";
                        sideStageImage.shown = true;
                        priv.overlayOverride = false;
                    }
                    sideStageImage.visible = false;
                    mainStageImage.visible = false;
                    print("snapped sidestage", root.overlayMode, root.painting)
                }
            }
        }
    }
}
