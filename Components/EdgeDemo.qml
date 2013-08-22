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
    property Item dash
    property Item launcher
    property Item indicators
    property Item overlay

    property bool launcherEnabled: true
    property bool dashEnabled: true
    property bool panelEnabled: true

    property bool showEdgeDemo: false
    property bool showEdgeDemoInGreeter: showEdgeDemo // TODO: AccountsService.getUserProperty("lightdm", "demo-edges")

    function hideEdgeDemoInShell() {
        var user = LightDM.Users.data(greeter.currentIndex, LightDM.UserRoles.NameRole);
        AccountsService.setUserProperty(user, "demo-edges", false);
        demo.showEdgeDemo = false;
        stopDemo();
    }

    function hideEdgeDemoInGreeter() {
        // TODO: AccountsService.setUserProperty("lightdm", "demo-edges", false);
        demo.showEdgeDemoInGreeter = false;
    }

    function hideEdgeDemos() {
        hideEdgeDemoInGreeter();
        hideEdgeDemoInShell();
    }

    function stopDemo() {
        launcherEnabled = true;
        dashEnabled = true;
        panelEnabled = true;
        if (d.rightEdgeDemo)  d.rightEdgeDemo.destroy()
        if (d.topEdgeDemo)    d.topEdgeDemo.destroy()
        if (d.bottomEdgeDemo) d.bottomEdgeDemo.destroy()
        if (d.leftEdgeDemo)   d.leftEdgeDemo.destroy()
        if (d.finalEdgeDemo)  d.finalEdgeDemo.destroy()
    }

    QtObject {
        id: d
        property Component overlay
        property QtObject rightEdgeDemo
        property QtObject topEdgeDemo
        property QtObject bottomEdgeDemo
        property QtObject leftEdgeDemo
        property QtObject finalEdgeDemo
    }

    onShowEdgeDemoInGreeterChanged: {
        if (!d.overlay && showEdgeDemoInGreeter) {
            d.overlay = Qt.createComponent("EdgeDemoOverlay.qml")
            startRightEdgeDemo()
        }
    }

    function startRightEdgeDemo() {
        launcherEnabled = false;
        demo.dashEnabled = false;
        demo.panelEnabled = false;
        if (demo.greeter) {
            d.rightEdgeDemo = d.overlay.createObject(demo.greeter, {
                "edge": "right",
                "title": i18n.tr("Right edge"),
                "text": i18n.tr("Try swiping from the right edge to unlock the phone"),
                "anchors.fill": demo.greeter,
            });
            d.rightEdgeDemo.onSkip.connect(demo.hideEdgeDemos)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.greeter

        function hide() {
            if (d.rightEdgeDemo) {
                d.rightEdgeDemo.hide()
                hideEdgeDemoInGreeter()
                startTopEdgeDemo()
            }
        }

        onUnlocked: hide()
        onShownChanged: if (!greeter.shown) hide()

        onSelected: {
            var user = LightDM.Users.data(uid, LightDM.UserRoles.NameRole)
            showEdgeDemo = true;///AccountsService.getUserProperty(user, "demo-edges")
        }
    }

    function startTopEdgeDemo() {
        demo.panelEnabled = true;
        if (demo.dash) {
            d.topEdgeDemo = d.overlay.createObject(demo.dash, {
                "edge": "top",
                "title": i18n.tr("Top edge"),
                "text": i18n.tr("Try swiping from the top edge to access the indicators"),
                "anchors.fill": demo.dash,
            });
            d.topEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.indicators
        onFullyOpenedChanged: {
            if (d.topEdgeDemo && demo.indicators.fullyOpened) {
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
                "anchors.fill": demo.indicators,
            });
            d.bottomEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.indicators
        onPartiallyOpenedChanged: {
            if (d.bottomEdgeDemo && !demo.indicators.partiallyOpened && !demo.indicators.fullyOpened) {
                d.bottomEdgeDemo.hideNow()
                startLeftEdgeDemo()
            }
        }
    }

    function startLeftEdgeDemo() {
        demo.panelEnabled = false;
        demo.launcherEnabled = true;
        if (demo.dash) {
            d.leftEdgeDemo = d.overlay.createObject(demo.dash, {
                "edge": "left",
                "title": i18n.tr("Left edge"),
                "text": i18n.tr("Swipe from the left to reveal the launcher for quick access to apps"),
                "anchors.fill": demo.dash,
            });
            d.leftEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }

    Connections {
        target: demo.launcher
        onStateChanged: {
            if (d.leftEdgeDemo && launcher.state == "visible") {
                d.leftEdgeDemo.hide()
                startFinalEdgeDemo()
            }
        }
    }

    function startFinalEdgeDemo() {
        demo.launcherEnabled = false;
        if (demo.dash) {
            d.finalEdgeDemo = d.overlay.createObject(demo.overlay, {
                "edge": "none",
                "title": i18n.tr("Well done"),
                "text": i18n.tr("You have now mastered the edge gestures and can start using the phone"),
                "anchors.fill": demo.overlay,
            });
            d.finalEdgeDemo.onSkip.connect(demo.hideEdgeDemoInShell)
        } else {
            stopDemo();
        }
    }
}
