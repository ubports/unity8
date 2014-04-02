/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
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
                               || (priv.mainStageAppId.length == 0 && sideStageSnapAnimation.running)

    readonly property int overlayWidth: priv.overlayOverride ? 0 : priv.sideStageWidth

    onShownChanged: {
        if (!shown) {
            priv.mainStageAppId = "";
        }
    }

    onMovingChanged: {
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

        property string startingAppId: ""

        // Keep overlayMode even if there is no focused app (to allow pulling in the sidestage from the right)
        property bool overlayOverride: false

        onFocusedApplicationChanged: {
            if (focusedApplication) {
                if (focusedApplication.stage == ApplicationInfoInterface.MainStage) {
                    mainStageAppId = focusedApplicationId;
                    priv.overlayOverride = false;
                    if (priv.startingAppId == focusedApplicationId && sideStageImage.shown) {
                        // There was already a sidestage app on top. bring it back!
                        ApplicationManager.focusApplication(priv.sideStageAppId)
                        priv.startingAppId = "";
                    }
                } else if (focusedApplication.stage == ApplicationInfoInterface.SideStage) {
                    sideStageAppId = focusedApplicationId;
                    if (priv.startingAppId == focusedApplicationId && !sideStageImage.shown) {
                        sideStageImage.snapToApp(focusedApplication);
                        priv.startingAppId = "";
                    }
                }
            } else if (root.overlayMode){
                sideStageImage.snapTo(root.width)
            }
        }

        onMainStageScreenshotChanged: {
            waitingForMainScreenshot = false;
        }

        onSideStageScreenshotChanged: {
            waitingForSideScreenshot = false;
        }

        onFocusedScreenshotChanged: {
            waitingForSideScreenshot = false;
        }

        onWaitingForScreenshotsChanged: {
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
                    sideStageImage.visible = true;
                }
            }
            if (sideStageHandleMouseArea.pressed) {
                if (sideStageAppId) {
                    sideStageImage.application = sideStageApp;
                    sideStageImage.x = root.width - sideStageImage.width
                    sideStageImage.visible = true;
                }
                if (mainStageAppId) {
                    mainStageImage.application = mainStageApp
                    mainStageImage.visible = true;
                }
            }
        }

        function requestNewScreenshot(stage) {
            if (stage == ApplicationInfoInterface.MainStage && mainStageAppId) {
                waitingForMainScreenshot = true;
                ApplicationManager.updateScreenshot(mainStageAppId);
            } else if (stage == ApplicationInfoInterface.SideStage && sideStageAppId) {
                waitingForSideScreenshot = true;
                ApplicationManager.updateScreenshot(sideStageAppId);
            }
        }

    }
    // FIXME: the signal connection seems to get lost with the fake application manager.
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

        onApplicationAdded: {
            priv.startingAppId = appId;
            splashScreenTimer.start();
            var application = ApplicationManager.findApplication(appId)
            if (application.stage == ApplicationInfoInterface.SideStage) {
                sideStageSplash.visible = true;
            } else if (application.stage == ApplicationInfoInterface.MainStage) {
                mainStageSplash.visible = true;
            }
        }

        onFocusRequested: {
            var application = ApplicationManager.findApplication(appId)
            if (application.stage == ApplicationInfoInterface.SideStage) {
                if (!root.shown) {
                    priv.mainStageAppId = "";
                    mainStageImage.application = null
                }
                if (sideStageImage.shown) {
                    sideStageImage.switchTo(application);
                    if (priv.mainStageAppId) {
                        mainStageImage.application = priv.mainStageApp;
                        mainStageImage.visible = true;
                    }
                } else {
                    sideStageImage.application = application;
                    sideStageImage.snapToApp(application);
                }
            } else if (application.stage == ApplicationInfoInterface.MainStage) {
                if (root.shown) {
                    if (sideStageImage.shown) {
                        sideStageImage.application = priv.sideStageApp;
                        sideStageImage.visible = true;
                    }
                    priv.mainStageAppId = application.appId;
                    mainStageImage.switchTo(application)
                    ApplicationManager.focusApplication(appId)
                    if (sideStageImage.shown) {
                        // There was already a focused SS app. Bring it back
                        ApplicationManager.focusApplication(priv.sideStageAppId)
                    }
                } else {
                    if (sideStageImage.shown) {
                        sideStageImage.visible = false;
                        sideStageImage.x = root.width;
                    }

                    mainStageImage.application = application;
                    ApplicationManager.focusApplication(appId)
                }
            }
        }

        onApplicationRemoved: {
            if (priv.mainStageAppId == appId) {
                priv.mainStageAppId = "";
            }
            if (priv.sideStageAppId == appId) {
                priv.sideStageAppId = "";
            }
            if (priv.sideStageAppId.length == 0) {
                sideStageImage.shown = false;
                priv.overlayOverride = false;
            }
        }

    }

    Timer {
        id: splashScreenTimer
        // FIXME: apart from removing this completely in the future and make the app surface paint
        // meaningful stuff, also check for colin's stuff to land so we can shape 1.4 secs away from here
        // https://code.launchpad.net/~cjwatson/upstart-app-launch/libclick-manifest/+merge/210520
        // https://code.launchpad.net/~cjwatson/upstart-app-launch/libclick-pkgdir/+merge/209909
        interval: 1700
        repeat: false
        onTriggered: {
            mainStageSplash.visible = false;
            sideStageSplash.visible = false;
        }
    }

    SwitchingApplicationImage {
        id: mainStageImage
        anchors.bottom: parent.bottom
        width: parent.width
        visible: false

        onSwitched: {
            sideStageImage.visible = false;
        }
    }

    Rectangle {
        id: mainStageSplash
        anchors.fill: root
        anchors.rightMargin: root.width - sideStageImage.x
        color: "white"
    }

    SidestageHandle {
        id: sideStageHandle
        anchors { top: parent.top; right: sideStageImage.left; bottom: parent.bottom }
        width: root.dragAreaWidth
        visible: root.shown && priv.sideStageAppId && sideStageImage.x < root.width

    }
    MouseArea {
        id: sideStageHandleMouseArea
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom; rightMargin: sideStageImage.shown ? sideStageImage.width : 0}
        width: root.dragAreaWidth
        visible: priv.sideStageAppId

        property var dragPoints: new Array()

        onPressed: {
            priv.requestNewScreenshot(ApplicationInfoInterface.SideStage)
            if (priv.mainStageAppId) {
                priv.requestNewScreenshot(ApplicationInfoInterface.MainStage)
            }
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
                sideStageImage.snapToApp(priv.sideStageApp)
            }
        }
    }

    SwitchingApplicationImage {
        id: sideStageImage
        width: priv.sideStageWidth
        height: root.height
        x: root.width
        anchors.bottom: parent.bottom
        visible: true
        property bool shown: false

        onSwitched: {
            mainStageImage.visible = false;
            ApplicationManager.focusApplication(application.appId)
        }

        function snapTo(targetX) {
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

            UbuntuNumberAnimation { target: sideStageImage; property: "x"; to: sideStageSnapAnimation.targetX; duration: UbuntuAnimation.SlowDuration }
            ScriptAction {
                script: {
                    if (sideStageSnapAnimation.targetX == root.width) {
                        if (priv.mainStageAppId) {
                            ApplicationManager.focusApplication(priv.mainStageAppId)
                        } else {
                            priv.overlayOverride = true;
                            ApplicationManager.unfocusCurrentApplication();
                        }
                        sideStageImage.shown = false;
                    }
                    if (sideStageSnapAnimation.snapToId) {
                        ApplicationManager.focusApplication(sideStageSnapAnimation.snapToId)
                        sideStageSnapAnimation.snapToId = "";
                        sideStageImage.shown = true;
                        priv.overlayOverride = false;
                    }
                    sideStageImage.visible = false;
                    mainStageImage.visible = false;
                }
            }
        }
    }

    Rectangle {
        id: sideStageSplash
        anchors.fill: parent
        anchors.leftMargin: sideStageImage.x
        color: "white"
    }
}
