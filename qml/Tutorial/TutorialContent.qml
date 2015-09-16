/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    id: root

    property Item launcher
    property Item panel

    readonly property bool launcherEnabled: !running || tutorialLeft.shown
    readonly property bool spreadEnabled: !running
    readonly property bool panelEnabled: !running
    readonly property bool panelContentEnabled: !running
    readonly property alias running: d.running

    signal finished()

    function finish() {
        d.stop();
        finished();
    }

    ////

    Component.onCompleted: {
        d.start();
    }

    QtObject {
        id: d

        property bool running

        function stop() {
            running = false;
        }

        function start() {
            running = true;
            tutorialLeft.show();
        }
    }

    TutorialLeft {
        id: tutorialLeft
        objectName: "tutorialLeft"
        parent: root.panel
        anchors.fill: parent
        launcher: root.launcher

        onFinished: root.finish()
    }
}
