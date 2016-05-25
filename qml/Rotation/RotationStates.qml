/*
 * Copyright (C) 2015,2016 Canonical, Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Powerd 0.1

// Why the state machine is done that way:
// We cannot use regular PropertyChanges{} inside the State elements as steps in the
// transition animations must take place in a well defined order.
// Which means that we also cannot jump to a new state in the middle of a transition
// as that would make hell brake loose.
StateGroup {
    id: root

    // to be set from the outside
    property Item orientedShell
    property Item shell
    property Item shellCover
    property Item shellSnapshot

    property int rotationDuration: 450
    property int rotationEasing: Easing.InOutCubic
    // Those values are good for debugging/development
    //property int rotationDuration: 3000
    //property int rotationEasing: Easing.Linear

    state: "0"
    states: [
        State { name: "0" },
        State { name: "90" },
        State { name: "180" },
        State { name: "270" }
    ]

    property QtObject d: QtObject {
        id: d

        property bool startingUp: true
        property var finishStartUpTimer: Timer {
            interval: 500
            onTriggered: d.startingUp = false
        }
        Component.onCompleted: {
            finishStartUpTimer.start();
        }

        property bool transitioning: false
        onTransitioningChanged: {
            d.tryUpdateState();
        }

        readonly property int requestedOrientationAngle: root.orientedShell.acceptedOrientationAngle

        // Avoiding a direct call to tryUpdateState() as the state change might trigger an immediate
        // change to Shell.orientationAngle which, in its turn, causes a reevaluation of
        // requestedOrientationAngle (ie., OrientedShell.acceptedOrientationAngle). A reentrant evaluation
        // of a binding is detected by QML as a binding loop and QML will deny the reevalutation, which
        // will leave us in a bogus state.
        //
        // To avoid this mess we update the state in the next event loop iteration, ensuring a clean
        // call stack.
        onRequestedOrientationAngleChanged: {
            stateUpdateTimer.start();
        }
        property Timer stateUpdateTimer: Timer {
            id: stateUpdateTimer
            interval: 1
            onTriggered: { d.tryUpdateState(); }
        }

        function tryUpdateState() {
            if (d.transitioning || (!d.startingUp && !root.orientedShell.orientationChangesEnabled)) {
                return;
            }

            var requestedState = d.requestedOrientationAngle.toString();
            if (requestedState === root.state) {
                return;
            }

            d.resolveAnimationType();

            var angleDiff = Math.abs(root.shell.orientationAngle - d.requestedOrientationAngle);
            var isNinetyRotationAnimation = angleDiff == 90 || angleDiff == 270;
            var needsShellSnapshot = d.animationType == d.fullAnimation && isNinetyRotationAnimation;

            if (needsShellSnapshot && !shellSnapshotReady) {
                root.shellSnapshot.take();
                // try again once we have a shell snapshot ready for use. Snapshot taking is async.
                return;
            }

            if (!needsShellSnapshot && shellSnapshotReady) {
                root.shellSnapshot.discard();
            }

            root.state = requestedState;
        }

        property bool shellSnapshotReady: root.shellSnapshot && root.shellSnapshot.ready
        onShellSnapshotReadyChanged: tryUpdateState();

        property Connections shellConnections: Connections {
            target: root.orientedShell
            onOrientationChangesEnabledChanged: {
                d.tryUpdateState();
            }
        }

        property var shellBeingResized: Binding {
            target: root.shell
            property: "beingResized"
            value: d.transitioning
        }

        readonly property int fullAnimation: 0
        readonly property int indicatorsBarAnimation: 1
        readonly property int noAnimation: 2

        property int animationType

        // animationType update *must* take place *before* the state update.
        // If animationType and state were updated through bindings, as with normal qml code,
        // there would be no guarantee in the order of the binding updates, which could then
        // cause the wrong transitions to be chosen for the state changes.
        function resolveAnimationType() {
            if (d.startingUp) {
                // During start up, inital property values are still settling while we're still
                // to render the very first frame
                d.animationType = d.noAnimation;
            } else if (Powerd.status === Powerd.Off) {
                // There's no point in animating if the user can't see it (display is off).
                d.animationType = d.noAnimation;
            } else if (root.shell.showingGreeter) {
                // A rotating greeter looks weird.
                d.animationType = d.noAnimation;
            } else {
                if (!root.shell.mainApp) {
                    // shouldn't happen but, anyway
                    d.animationType = d.fullAnimation;
                    return;
                }

                if (root.shell.mainApp.rotatesWindowContents) {
                    // The application will animate its own GUI, so we don't have to do anything ourselves.
                    d.animationType = d.noAnimation;
                } else if (root.shell.mainAppWindowOrientationAngle == d.requestedOrientationAngle) {
                    // The app window is already on its final orientation angle.
                    // So we just animate the indicators bar
                    // TODO: what if the app is fullscreen?
                    d.animationType = d.indicatorsBarAnimation;
                } else {
                    d.animationType = d.fullAnimation;
                }
            }
        }

        // When an application switch takes place, d.requestedOrientationAngle and
        // root.shell.mainAppWindowOrientationAngle get updated separately, at different moments.
        // So, when one of those properties change, we shouldn't make a decision straight away
        // as the other might be stale and about to be changed. So let's give it a bit of time for
        // them to get properly updated.
        // This approach is indeed a bit hacky.
        property bool appWindowOrientationAngleNeedsUpdateUnstable:
            root.shell.orientationAngle === d.requestedOrientationAngle
            && root.shell.mainApp
            && root.shell.mainAppWindowOrientationAngle !== root.shell.orientationAngle
            && !d.transitioning
        onAppWindowOrientationAngleNeedsUpdateUnstableChanged: {
            stableTimer.restart();
        }
        property Timer stableTimer: Timer {
            interval: 200
            onTriggered: {
                if (d.appWindowOrientationAngleNeedsUpdateUnstable) {
                    shell.updateFocusedAppOrientationAnimated();
                }
            }
        }
    }

    transitions: [
        Transition {
            from: "90"; to: "0"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 90; toAngle: 0
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "0"; to: "90"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 0; toAngle: 90
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "0"; to: "270"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 0; toAngle: 270
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "270"; to: "0"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 270; toAngle: 0
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "90"; to: "180"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 90; toAngle: 180
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "180"; to: "90"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 180; toAngle: 90
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "180"; to: "270"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 180; toAngle: 270
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "270"; to: "180"
            enabled: d.animationType == d.fullAnimation
            NinetyRotationAnimation { fromAngle: 270; toAngle: 180
                                      info: d; shell: root.shell }
        },
        Transition {
            from: "0"; to: "180"
            enabled: d.animationType == d.fullAnimation
            HalfLoopRotationAnimation { fromAngle: 0; toAngle: 180
                                        info: d; shell: root.shell }
        },
        Transition {
            from: "180"; to: "0"
            enabled: d.animationType == d.fullAnimation
            HalfLoopRotationAnimation { fromAngle: 180; toAngle: 0
                                        info: d; shell: root.shell }
        },
        Transition {
            from: "90"; to: "270"
            enabled: d.animationType == d.fullAnimation
            HalfLoopRotationAnimation { fromAngle: 90; toAngle: 270
                                        info: d; shell: root.shell }
        },
        Transition {
            from: "270"; to: "90"
            enabled: d.animationType == d.fullAnimation
            HalfLoopRotationAnimation { fromAngle: 270; toAngle: 90
                                        info: d; shell: root.shell }
        },
        Transition {
            objectName: "immediateTransition"
            enabled: d.animationType == d.noAnimation
            ImmediateRotationAction { info: d; shell: root.shell }
        },
        Transition {
            enabled: d.animationType == d.indicatorsBarAnimation
            SequentialAnimation {
                ScriptAction { script: {
                    d.transitioning = true;
                } }
                NumberAnimation {
                    duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing
                    target: root.shell; property: "indicatorAreaShowProgress"
                    from: 1.0; to: 0.0
                }
                ImmediateRotationAction { info: d; shell: root.shell }
                NumberAnimation {
                    duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing
                    target: root.shell; property: "indicatorAreaShowProgress"
                    from: 0.0; to: 1.0
                }
                ScriptAction { script: {
                    d.transitioning = false;
                }}
            }
        }
    ]

}
