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

ResponsiveFlowView {
    id: root
    clip: true

    signal updateScreenshots

    Connections {
        target: shell
        onDashShownChanged: if (shell.dashShown && shell.stageScreenshotsReady) updateScreenshots();
        onStageScreenshotsReadyChanged: if (shell.dashShown && shell.stageScreenshotsReady) updateScreenshots();
    }

    Behavior on height {
        enabled: culled === undefined || !culled;
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
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
                shell.applicationManager.stopApplication(model.appId)
            }
            onRequestedApplicationActivation: {
                shell.activateApplication(model.appId)
            }

            terminationModeEnabled: root.terminationModeEnabled

            Component.onCompleted: {
                root.updateScreenshots.connect(updateScreenshotFromCache);
            }
        }
    }

    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutCubic }
    }
}
