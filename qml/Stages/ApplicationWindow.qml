/*
 * Copyright 2014-2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Unity.Application 0.1

FocusScope {
    id: root
    implicitWidth: sessionContainer.implicitWidth
    implicitHeight: sessionContainer.implicitHeight

    // to be read from outside
    readonly property bool fullscreen: application ? application.fullscreen : false
    property alias interactive: sessionContainer.interactive
    property bool orientationChangesEnabled: d.supportsSurfaceResize ? d.surfaceOldEnoughToBeResized : true

    // to be set from outside
    property QtObject application
    property int surfaceOrientationAngle
    property alias resizeSurface: sessionContainer.resizeSurface

    QtObject {
        id: d

        // helpers so that we don't have to check for the existence of an application everywhere
        // (in order to avoid breaking qml binding due to a javascript exception)
        readonly property string name: root.application ? root.application.name : ""
        readonly property url icon: root.application ? root.application.icon : ""
        readonly property int applicationState: root.application ? root.application.state : -1
        readonly property string splashTitle: root.application ? root.application.splashTitle : ""
        readonly property url splashImage: root.application ? root.application.splashImage : ""
        readonly property bool splashShowHeader: root.application ? root.application.splashShowHeader : true
        readonly property color splashColor: root.application ? root.application.splashColor : "#00000000"
        readonly property color splashColorHeader: root.application ? root.application.splashColorHeader : "#00000000"
        readonly property color splashColorFooter: root.application ? root.application.splashColorFooter : "#00000000"
        readonly property url defaultScreenshot: (root.application && root.application.defaultScreenshot !== undefined) ? root.application.defaultScreenshot : ""

        // Whether the Application had a surface before but lost it.
        property bool hadSurface: sessionContainer.surfaceContainer.hadSurface

        property bool needToTakeScreenshot:
            ((sessionContainer.surface && d.surfaceInitialized) || d.hadSurface)
            && screenshotImage.status === Image.Null
            && d.applicationState === ApplicationInfoInterface.Stopped
        onNeedToTakeScreenshotChanged: {
            if (needToTakeScreenshot) {
                screenshotImage.take();
            }
        }

        //FIXME - this is a hack to avoid the first few rendered frames as they
        // might show the UI accommodating due to surface resizes on startup.
        // Remove this when possible
        property bool surfaceInitialized: false

        property bool supportsSurfaceResize:
                application &&
                ((application.supportedOrientations & Qt.PortraitOrientation)
                  || (application.supportedOrientations & Qt.InvertedPortraitOrientation))
                &&
                ((application.supportedOrientations & Qt.LandscapeOrientation)
                 || (application.supportedOrientations & Qt.InvertedLandscapeOrientation))

        property bool surfaceOldEnoughToBeResized: false
    }

    Timer {
        id: surfaceInitTimer
        interval: 100
        onTriggered: { if (sessionContainer.surface) {d.surfaceInitialized = true;} }
    }

    Timer {
        id: surfaceIsOldTimer
        interval: 1000
        onTriggered: { if (stateGroup.state === "surface") { d.surfaceOldEnoughToBeResized = true; } }
    }

    Image {
        id: screenshotImage
        objectName: "screenshotImage"
        source: d.defaultScreenshot
        anchors.fill: parent
        antialiasing: !root.interactive

        function take() {
            // Save memory by using a half-resolution (thus quarter size) screenshot.
            // Do not make this a binding, we can only take the screenshot once!
            sourceSize.width = root.width / 2;
            sourceSize.height = root.height / 2;

            // Format: "image://application/$APP_ID/$CURRENT_TIME_MS"
            // eg: "image://application/calculator-app/123456"
            var timeMs = new Date().getTime();
            source = "image://application/" + root.application.appId + "/" + timeMs;
        }
    }

    Loader {
        id: splashLoader
        visible: active
        active: false
        anchors.fill: parent
        sourceComponent: Component {
            Splash {
                id: splash
                title: d.splashTitle ? d.splashTitle : d.name
                imageSource: d.splashImage
                icon: d.icon
                showHeader: d.splashShowHeader
                backgroundColor: d.splashColor
                headerColor: d.splashColorHeader
                footerColor: d.splashColorFooter
            }
        }
    }

    SessionContainer {
        id: sessionContainer
        // A fake application might not even have a session property.
        session: application && application.session ? application.session : null
        anchors.fill: parent

        surfaceOrientationAngle: application && application.rotatesWindowContents ? root.surfaceOrientationAngle : 0

        onSurfaceChanged: {
            if (sessionContainer.surface) {
                surfaceInitTimer.start();
            } else {
                d.surfaceInitialized = false;
            }
        }

        focus: true
    }

    StateGroup {
        id: stateGroup
        objectName: "applicationWindowStateGroup"
        states: [
            State {
                name: "void"
                when:
                     d.hadSurface && (!sessionContainer.surface || !d.surfaceInitialized)
                     &&
                     screenshotImage.status !== Image.Ready
            },
            State {
                name: "splashScreen"
                when:
                     !d.hadSurface && (!sessionContainer.surface || !d.surfaceInitialized)
                     &&
                     screenshotImage.status !== Image.Ready
            },
            State {
                name: "surface"
                when:
                      (sessionContainer.surface && d.surfaceInitialized)
                      &&
                      (d.applicationState !== ApplicationInfoInterface.Stopped
                       || screenshotImage.status !== Image.Ready)
            },
            State {
                name: "screenshot"
                when:
                      screenshotImage.status === Image.Ready
                      &&
                      (d.applicationState === ApplicationInfoInterface.Stopped
                       || !sessionContainer.surface || !d.surfaceInitialized)
            }
        ]

        transitions: [
            Transition {
                from: ""; to: "splashScreen"
                PropertyAction { target: splashLoader; property: "active"; value: true }
                PropertyAction { target: sessionContainer.surfaceContainer
                                 property: "visible"; value: false }
            },
            Transition {
                from: "splashScreen"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: sessionContainer.surfaceContainer
                                     property: "opacity"; value: 0.0 }
                    PropertyAction { target: sessionContainer.surfaceContainer
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: sessionContainer.surfaceContainer; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    ScriptAction { script: {
                        splashLoader.active = false;
                        surfaceIsOldTimer.start();
                    } }
                }
            },
            Transition {
                from: "surface"; to: "splashScreen"
                SequentialAnimation {
                    ScriptAction { script: {
                        surfaceIsOldTimer.stop();
                        d.surfaceOldEnoughToBeResized = false;
                        splashLoader.active = true;
                        sessionContainer.surfaceContainer.visible = true;
                    } }
                    UbuntuNumberAnimation { target: splashLoader; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    PropertyAction { target: sessionContainer.surfaceContainer
                                     property: "visible"; value: false }
                }
            },
            Transition {
                from: "surface"; to: "screenshot"
                SequentialAnimation {
                    ScriptAction { script: {
                        surfaceIsOldTimer.stop();
                        d.surfaceOldEnoughToBeResized = false;
                        screenshotImage.visible = true;
                    } }
                    UbuntuNumberAnimation { target: screenshotImage; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    ScriptAction { script: {
                        sessionContainer.surfaceContainer.visible = false;
                        if (sessionContainer.session) { sessionContainer.session.release(); }
                    } }
                }
            },
            Transition {
                from: "screenshot"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: sessionContainer.surfaceContainer
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: screenshotImage; property: "opacity";
                                            from: 1.0; to: 0.0
                                            duration: UbuntuAnimation.BriskDuration }
                    ScriptAction { script: {
                        screenshotImage.visible = false;
                        screenshotImage.source = "";
                        surfaceIsOldTimer.start();
                    } }
                }
            },
            Transition {
                from: "splashScreen"; to: "screenshot"
                SequentialAnimation {
                    PropertyAction { target: screenshotImage
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: screenshotImage; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    PropertyAction { target: splashLoader; property: "active"; value: false }
                }
            },
            Transition {
                from: "surface"; to: "void"
                ScriptAction { script: {
                    surfaceIsOldTimer.stop();
                    d.surfaceOldEnoughToBeResized = false;
                    sessionContainer.surfaceContainer.visible = false;
                    if (sessionContainer.session) { sessionContainer.session.release(); }
                } }
            },
            Transition {
                from: "void"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: sessionContainer.surfaceContainer; property: "opacity"; value: 0.0 }
                    PropertyAction { target: sessionContainer.surfaceContainer; property: "visible"; value: true }
                    UbuntuNumberAnimation { target: sessionContainer.surfaceContainer; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    ScriptAction { script: {
                        surfaceIsOldTimer.start();
                    } }
                }
            }
        ]
    }

}
