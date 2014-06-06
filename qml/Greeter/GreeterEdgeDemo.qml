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

    property bool active: false
    property bool paused: false

    onPausedChanged: {
        if (d.rightEdgeDemo)  d.rightEdgeDemo.paused = paused
    }

    function hideEdgeDemoInShell() {
        AccountsService.demoEdges = false;
    }

    function hideEdgeDemoInGreeter() {
        AccountsService.demoEdgesForCurrentUser = false;
    }

    function hideEdgeDemos() {
        hideEdgeDemoInGreeter();
        hideEdgeDemoInShell();
    }

    function startDemo() {
        if (!d.overlay) {
            d.overlay = Qt.createComponent("../Components/EdgeDemoOverlay.qml")
        }
        startRightEdgeDemo()
    }

    function stopDemo() {
        active = false
        if (d.rightEdgeDemo)  d.rightEdgeDemo.destroy()
    }

    QtObject {
        id: d
        property Component overlay
        property QtObject rightEdgeDemo
        property bool showEdgeDemoInGreeter: AccountsService.demoEdgesForCurrentUser && AccountsService.demoEdges

        onShowEdgeDemoInGreeterChanged: {
            stopDemo()
            if (d.showEdgeDemoInGreeter) {
                startDemo()
            }
        }
    }

    function startRightEdgeDemo() {
        active = true;
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
            }
        }

        onUnlocked: hide()
        onShownChanged: if (!greeter.shown) hide()
    }
}
