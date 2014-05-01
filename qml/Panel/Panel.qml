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
    readonly property real panelHeight: callHint.active ? callHint.height + indicatorArea.indicatorHeight : indicatorArea.indicatorHeight
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

        y: active ? 0 : -height
        z: 1

        Behavior on y { StandardAnimation {} }
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"

        readonly property real indicatorHeight: indicatorsMenu.panelHeight + leftSeparatorLine.height

        anchors {
            left: parent.left
            right: parent.right
        }
        height: root.height - indicatorArea.y
        z: 0

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

            anchors {
                top: parent.top
                left: parent.left
            }
            height: panelBackground.height

            onClicked: root.searchClicked()
        }
    }

    states: [
        State {
            name: "in" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
            PropertyChanges { target: indicatorArea; y: callHint.y + callHint.height }
        },
        State {
            name: "out" //pushed off screen
            when: fullscreenMode
            PropertyChanges { target: indicatorArea; y: callHint.y + callHint.height - indicatorHeight }
        }
    ]
}
