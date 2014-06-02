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

import AccountsService 0.1
import QtQuick 2.0

Item {
    id: demo

    property Item dash
    property Item launcher
    property Item indicators
    property Item underlay

    property bool launcherEnabled: true
    property bool dashEnabled: true
    property bool panelEnabled: true
    property bool panelContentEnabled: true
    property bool running: !launcherEnabled || !dashEnabled || !panelEnabled || !panelContentEnabled

    property bool paused: false

    onPausedChanged: {
        if (d.topEdgeDemo)    d.topEdgeDemo.paused = paused
        if (d.bottomEdgeDemo) d.bottomEdgeDemo.paused = paused
        if (d.leftEdgeDemo)   d.leftEdgeDemo.paused = paused
        if (d.finalEdgeDemo)  d.finalEdgeDemo.paused = paused
    }

    function hideEdgeDemoInShell() {
        AccountsService.demoEdges = false;
    }

    function stopDemo() {
        launcherEnabled = true
        dashEnabled = true
        panelEnabled = true
        panelContentEnabled = true
        if (d.topEdgeDemo)    d.topEdgeDemo.destroy()
        if (d.bottomEdgeDemo) d.bottomEdgeDemo.destroy()
        if (d.leftEdgeDemo)   d.leftEdgeDemo.destroy()
        if (d.finalEdgeDemo)  d.finalEdgeDemo.destroy()
    }

    function startDemo() {
        if (!d.overlay) {
            d.overlay = Qt.createComponent("EdgeDemoOverlay.qml")
        }

        launcherEnabled = false;
        dashEnabled = false;
        panelEnabled = false;
        panelContentEnabled = false;

        startTopEdgeDemo()
    }

    QtObject {
        id: d
        property Component overlay
        property QtObject topEdgeDemo
        property QtObject bottomEdgeDemo
        property QtObject leftEdgeDemo
        property QtObject finalEdgeDemo
        property bool showEdgeDemo: AccountsService.demoEdges

        onShowEdgeDemoChanged: {
            stopDemo()
            if (d.showEdgeDemo) {
                startDemo()
            }
        }
    }

    function startTopEdgeDemo() {
        demo.panelEnabled = true;
        if (demo.dash && demo.underlay) {
            d.topEdgeDemo = d.overlay.createObject(demo.underlay, {
                "edge": "top",
                "title": i18n.tr("Top edge"),
                "text": i18n.tr("Try swiping from the top edge to access the indicators"),
                "anchors.fill": demo.dash,
            });
        }
        if (d.topEdgeDemo) {
            d.topEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.indicators
        onFullyOpenedChanged: {
            if (d.topEdgeDemo && d.topEdgeDemo.available && demo.indicators.fullyOpened) {
                d.topEdgeDemo.hideNow()
                startBottomEdgeDemo()
            }
        }
    }

    function startBottomEdgeDemo() {
        if (demo.indicators) {
            d.bottomEdgeDemo = d.overlay.createObject(demo.indicators, {
                "edge": "bottom",
                "title": i18n.tr("Close"),
                "text": i18n.tr("Swipe up again to close the settings screen"),
                "anchors.fill": demo.indicators.content,
            });
        }
        if (d.bottomEdgeDemo) {
            d.bottomEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.indicators
        onPartiallyOpenedChanged: {
            if (d.bottomEdgeDemo && d.bottomEdgeDemo.available && !demo.indicators.partiallyOpened && !demo.indicators.fullyOpened) {
                d.bottomEdgeDemo.hideNow()
                startLeftEdgeDemo()
            }
        }
    }

    function startLeftEdgeDemo() {
        demo.panelEnabled = false;
        demo.launcherEnabled = true;
        if (demo.dash && demo.underlay) {
            d.leftEdgeDemo = d.overlay.createObject(demo.underlay, {
                "edge": "left",
                "title": i18n.tr("Left edge"),
                "text": i18n.tr("Swipe from the left to reveal the launcher for quick access to apps"),
                "anchors.fill": demo.dash,
            });
        }
        if (d.leftEdgeDemo) {
            d.leftEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.launcher
        onStateChanged: {
            if (d.leftEdgeDemo && d.leftEdgeDemo.available && launcher.state == "visible") {
                d.leftEdgeDemo.hide()
                launcher.hide()
                startFinalEdgeDemo()
            }
        }
    }

    function startFinalEdgeDemo() {
        demo.launcherEnabled = false;
        if (demo.dash && demo.underlay) {
            d.finalEdgeDemo = d.overlay.createObject(demo.underlay, {
                "edge": "none",
                "title": i18n.tr("Well done"),
                "text": i18n.tr("You have now mastered the edge gestures and can start using the phone<br><br>Tap on the screen to start"),
                "anchors.fill": demo.dash,
                "showSkip": false,
            });
        }
        if (d.finalEdgeDemo) {
            d.finalEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }
}
