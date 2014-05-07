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
    readonly property real panelHeight: nonIndicatorArea.y + nonIndicatorArea.height
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
            left: parent.left
            right: parent.right
            top: nonIndicatorArea.bottom
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

    PanelBackground {
        anchors.fill: nonIndicatorArea
    }

    Item {
        id: nonIndicatorArea
        objectName: "indicatorArea"

        anchors {
            top: callHint.bottom
            left: parent.left
            right: parent.right
        }
        height: d.indicatorHeight

        PanelSeparatorLine {
            id: leftSeparatorLine
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            saturation: 1 - indicators.unitProgress
        }

        MouseArea {
            id: nonIndicatorMouseArea
            enabled: callHint.active
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: indicators.panelHeight/2
            onClicked: callHint.activate();
        }
    }

    // eater
    MouseArea {
        anchors.fill: callHint
        onClicked: callHint.activate()
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"

        anchors {
            top: callHint.bottom
            right: parent.right
            bottom: parent.bottom
        }
        width: indicators.width

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

                topMargin: nonIndicatorArea.anchors.topMargin + indicators.panelHeight
            }

            width: units.dp(2)
            source: "graphics/VerticalDivider.png"
        }

        PanelBackground {
            anchors.fill: indicators
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
            openedHeight: root.height - (callHint.y + callHint.height)
            overFlowWidth: search.state=="hidden" ? root.width : root.width - search.width

            enableHint: !callHint.active && !fullscreenMode
            showHintBottomMargin: fullscreenMode ? -panelHeight : 0
            showHintHeightOffset: callHint.active ? callHint.height : 0

            onShowTapped: {
                if (callHint.active) {
                    var callHintScenePosition = callHint.mapToItem(null, callHint.x, callHint.y);
                    var indicatorScenePosition = mapToItem(null, x, y);

                    // tapped on callHint
                    if (position.y > callHintScenePosition.y && position.y <= callHintScenePosition.y + callHint.height) {
                        callHint.activate();
                    // tapped on top half of indicator
                    } else  if (!fullscreenMode && position.y > indicatorScenePosition.y && position.y < indicatorScenePosition.y + panelHeight/2) {
                        callHint.activate();
                    }
                }
            }
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

    SearchIndicator {
        id: search
        objectName: "search"
        enabled: root.searchVisible

        state: {
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
            top: nonIndicatorArea.top
            bottom: nonIndicatorArea.bottom
            left: nonIndicatorArea.left
        }

        mouseArea {
            onClicked: root.searchClicked()
        }
    }

    ActiveCallHint {
        id: __callHint
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
        Behavior on y { StandardAnimation {} }
    }

    QtObject {
        id: d
        readonly property real indicatorHeight: indicators.panelHeight + leftSeparatorLine.height
    }

    states: [
        State {
            name: "onscreen" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
        },
        State {
            name: "offscreen" //pushed off screen
            when: fullscreenMode
            PropertyChanges { target: nonIndicatorArea;  anchors.topMargin: -d.indicatorHeight }
            PropertyChanges { target: indicatorArea;  anchors.topMargin: indicators.state === "initial" ? -d.indicatorHeight : 0 }
        }
    ]

    transitions: [
        Transition {
            to: "onscreen"
            SequentialAnimation {
                ParallelAnimation {
                    StandardAnimation { target: nonIndicatorArea; property: "anchors.topMargin" }
                    StandardAnimation { target: indicatorArea;  property: "anchors.topMargin" }
                }
                PropertyAction { target: search; property: "z"; value: 2 }
                PropertyAction { target: indicatorArea; property: "z"; value: 2 }
            }
        },
        Transition {
            to: "offscreen"
            SequentialAnimation {
                PropertyAction { target: search; property: "z"; value: 0 }
                PropertyAction { target: indicatorArea; property: "z"; value: 0 }
                ParallelAnimation {
                    StandardAnimation { target: nonIndicatorArea; property: "anchors.topMargin" }
                    StandardAnimation { target: indicatorArea;  property: "anchors.topMargin" }
                }
            }
        }
    ]
}
