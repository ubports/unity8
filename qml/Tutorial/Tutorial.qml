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

    readonly property bool launcherEnabled: !running ||
                                            loader.sourceComponent === leftComponent ||
                                            loader.sourceComponent === leftFinishComponent
    readonly property bool stagesEnabled: !running
    readonly property bool panelEnabled: !running ||
                                         loader.sourceComponent === topComponent ||
                                         loader.sourceComponent === topFinishComponent
    readonly property bool panelContentEnabled: !running
    readonly property bool running: loader.sourceComponent !== null

    property bool paused: false

    property int readingDelay: 3500

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
        property int pageTotal: 2

        function stop() {
            loader.sourceComponent = null;
        }

        function start() {
            loader.load(introComponent);
        }
    }

    Connections {
        target: root.panel.indicators

        onFullyOpenedChanged: {
            if (loader.sourceComponent === topComponent &&
                    root.panel.indicators.fullyOpened) {
                loader.load(topFinishComponent);
            }
        }

        onPartiallyOpenedChanged: {
            if (loader.sourceComponent === topFinishComponent &&
                    !root.panel.indicators.partiallyOpened &&
                    !root.panel.indicators.fullyOpened) {
                loader.load(leftComponent);
            }
        }
    }

    Connections {
        target: root.launcher

        onProgressChanged: {
            if (loader.sourceComponent === leftComponent &&
                    launcher.progress > 0) {
                loader.load(leftFinishComponent);
            }
        }

        onShownChanged: {
            // This stanza is necessary because user might have dragged launcher
            // far enough to trigger the progress check above, but then dragged
            // it back into its original position.
            if (loader.sourceComponent === leftFinishComponent &&
                    !launcher.shown) {
                loader.load(null);
            }
        }

        onStateChanged: {
            if ((loader.sourceComponent === leftComponent || // happens if user didn't drag past launcher
                 loader.sourceComponent === leftFinishComponent) &&
                    launcher.state === "visible") {
                loader.load(null);
                launcher.hide();
            }
        }
    }

    Loader {
        id: loader

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

        Binding {
            target: loader.item
            property: "pageTotal"
            value: d.pageTotal
        }
    }

    Component {
        id: introComponent
        TutorialIntro {
            objectName: "tutorialIntro"
            parent: root.stages
            anchors.fill: parent
            backgroundFadesOut: false

            Timer {
                interval: root.readingDelay
                running: !root.paused
                onTriggered: loader.load(topComponent)
            }
        }
    }

    Component {
        id: topComponent
        TutorialTop {
            objectName: "tutorialTop"
            parent: root.stages
            anchors.fill: parent
            anchors.topMargin: root.panel.indicators.panelHeight
            pageNumber: 1
            backgroundFadesIn: false
        }
    }

    Component {
        id: topFinishComponent
        TutorialTopFinish {
            objectName: "tutorialTopFinish"
            parent: root.panel.indicators
            anchors.bottom: parent ? parent.content.bottom : undefined
            anchors.left: parent ? parent.content.left : undefined
            anchors.right: parent ? parent.content.right : undefined
            height: root.stages.height
        }
    }

    Component {
        id: leftComponent
        TutorialLeft {
            objectName: "tutorialLeft"
            parent: root.stages
            anchors.fill: parent
            pageNumber: 2
            backgroundFadesOut: false
        }
    }

    Component {
        id: leftFinishComponent
        TutorialLeftFinish {
            objectName: "tutorialLeftFinish"
            parent: root.stages
            anchors.fill: parent
            textXOffset: root.launcher.panelWidth
            backgroundFadesIn: false
        }
    }
}
