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

import QtQuick 2.4
import Ubuntu.Components 1.3
import AccountsService 0.1

/**
 * This object is always present, so it should be lean and mean.  It will
 * use a Loader to create the heavier tutorial pages if needed.
 */

Item {
    id: root

    property alias active: loader.active

    property Item launcher
    property Item panel
    property Item stage
    property string usageScenario

    readonly property bool launcherEnabled: loader.item ? loader.item.launcherEnabled : true
    readonly property bool spreadEnabled: loader.item ? loader.item.spreadEnabled : true
    readonly property bool panelEnabled: loader.item ? loader.item.panelEnabled : true
    readonly property bool running: loader.item ? loader.item.running : false

    function finish() {
        if (loader.item) {
            loader.item.finish();
        }
    }

    Connections {
        target: panel.indicators
        onFullyOpenedChanged: AccountsService.markDemoEdgeCompleted("top")
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: "TutorialContent.qml"

        // EdgeDragAreas don't work with mice.  So to avoid trapping the user,
        // we skip the tutorial on the Desktop to avoid using them.  The
        // Desktop doesn't use the same spread design anyway.  The tutorial is
        // all a bit of a placeholder on non-phone form factors right now.
        // When the design team gives us more guidance, we can do something
        // more clever here.
        active: usageScenario != "desktop" && AccountsService.demoEdges

        Binding {
            target: loader.item
            property: "launcher"
            value: root.launcher
        }

        Binding {
            target: loader.item
            property: "panel"
            value: root.panel
        }

        Binding {
            target: loader.item
            property: "stage"
            value: root.stage
        }

        Connections {
            target: loader.item
            onFinished: AccountsService.demoEdges = false
        }
    }
}
