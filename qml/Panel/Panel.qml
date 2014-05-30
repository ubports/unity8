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

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"

Item {
    id: root
    readonly property real panelHeight: units.gu(3) + units.dp(2)
    property real indicatorsMenuWidth: (shell.width > units.gu(60)) ? units.gu(40) : shell.width
    property alias indicators: indicatorsMenu
    property bool fullscreenMode: false
    property bool searchVisible: true

    readonly property real separatorLineHeight: leftSeparatorLine.height
    readonly property real __panelMinusSeparatorLineHeight: panelHeight - separatorLineHeight

    signal searchClicked

    function hideIndicatorMenu(delay) {
        if (delay !== undefined) {
            hideTimer.interval = delay;
            hideTimer.start();
        } else {
            indicatorsMenu.hide();
        }
    }

    Timer {
        id: hideTimer
        running: false
        onTriggered: {
            indicatorsMenu.hide();
        }
    }

    Connections {
        target: indicatorsMenu
        onShownChanged: hideTimer.stop()
    }

    PanelBackground {
        id: panelBackground
        anchors {
            left: parent.left
            right: parent.right
        }
        height: __panelMinusSeparatorLineHeight
        y: 0

        Behavior on y { StandardAnimation { duration: 500 } }
    }

    PanelSeparatorLine {
        id: leftSeparatorLine
        anchors {
            top: panelBackground.bottom
            left: parent.left
            right: indicatorsMenu.left
        }
        saturation: 1 - indicatorsMenu.unitProgress
    }

    Rectangle {
        id: darkenedArea
        property real darkenedOpacity: 0.6
        anchors {
            left: parent.left
            right: parent.right
            top: panelBackground.bottom
            bottom: parent.bottom
        }
        color: "black"
        opacity: indicatorsMenu.unitProgress * darkenedOpacity
        MouseArea {
            anchors.fill: parent
            enabled: indicatorsMenu.shown
            onClicked: if (indicatorsMenu.fullyOpened) indicatorsMenu.hide();
        }
    }

    Indicators {
        id: indicatorsMenu
        objectName: "indicators"

        anchors.right: parent.right
        y: panelBackground.y
        width: root.indicatorsMenuWidth
        shown: false
        panelHeight: __panelMinusSeparatorLineHeight
        openedHeight: parent.height + (pinnedMode ? 0 : root.panelHeight)
        pinnedMode: !fullscreenMode
        overFlowWidth: search.state=="hidden" ? parent.width : parent.width - search.width
    }

    PanelSeparatorLine {
        id: indicatorsSeparatorLine
        visible: true
        anchors {
            left: indicatorsMenu.left
            right: indicatorsMenu.right
        }
        y: indicatorsMenu.visualBottom
    }

    BorderImage {
        id: dropShadow
        anchors {
            top: indicators.top
            bottom: indicatorsSeparatorLine.bottom
            left: indicators.left
            right: indicators.right
            margins: -units.gu(1)
        }
        visible: indicatorsMenu.height > indicatorsMenu.panelHeight
        source: "graphics/rectangular_dropshadow.sci"
    }

    SearchIndicator {
        id: search
        objectName: "search"
        enabled: root.searchVisible

        state: {
            if (parent.width < indicatorsMenu.width + width) {
                if (indicatorsMenu.state != "initial") {
                    return "hidden";
                }
            }
            if (root.searchVisible && !indicatorsMenu.showAll) {
                return "visible";
            }

            return "hidden";
        }

        height: __panelMinusSeparatorLineHeight
        anchors {
            top: panelBackground.top
            left: panelBackground.left
        }

        onClicked: root.searchClicked()
    }

    states: [
        State {
            name: "in" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
            PropertyChanges { target: panelBackground; y: 0 }
        },
        State {
            name: "out" //pushed off screen
            when: fullscreenMode
            PropertyChanges { target: panelBackground; y: -panelHeight }
        }
    ]
}
