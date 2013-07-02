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

    PanelBackground {
        id: panelBackground
        anchors {
            left: parent.left
            right: parent.right
        }
        height: __panelMinusSeparatorLineHeight
        y: 0
        onYChanged: indicatorsMenu.y = y;

        Behavior on y {
                NumberAnimation { duration: 200 }
        }
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

        anchors.right: parent.right
        y: 0
        width: root.indicatorsMenuWidth
        shown: false
        hintValue: __panelMinusSeparatorLineHeight * 3
        panelHeight: __panelMinusSeparatorLineHeight
        openedHeight: parent.height

        pinnedMode: !fullscreenMode

        property real unitProgress: height / parent.height
    }

    SearchIndicator {
        id: search
        objectName: "search"
        enabled: root.searchVisible

        state: {
            if (parent.width < indicatorsMenu.width + width) {
                if (indicatorsMenu.state != "initial") {
                    return "hiddenUp";
                }
            }
            if (root.searchVisible) {
                return "visible";
            }

            return "hiddenUp";
        }

        width: units.gu(13)
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
