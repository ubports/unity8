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
    property Item stages
    property Item overlay

    readonly property bool launcherEnabled: !running ||
                                            (!paused && loader.target === leftComponent)
    readonly property bool stagesEnabled: !running
    readonly property bool panelEnabled: !running
    readonly property bool panelContentEnabled: !running
    readonly property bool running: loader.sourceComponent !== null

    property bool paused: false

    signal finished()

    function finish() {
        d.stop();
        finished();
    }

    ////

    visible: false
    onVisibleChanged: {
        d.stop();
        if (visible) {
            d.start();
        }
    }

    QtObject {
        id: d

        function stop() {
            loader.sourceComponent = null;
        }

        function start() {
            loader.load(leftComponent);
        }
    }

    Loader {
        id: loader

        property Component target: {
            if (next) {
                return next;
            } else if (loader.item && loader.item.shown) {
                return sourceComponent;
            } else {
                return null;
            }
        }

        property Component next: null

        function load(comp) {
            if (loader.item) {
                next = comp;
                loader.item.hide();
            } else {
                loader.sourceComponent = comp;
            }
        }

        Connections {
            target: loader.item
            onFinished: {
                loader.sourceComponent = loader.next;
                if (loader.next != null) {
                    loader.next = null;
                } else {
                    root.finished();
                }
            }
        }

        Binding {
            target: loader.item
            property: "paused"
            value: root.paused
        }
    }

    Component {
        id: leftComponent
        TutorialLeft {
            objectName: "tutorialLeft"
            parent: root.stages
            anchors.fill: parent
            launcher: root.launcher

            onFinished: loader.load(leftFinishComponent)
        }
    }

    Component {
        id: leftFinishComponent
        TutorialLeftFinish {
            objectName: "tutorialLeftFinish"
            parent: root.stages
            anchors.fill: parent
            textXOffset: root.launcher.panelWidth
            backgroundFadesOut: true

            onFinished: root.launcher.hide()
        }
    }
}
