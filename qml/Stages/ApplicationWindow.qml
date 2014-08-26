/*
 * Copyright 2014 Canonical Ltd.
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

SessionContainer {
    id: root

    // to be read from outside
    readonly property bool fullscreen: application ? application.fullscreen : false

    // to be set from outside
    property QtObject application
    session: application ? application.session : null

    QtObject {
        id: d

        // helpers so that we don't have to check for the existence of an application everywhere
        // (in order to avoid breaking qml binding due to a javascript exception)
        readonly property string name: root.application ? root.application.name : ""
        readonly property url icon: root.application ? root.application.icon : ""
        readonly property int applicationState: root.application ? root.application.state : -1

        // Whether the Application had a surface before but lost it.
        property bool hadSurface: false

        property bool needToTakeScreenshot:
            root.surface && d.surfaceInitialized && screenshotImage.status === Image.Null
            && d.applicationState === ApplicationInfo.Stopped
        onNeedToTakeScreenshotChanged: {
            if (needToTakeScreenshot) {
                screenshotImage.take();
            }
        }

        //FIXME - this is a hack to avoid the first few rendered frames as they
        // might show the UI accommodating due to surface resizes on startup.
        // Remove this when possible
        property bool surfaceInitialized: false
    }
    onSurfaceChanged: {
        if (root.surface) {
            surfaceInitTimer.start();
        } else {
            d.hadSurface = true;
            d.surfaceInitialized = false;
        }
    }

    Timer {
        id: surfaceInitTimer
        interval: 100
        onTriggered: { if (root.surface) {d.surfaceInitialized = true;} }
    }

    Connections {
        target: root.surface
        // FIXME: I would rather not need to do this, but currently it doesn't get
        // active focus without it and I don't know why.
        onFocusChanged: forceSurfaceActiveFocusIfReady();
        onParentChanged: forceSurfaceActiveFocusIfReady();
        onEnabledChanged: forceSurfaceActiveFocusIfReady();
        function forceSurfaceActiveFocusIfReady() {
            if (root.surface.focus && root.surface.parent === surfaceContainer && root.surface.enabled) {
                root.surface.forceActiveFocus();
            }
        }
    }

    Image {
        id: screenshotImage
        objectName: "screenshotImage"
        source: ""
        anchors.fill: parent

        function take() {
            // Format: "image://application/$APP_ID/$CURRENT_TIME_MS"
            // eg: "image://application/calculator-app/123456"
            var timeMs = new Date().getTime();
            source = "image://application/" + root.application.appId + "/" + timeMs;
        }

        // Save memory by using a half-resolution (thus quarter size) screenshot
        sourceSize.width: root.width / 2
        sourceSize.height: root.height / 2
    }

    Loader {
        id: splashLoader
        visible: active
        active: false
        anchors.fill: parent
        sourceComponent: Component {
            Splash { name: d.name; image: d.icon }
        }
    }

    StateGroup {
        objectName: "applicationWindowStateGroup"
        states: [
            State {
                name: "void"
                when:
                     d.hadSurface && (!root.surface || !d.surfaceInitialized)
                     &&
                     screenshotImage.status !== Image.Ready
            },
            State {
                name: "splashScreen"
                when:
                     !d.hadSurface && (!root.surface || !d.surfaceInitialized)
                     &&
                     screenshotImage.status !== Image.Ready
            },
            State {
                name: "surface"
                when:
                      (root.surface && d.surfaceInitialized)
                      &&
                      (d.applicationState !== ApplicationInfo.Stopped
                       || screenshotImage.status !== Image.Ready)
            },
            State {
                name: "screenshot"
                when:
                      screenshotImage.status === Image.Ready
                      &&
                      (d.applicationState === ApplicationInfo.Stopped
                       || !root.surface || !d.surfaceInitialized)
            }
        ]

        transitions: [
            Transition {
                from: ""; to: "splashScreen"
                PropertyAction { target: splashLoader; property: "active"; value: true }
            },
            Transition {
                from: "splashScreen"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: surfaceContainer
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: splashLoader; property: "opacity";
                                            from: 1.0; to: 0.0
                                            duration: UbuntuAnimation.BriskDuration }
                    PropertyAction { target: splashLoader; property: "active"; value: false }
                }
            },
            Transition {
                from: "surface"; to: "splashScreen"
                SequentialAnimation {
                    PropertyAction { target: splashLoader; property: "active"; value: true }
                    PropertyAction { target: surfaceContainer
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: splashLoader; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                }
            },
            Transition {
                from: "surface"; to: "screenshot"
                SequentialAnimation {
                    PropertyAction { target: screenshotImage
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: screenshotImage; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                    PropertyAction { target: surfaceContainer
                                     property: "visible"; value: false }
                    ScriptAction { script: { if (root.surface) { root.surface.release(); } } }
                }
            },
            Transition {
                from: "screenshot"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: surfaceContainer
                                     property: "visible"; value: true }
                    UbuntuNumberAnimation { target: screenshotImage; property: "opacity";
                                            from: 1.0; to: 0.0
                                            duration: UbuntuAnimation.BriskDuration }
                    PropertyAction { target: screenshotImage; property: "visible"; value: false }
                    PropertyAction { target: screenshotImage; property: "source"; value: "" }
                }
            },
            Transition {
                from: "surface"; to: "void"
                SequentialAnimation {
                    PropertyAction { target: surfaceContainer; property: "visible"; value: false }
                    ScriptAction { script: { if (d.surface) { d.surface.release(); } } }
                }
            },
            Transition {
                from: "void"; to: "surface"
                SequentialAnimation {
                    PropertyAction { target: surfaceContainer; property: "opacity"; value: 0.0 }
                    PropertyAction { target: surfaceContainer; property: "visible"; value: true }
                    UbuntuNumberAnimation { target: surfaceContainer; property: "opacity";
                                            from: 0.0; to: 1.0
                                            duration: UbuntuAnimation.BriskDuration }
                }
            }
        ]
    }

}
