/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "../Components"
import "../Components/PanelState"
import ".."

Item {
    id: root
    readonly property real panelHeight: indicatorArea.y + d.indicatorHeight
    property alias indicators: __indicators
    property alias callHint: __callHint
    property bool fullscreenMode: false
    property real indicatorAreaShowProgress: 1.0
    property bool locked: false

    Rectangle {
        id: darkenedArea
        property real darkenedOpacity: 0.6
        anchors {
            fill: parent
            topMargin: panelHeight
        }
        color: "black"
        opacity: indicators.unitProgress * darkenedOpacity
        visible: !indicators.fullyClosed

        MouseArea {
            anchors.fill: parent
            onClicked: if (indicators.fullyOpened) indicators.hide();
            hoverEnabled: true // should also eat hover events, otherwise they will pass through
        }
    }

    Binding {
        target: PanelState
        property: "panelHeight"
        value: indicators.minimizedPanelHeight
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"

        anchors.fill: parent

        transform: Translate {
            y: indicators.state === "initial"
                ? (1.0 - indicatorAreaShowProgress) * -d.indicatorHeight
                : 0
        }

        BorderImage {
            id: indicatorsDropShadow
            anchors {
                fill: indicators
                leftMargin: -units.gu(1)
                bottomMargin: -units.gu(1)
            }
            visible: !indicators.fullyClosed
            source: "graphics/rectangular_dropshadow.sci"
        }

        BorderImage {
            id: panelDropShadow
            anchors {
                fill: indicatorAreaBackground
                bottomMargin: -units.gu(1)
            }
            visible: PanelState.dropShadow && !callHint.visible
            source: "graphics/rectangular_dropshadow.sci"
        }

        Rectangle {
            id: indicatorAreaBackground
            color: callHint.visible ? UbuntuColors.green : theme.palette.normal.background
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: indicators.minimizedPanelHeight

            Behavior on color { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
        }

        MouseArea {
            anchors {
                top: parent.top
                left: parent.left
                right: indicators.left
            }
            height: indicators.minimizedPanelHeight
            hoverEnabled: true
            onClicked: callHint.visible ? callHint.showLiveCall() : PanelState.focusMaximizedApp()
            onDoubleClicked: PanelState.restoreClicked()

            // WindowControlButtons inside the mouse area, otherwise QML doesn't grok nested hover events :/
            // cf. https://bugreports.qt.io/browse/QTBUG-32909
            WindowControlButtons {
                id: windowControlButtons
                objectName: "panelWindowControlButtons"
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: units.gu(1)
                    topMargin: units.gu(0.5)
                    bottomMargin: units.gu(0.5)
                }
                height: indicators.minimizedPanelHeight - anchors.topMargin - anchors.bottomMargin
                visible: PanelState.buttonsVisible && parent.containsMouse && !root.locked && !callHint.visible
                active: PanelState.buttonsVisible
                onCloseClicked: PanelState.closeClicked()
                onMinimizeClicked: PanelState.minimizeClicked()
                onMaximizeClicked: PanelState.restoreClicked()
                closeButtonShown: PanelState.closeButtonShown
            }
        }

        IndicatorsMenu {
            id: __indicators
            objectName: "indicators"

            anchors {
                top: parent.top
                right: parent.right
            }

            shown: false
            width: root.width - (windowControlButtons.visible ? windowControlButtons.width + titleLabel.width : 0)
            minimizedPanelHeight: units.gu(3)
            expandedPanelHeight: units.gu(7)
            openedHeight: root.height

            overFlowWidth: {
                if (callHint.visible) {
                    return Math.max(root.width - (callHint.width + units.gu(2)), 0)
                }
                return root.width
            }
            enableHint: !callHint.active && !fullscreenMode
            showOnClick: !callHint.visible
            panelColor: indicatorAreaBackground.color

            onShowTapped: {
                if (callHint.active) {
                    callHint.showLiveCall();
                }
            }
        }

        Label {
            id: titleLabel
            objectName: "windowDecorationTitle"
            anchors {
                left: parent.left
                right: __indicators.left
                top: parent.top
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
                topMargin: units.gu(0.5)
                bottomMargin: units.gu(0.5)
            }
            color: "white"
            height: indicators.minimizedPanelHeight - anchors.topMargin - anchors.bottomMargin
            visible: !windowControlButtons.visible && !root.locked && !callHint.visible
            verticalAlignment: Text.AlignVCenter
            fontSize: "medium"
            font.weight: PanelState.buttonsVisible ? Font.Light : Font.Medium
            text: PanelState.title
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // TODO here would the Locally integrated menus come

        ActiveCallHint {
            id: __callHint
            anchors {
                top: parent.top
                left: parent.left
            }
            height: indicators.minimizedPanelHeight
            visible: active && indicators.state == "initial"
        }
    }

    QtObject {
        id: d
        objectName: "panelPriv"
        readonly property real indicatorHeight: indicators.minimizedPanelHeight
    }

    states: [
        State {
            name: "onscreen" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
            PropertyChanges {
                target: indicatorArea;
                anchors.topMargin: 0
                opacity: 1;
            }
        },
        State {
            name: "offscreen" //pushed off screen
            when: fullscreenMode
            PropertyChanges {
                target: indicatorArea;
                anchors.topMargin: indicators.state === "initial" ? -d.indicatorHeight : 0
                opacity: indicators.fullyClosed ? 0.0 : 1.0
            }
            PropertyChanges {
                target: indicators.showDragHandle;
                anchors.bottomMargin: -units.gu(1)
            }
        }
    ]

    transitions: [
        Transition {
            to: "onscreen"
            UbuntuNumberAnimation { target: indicatorArea; properties: "anchors.topMargin,opacity" }
        },
        Transition {
            to: "offscreen"
            UbuntuNumberAnimation { target: indicatorArea; properties: "anchors.topMargin,opacity" }
        }
    ]
}
