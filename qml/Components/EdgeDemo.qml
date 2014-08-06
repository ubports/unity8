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
import LightDM 0.1 as LightDM
import QtQuick 2.0

Item {
    id: demo

    property Item greeter
    property Item launcher
    property Item indicators
    property Item stages

    property bool launcherEnabled: true
    property bool stagesEnabled: true
    property bool panelEnabled: true
    property bool panelContentEnabled: true
    property bool running: !launcherEnabled || !stagesEnabled || !panelEnabled || !panelContentEnabled

    property bool paused: false

    onPausedChanged: {
        if (d.rightEdgeDemo)  d.rightEdgeDemo.paused = paused
        if (d.topEdgeDemo)    d.topEdgeDemo.paused = paused
        if (d.bottomEdgeDemo) d.bottomEdgeDemo.paused = paused
        if (d.leftEdgeDemo)   d.leftEdgeDemo.paused = paused
        if (d.finalEdgeDemo)  d.finalEdgeDemo.paused = paused
    }

    function hideEdgeDemoInShell() {
        AccountsService.demoEdges = false;
        stopDemo();
    }

    function hideEdgeDemoInGreeter() {
        // TODO: AccountsService.demoEdges = false as lightdm user
    }

    function hideEdgeDemos() {
        hideEdgeDemoInGreeter();
        hideEdgeDemoInShell();
    }

    function stopDemo() {
        launcherEnabled = true
        stagesEnabled = true
        panelEnabled = true
        panelContentEnabled = true
        if (d.rightEdgeDemo)  d.rightEdgeDemo.destroy()
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
        stagesEnabled = false;
        panelEnabled = false;
        panelContentEnabled = false;

        // Begin with either greeter or top, depending on which is visible
        if (greeter && greeter.shown) {
            startRightEdgeDemo()
        } else {
            startTopEdgeDemo()
        }
    }

    QtObject {
        id: d
        property Component overlay
        property QtObject rightEdgeDemo
        property QtObject topEdgeDemo
        property QtObject bottomEdgeDemo
        property QtObject leftEdgeDemo
        property QtObject finalEdgeDemo
        property bool showEdgeDemo: AccountsService.demoEdges
        property bool showEdgeDemoInGreeter: AccountsService.demoEdges // TODO: AccountsService.demoEdges as lightdm user

        onShowEdgeDemoChanged: {
            stopDemo()
            if (d.showEdgeDemo) {
                startDemo()
            }
        }
    }

    function startRightEdgeDemo() {
        if (demo.greeter) {
            d.rightEdgeDemo = d.overlay.createObject(demo.greeter, {
                "edge": "right",
                "title": i18n.tr("Right edge"),
                "text": i18n.tr("Try swiping from the right edge to unlock the phone"),
                "anchors.fill": demo.greeter,
            });
        }
        if (d.rightEdgeDemo) {
            d.rightEdgeDemo.onSkip.connect(demo.hideEdgeDemos)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.greeter

        function hide() {
            if (d.rightEdgeDemo && d.rightEdgeDemo.available) {
                d.rightEdgeDemo.hide()
                hideEdgeDemoInGreeter()
                startTopEdgeDemo()
            }
        }

        onUnlocked: hide()
        onShownChanged: if (!greeter.shown) hide()
    }

    function startTopEdgeDemo() {
        demo.panelEnabled = true;
        if (demo.stages) {
            d.topEdgeDemo = d.overlay.createObject(demo.stages, {
                "edge": "top",
                "title": i18n.tr("Top edge"),
                "text": i18n.tr("Try swiping from the top edge to access the indicators"),
                "anchors.fill": demo.stages,
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
        if (demo.stages) {
            d.leftEdgeDemo = d.overlay.createObject(demo.stages, {
                "edge": "left",
                "title": i18n.tr("Left edge"),
                "text": i18n.tr("Swipe from the left to reveal the launcher for quick access to apps"),
                "anchors.fill": demo.stages,
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
        if (demo.stages) {
            d.finalEdgeDemo = d.overlay.createObject(demo.stages, {
                "edge": "none",
                "title": i18n.tr("Well done"),
                "text": i18n.tr("You have now mastered the edge gestures and can start using the phone<br><br>Tap on the screen to start"),
                "anchors.fill": demo.stages,
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
