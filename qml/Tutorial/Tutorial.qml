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
                                            loader.sourceComponent === leftComponent ||
                                            loader.sourceComponent === leftFinishComponent ||
                                            loader.sourceComponent === leftReleaseComponent
    readonly property bool stagesEnabled: !running
    readonly property bool panelEnabled: !running ||
                                         loader.sourceComponent === topComponent ||
                                         loader.sourceComponent === topFinishComponent
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
            if (loader.target === topComponent &&
                    root.panel.indicators.fullyOpened) {
                loader.load(topFinishComponent);
            }
        }

        onPartiallyOpenedChanged: {
            if (loader.target === topFinishComponent &&
                    !root.panel.indicators.partiallyOpened &&
                    !root.panel.indicators.fullyOpened) {
                loader.load(leftComponent);
            }
        }
    }

    Connections {
        target: root.launcher

        onProgressChanged: {
            if (loader.target === leftComponent && launcher.progress > 0) {
                loader.load(leftReleaseComponent);
            }
        }

        onShownChanged: {
            // This stanza is necessary because user might have dragged the
            // launcher far enough to trigger the progress check above, but
            // then dragged it back into its original position.
            if (loader.target === leftReleaseComponent && !launcher.shown) {
                loader.load(null);
            }
        }

        onStateChanged: {
            if (launcher.state === "visible") {
                if (loader.target === leftComponent) {
                    // happens if user didn't drag past launcher
                    loader.load(leftFinishComponent);
                } else if (loader.target === leftReleaseComponent) {
                    loader.load(null);
                    launcher.hide();
                }
            }
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
            onShownChanged: if (!shown) loader.load(topComponent)
        }
    }

    Component {
        id: topComponent
        TutorialTop {
            objectName: "tutorialTop"
            parent: root.panel
            anchors.fill: parent
            mouseArea {
                anchors.topMargin: root.panel.indicators.minimizedPanelHeight
            }
            pageNumber: 1
        }
    }

    Component {
        id: topFinishComponent
        TutorialTopFinish {
            objectName: "tutorialTopFinish"
            parent: root.panel
            anchors.bottom: parent ? parent.bottom : undefined
            anchors.left: parent ? parent.left : undefined
            anchors.right: parent ? parent.right : undefined
            mouseArea {
                anchors.bottomMargin: root.panel.indicators.hideDragHandle.height
            }
            height: root.panel.height
        }
    }

    Component {
        id: leftComponent
        TutorialLeft {
            objectName: "tutorialLeft"
            parent: root.stages
            anchors.fill: parent
            pageNumber: 2
        }
    }

    Component {
        id: leftReleaseComponent
        TutorialLeftRelease {
            objectName: "tutorialLeftRelease"
            parent: root.stages
            anchors.fill: parent
            textXOffset: root.launcher.panelWidth
            backgroundFadesOut: true
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
            mouseArea {
                parent: root.overlay
                onClicked: {
                    loader.load(null);
                    root.launcher.hide();
                }
            }
        }
    }
}
