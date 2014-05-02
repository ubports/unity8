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
import Unity.Application 0.1
import "../Components"

Item {
    id: root
    readonly property real panelHeight: indicatorArea.y + indicatorArea.indicatorHeight
    property alias indicators: indicatorsMenu
    property bool fullscreenMode: false
    property bool searchVisible: true

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
        id: callHintBackground
        anchors.fill: callHint
    }

    ActiveCallHint {
        id: callHint

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(3)
        y: -height

        states: [
            State {
                name: "active"
                when: callHint.active
                PropertyChanges { target: callHint; y: 0 }
                PropertyChanges { target: search.mouseArea; anchors.topMargin: -callHint.height/3 }
            }
        ]
        Behavior on y { StandardAnimation { id: callHintYAnimation } }

        mouseArea.onClicked: callHint.activate();

        Rectangle {
            anchors.fill: callHint.mouseArea
            color: Qt.rgba(0,1,0,0.5)
        }
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"
        z: 1

        readonly property real indicatorHeight: indicatorsMenu.panelHeight + leftSeparatorLine.height

        anchors {
            left: parent.left
            right: parent.right
        }
        height: root.height - indicatorArea.y

        Behavior on y {
            enabled: !callHintYAnimation.running
            StandardAnimation {}
        }

        PanelBackground {
            id: panelBackground
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: indicatorsMenu.panelHeight
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
                top: leftSeparatorLine.bottom
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

        MouseArea {
            id: indicatorAreaClick
            enabled: callHint.active
            anchors {
                top: parent.top
                left: search.right
                right: indicatorsMenu.right
            }
            height: indicatorsMenu.panelHeight/2
            onClicked: callHint.activate();

            Rectangle {
                anchors.fill: indicatorAreaClick
                color: Qt.rgba(0,1,0,0.5)
            }
        }

        Indicators {
            id: indicatorsMenu
            objectName: "indicators"

            anchors {
                top: parent.top
                right: parent.right
            }

            width: (root.width > units.gu(60)) ? units.gu(40) : root.width
            shown: false
            panelHeight: units.gu(3)
            openedHeight: parent.height
            pinnedMode: !fullscreenMode
            enableHint: !callHint.active
            overFlowWidth: search.state=="hidden" ? parent.width : parent.width - search.width
            hintAreaHeightOffset: callHint.active ? callHint.height : 0

            onShowTapped: {
                if (callHint.active && position.y < y + indicatorsMenu.panelHeight/2) {
                    callHint.activate();
                }
            }

            Rectangle {
                anchors.fill: indicatorsMenu
                color: Qt.rgba(1,1,0,0.5)
            }
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

            anchors {
                top: parent.top
                left: parent.left
            }
            height: panelBackground.height

            mouseArea {
                onClicked: root.searchClicked()
            }
            Rectangle {
                anchors.fill: search.mouseArea
                color: Qt.rgba(1,0,0,0.5)
            }
        }
    }

    states: [
        State {
            name: "in" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
            PropertyChanges { target: indicatorArea; y: callHint.y + callHint.height }
            PropertyChanges { target: callHint; z: 0 }
        },
        State {
            name: "out" //pushed off screen
            when: fullscreenMode
            PropertyChanges { target: indicatorArea; y: callHint.y + callHint.height - indicatorHeight }
            PropertyChanges { target: callHint; z: 2 }
        }
    ]
}
