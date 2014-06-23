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
import "../Components/ListItems"

Item {
    id: root
    readonly property real panelHeight: indicatorArea.y + d.indicatorHeight
    property alias indicators: __indicators
    property alias callHint: __callHint
    property bool fullscreenMode: false
    property bool searchVisible: true

    signal searchClicked

    function hideIndicatorMenu(delay) {
        if (delay !== undefined) {
            hideTimer.interval = delay;
            hideTimer.start();
        } else {
            indicators.hide();
        }
    }

    Timer {
        id: hideTimer
        running: false
        onTriggered: {
            indicators.hide();
        }
    }

    Connections {
        target: indicators
        onShownChanged: hideTimer.stop()
    }

    Rectangle {
        id: darkenedArea
        property real darkenedOpacity: 0.6
        anchors {
            top: parent.top
            topMargin: panelHeight
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: "black"
        opacity: indicators.unitProgress * darkenedOpacity

        MouseArea {
            anchors.fill: parent
            enabled: indicators.shown
            onClicked: if (indicators.fullyOpened) indicators.hide();
        }
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"

        anchors.fill: parent

        Behavior on anchors.topMargin { StandardAnimation {} }

        BorderImage {
            id: dropShadow
            anchors {
                fill: indicators
                leftMargin: -units.gu(1)
                bottomMargin: -units.gu(1)
            }
            visible: indicators.height > indicators.panelHeight
            source: "graphics/rectangular_dropshadow.sci"
        }

        VerticalThinDivider {
            id: indicatorDividor
            anchors {
                top: indicators.top
                bottom: indicators.bottom
                right: indicators.left

                topMargin: indicatorArea.anchors.topMargin + indicators.panelHeight
            }

            width: units.dp(2)
            source: "graphics/VerticalDivider.png"
        }

        Rectangle {
            id: indicatorAreaBackground
            color: callHint.visible ? "green" : "black"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: indicators.panelHeight

            Behavior on color { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
        }

        PanelSeparatorLine {
            id: nonIndicatorAreaSeparatorLine
            anchors {
                top: indicatorAreaBackground.bottom
                left: parent.left
                right: indicators.left
            }
            saturation: 1 - indicators.unitProgress
        }

        MouseArea {
            anchors {
                top: parent.top
                left: parent.left
                right: indicators.left
            }
            height: indicators.panelHeight
            enabled: callHint.visible
            onClicked: callHint.activate()
        }

        Indicators {
            id: __indicators
            objectName: "indicators"

            anchors {
                top: parent.top
                right: parent.right
            }

            width: (root.width > units.gu(60)) ? units.gu(40) : root.width
            shown: false
            panelHeight: units.gu(3)
            openedHeight: root.height
            overFlowWidth: {
                if (callHint.visible) {
                    return Math.max(root.width - (callHint.width + units.gu(2)), 0)
                }
                return search.state=="hidden" ? root.width : root.width - search.width
            }

            enableHint: !callHint.active && !fullscreenMode
            showHintBottomMargin: fullscreenMode ? -panelHeight : 0

            onShowTapped: {
                if (callHint.active) {
                    callHint.activate();
                }
            }
        }

        SearchIndicator {
            id: search
            objectName: "search"
            enabled: root.searchVisible

            state: {
                if (callHint.visible) {
                    return "hidden"
                }
                if (parent.width < indicators.width + width) {
                    if (indicators.state != "initial") {
                        return "hidden";
                    }
                }
                if (root.searchVisible && !indicators.showAll) {
                    return "visible";
                }
                return "hidden";
            }
            anchors {
                top: parent.top
                left: parent.left
            }
            height: indicators.panelHeight

            mouseArea {
                onClicked: root.searchClicked()
            }
        }

        ActiveCallHint {
            id: __callHint
            anchors {
                top: parent.top
                left: parent.left
            }
            height: indicators.panelHeight
            visible: active && indicators.state == "initial"
        }

        PanelSeparatorLine {
            id: indicatorsSeparatorLine
            visible: true
            anchors {
                top: indicators.bottom
                left: indicatorDividor.left
                right: indicators.right
            }
        }
    }

    QtObject {
        id: d
        readonly property real indicatorHeight: indicators.panelHeight + indicatorsSeparatorLine.height
    }

    states: [
        State {
            name: "onscreen" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
        },
        State {
            name: "offscreen" //pushed off screen
            when: fullscreenMode
            PropertyChanges { target: indicatorArea;  anchors.topMargin: indicators.state === "initial" ? -d.indicatorHeight : 0 }
        }
    ]
}
