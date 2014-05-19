/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import "../../Components"

import Ubuntu.Gestures 0.1
import Mir.Application 0.1

ResponsiveFlowView {
    id: root
    clip: true

    signal updateScreenshots
    property alias enableHeightBehavior: heightBehaviour.enabled
    property bool enableHeightBehaviorOnNextCreation: model.count === 0

    property int orientationAngle

    Behavior on height {
        id: heightBehaviour
        enabled: false
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Connections {
        target: root.model
        onCountChanged: {
            heightBehaviour.enabled = true;
        }
    }

    property bool canEnableTerminationMode: true

    onCanEnableTerminationModeChanged: {
        if (!canEnableTerminationMode)
            terminationModeEnabled = false
    }

    // when false, it means it's on activation mode
    property bool terminationModeEnabled: false

    maximumNumberOfColumns: 10
    minimumHorizontalSpacing: units.gu(2)
    referenceDelegateWidth: units.gu(11)
    verticalSpacing: units.gu(2)

    delegate: Item {
        width: runningAppTile.width + root.horizontalSpacing
        height: runningAppTile.height + root.verticalSpacing

        RunningApplicationTile {
            id: runningAppTile
            objectName: "runningAppTile " + model.name
            orientationAngle: root.orientationAngle
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            application: model
            onRequestedActivationMode: { root.terminationModeEnabled = false }
            onRequestedTerminationMode: {
                if (canEnableTerminationMode)
                    root.terminationModeEnabled = true
            }
            onRequestedApplicationTermination: {
                ApplicationManager.stopApplication(model.appId)
            }
            onRequestedApplicationActivation: {
                ApplicationManager.requestFocusApplication(model.appId)
            }

            terminationModeEnabled: root.terminationModeEnabled
        }
    }

    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutCubic }
    }

    MouseArea {
        anchors.fill: parent
        z: -1 // behind all RunningApplicationTiles
        enabled: root.terminationModeEnabled
        onPressed: { root.terminationModeEnabled = false; }
    }

    PressedOutsideNotifier {
        anchors.fill: parent
        enabled: root.terminationModeEnabled
        onPressedOutside: {
            root.terminationModeEnabled = false;
        }
    }
}
