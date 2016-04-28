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
    property bool paused // hide any existing tutorial and don't show new ones
    property bool delayed // don't show new tutorials
    property int lastInputTimestamp

    readonly property bool launcherEnabled: loader.item ? loader.item.launcherEnabled : true
    readonly property bool launcherLongSwipeEnabled: loader.item ? loader.item.launcherLongSwipeEnabled : true
    readonly property bool spreadEnabled: loader.item ? loader.item.spreadEnabled : true
    readonly property bool panelEnabled: loader.item ? loader.item.panelEnabled : true
    readonly property bool running: loader.item ? loader.item.running : false

    function finish() {
        if (loader.item) {
            loader.item.finish();
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: "TutorialContent.qml"
        active: AccountsService.demoEdges

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

        Binding {
            target: loader.item
            property: "usageScenario"
            value: root.usageScenario
        }

        Binding {
            target: loader.item
            property: "paused"
            value: root.paused
        }

        Binding {
            target: loader.item
            property: "delayed"
            value: root.delayed
        }

        Binding {
            target: loader.item
            property: "lastInputTimestamp"
            value: root.lastInputTimestamp
        }

        Connections {
            target: loader.item
            onFinished: AccountsService.demoEdges = false
        }
    }
}
