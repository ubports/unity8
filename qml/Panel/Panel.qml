/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import Ubuntu.Layouts 1.0
import Unity.Application 0.1
import Unity.Indicators 0.1
import Utils 0.1
import Unity.ApplicationMenu 0.1

import QtQuick.Window 2.2
// for indicator-keyboard
import AccountsService 0.1
import Unity.InputInfo 0.1

import "../ApplicationMenus"
import "../Components"
import "../Components/PanelState"
import ".."
import "Indicators"

Item {
    id: root
    readonly property real panelHeight: indicatorArea.y + minimizedPanelHeight

    property real minimizedPanelHeight: units.gu(3)
    property real expandedPanelHeight: units.gu(7)
    property real indicatorMenuWidth: width
    property real applicationMenuWidth: width

    property alias applicationMenus: fakeApplicationMenus
    property alias indicators: __indicators
    property bool fullscreenMode: false
    property real indicatorAreaShowProgress: 1.0
    property bool locked: false
    property bool greeterShown: false

    property string mode: "staged"

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: panelHeight
        visible: !indicators.fullyClosed
        enabled: visible
        onClicked: if (indicators.fullyOpened) indicators.hide();
        hoverEnabled: true // should also eat hover events, otherwise they will pass through
    }

    Binding {
        target: PanelState
        property: "panelHeight"
        value: minimizedPanelHeight
    }

    FakePanelMenu {
        id: fakeApplicationMenus
        model: registeredMenuModel.model
    }

    RegisteredApplicationMenuModel {
        id: registeredMenuModel
        persistentSurfaceId: PanelState.focusedPersistentSurfaceId
    }

    Item {
        id: indicatorArea
        objectName: "indicatorArea"

        anchors.fill: parent

        transform: Translate {
            y: indicators.state === "initial"
                ? (1.0 - indicatorAreaShowProgress) * - minimizedPanelHeight
                : 0
        }

        BorderImage {
            id: indicatorsDropShadow
            anchors {
                fill: __indicators
                margins: -units.gu(1)
            }
            visible: !__indicators.fullyClosed
            source: "graphics/rectangular_dropshadow.sci"
        }

        BorderImage {
            id: panelDropShadow
            anchors {
                fill: panelAreaBackground
                bottomMargin: -units.gu(1)
            }
            visible: PanelState.dropShadow && !callHint.visible
            source: "graphics/rectangular_dropshadow.sci"
        }

        Rectangle {
            id: panelAreaBackground
            color: theme.palette.normal.background
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: minimizedPanelHeight

            Behavior on color { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
        }

        Loader {
            id: apppMenuLoader
            sourceComponent: mode == "staged" ? stagedLeftPanelComponent : windowedLeftPanelComponent
            width: parent.width
            height: minimizedPanelHeight

            opacity: root.locked ? 0 : 1
            visible: opacity != 0
            Behavior on opacity { UbuntuNumberAnimation {} }
        }

        Component {
            id: stagedLeftPanelComponent

            MouseArea {
                id: decorationMouseArea
                objectName: "windowControlArea"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: minimizedPanelHeight
                hoverEnabled: !__indicators.shown
                onClicked: {
                    if (callHint.visible) {
                        callHint.showLiveCall();
                    }
                }

                BorderImage {
                    id: applicationMenusDropShadow
                    anchors {
                        fill: __applicationMenus
                        margins: -units.gu(1)
                    }
                    visible: !__applicationMenus.fullyClosed
                    source: "graphics/rectangular_dropshadow.sci"
                }

                PanelMenu {
                    id: __applicationMenus

                    hides: fakeApplicationMenus.hides
                    model: fakeApplicationMenus.model

                    width: root.applicationMenuWidth
                    minimizedPanelHeight: root.minimizedPanelHeight
                    expandedPanelHeight: root.expandedPanelHeight
                    openedHeight: root.height
                    enableHint: !callHint.active && !fullscreenMode
                    showOnClick: !callHint.visible
                    panelColor: callHint.visible ? theme.palette.normal.positive : theme.palette.normal.background
                    alignment: Qt.AlignLeft

                    showRowTitle: !expanded
                    rowTitle: PanelState.title
                    rowItemDelegate: ActionItem {
                        id: actionItem
                        property int ownIndex: index

                        width: _title.width + units.gu(2)
                        height: parent.height

                        action: Action {
                            text: model.label.replace("_", "&")
                        }

                        Label {
                            id: _title
                            anchors.centerIn: parent
                            text: actionItem.text
                            horizontalAlignment: Text.AlignLeft
                            color: enabled ? "white" : "#5d5d5d"
                        }
                    }

                    pageDelegate: PanelMenuPage {
                        id: page
                        menuModel: __applicationMenus.model
                        submenuIndex: modelIndex

                        factory: ApplicationMenuItemFactory {
                            rootModel: __applicationMenus.model
                        }
                    }

                    enabled: !root.locked && model
                    opacity: !indicators.expanded ? 1 : 0
                    visible: opacity != 0
                    Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

                    onEnabledChanged: {
                        if (!enabled) hide();
                    }

                    Binding {
                        target: fakeApplicationMenus
                        property: "expanded"
                        value: __applicationMenus.expanded
                    }

                    Connections {
                        target: fakeApplicationMenus
                        onHide: __applicationMenus.hide();
                        onShow: __applicationMenus.show();
                    }
                }

                ActiveCallHint {
                    id: callHint
                    x: __applicationMenus.x + __applicationMenus.barWidth
                    height: parent.height

                    visible: active && (indicators.state == "initial" && __applicationMenus.state == "initial")
                    greeterShown: root.greeterShown
                }

                Binding {
                    target: __indicators
                    property: "overFlowWidth"
                    value: {
                        var width = root.width;
                        if (callHint.visible) {
                            width -= callHint.width;
                        }
                        if (__applicationMenus.visible) {
                            width -= __applicationMenus.barWidth;
                        }
                        return Math.max(width, 0);
                    }
                }
                Binding {
                    target: panelAreaBackground
                    property: "color"
                    value: callHint.visible ? theme.palette.normal.positive : theme.palette.normal.background
                }
                Binding {
                    target: __indicators
                    property: "enableHint"
                    value: !callHint.active && !__indicators.fullscreenMode
                }
                Binding {
                    target: __indicators
                    property: "showOnClick"
                    value: !callHint.visible
                }
                Connections {
                    target: __indicators
                    onShowTapped: {
                        if (callHint.active) {
                            callHint.showLiveCall();
                        }
                    }
                }
            }
        }

        Component {
            id: windowedLeftPanelComponent

            MouseArea {
                id: decorationMouseArea
                objectName: "windowControlArea"
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: minimizedPanelHeight
                hoverEnabled: !__indicators.shown
                onClicked: if (callHint.visible) { callHint.showLiveCall(); }

                onPressed: {
                    if (!callHint.visible) {
                        // let it fall through to the window decoration of the maximized window behind, if any
                        mouse.accepted = false;
                    }
                }

                property bool showWindowControls: (PanelState.decorationsVisible && (containsMouse || menuBarLoader.menusRequested)) || PanelState.decorationsAlwaysVisible

                // WindowControlButtons inside the mouse area, otherwise QML doesn't grok nested hover events :/
                // cf. https://bugreports.qt.io/browse/QTBUG-32909
                WindowControlButtons {
                    id: windowControlButtons
                    objectName: "panelWindowControlButtons"
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    height: indicators.minimizedPanelHeight
                    opacity: decorationMouseArea.showWindowControls ? 1 : 0
                    visible: opacity != 0
                    Behavior on opacity { UbuntuNumberAnimation {} }

                    active: PanelState.decorationsVisible || PanelState.decorationsAlwaysVisible
                    windowIsMaximized: true
                    onCloseClicked: PanelState.closeClicked()
                    onMinimizeClicked: PanelState.minimizeClicked()
                    onMaximizeClicked: PanelState.restoreClicked()
                    closeButtonShown: PanelState.closeButtonShown
                }

                Loader {
                    id: menuBarLoader
                    anchors {
                        left: windowControlButtons.right
                        leftMargin: units.gu(3)
                    }
                    height: parent.height
                    opacity: windowControlButtons.opacity
                    visible: opacity != 0
                    active: fakeApplicationMenus.model

                    property bool menusRequested: menuBarLoader.item ? menuBarLoader.item.showRequested : false

                    sourceComponent: MenuBar {
                        id: bar
                        height: menuBarLoader.height
                        enableKeyFilter: valid && PanelState.decorationsVisible
                        unityMenuModel: fakeApplicationMenus.model

                        Connections {
                            target: fakeApplicationMenus
                            onHide: bar.dismiss();
                        }
                    }
                }

                Label {
                    id: titleLabel
                    objectName: "windowDecorationTitle"
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    color: "white"
                    opacity: !decorationMouseArea.showWindowControls ? 1 : 0
                    visible: opacity != 0
                    verticalAlignment: Text.AlignVCenter
                    fontSize: "medium"
                    font.weight: PanelState.decorationsVisible ? Font.Light : Font.Medium
                    text: PanelState.title
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    Behavior on opacity { UbuntuNumberAnimation {} }
                }

                ActiveCallHint {
                    id: callHint
                    anchors.centerIn: parent
                    height: minimizedPanelHeight

                    visible: active && indicators.state == "initial"
                    greeterShown: root.greeterShown
                }

                Binding {
                    target: panelAreaBackground
                    property: "color"
                    value: callHint.visible ? theme.palette.normal.positive : theme.palette.normal.background
                }
                Binding {
                    target: __indicators
                    property: "enableHint"
                    value: !callHint.active && !__indicators.fullscreenMode
                }
                Binding {
                    target: __indicators
                    property: "showOnClick"
                    value: !callHint.visible
                }
                Connections {
                    target: __indicators
                    onShowTapped: {
                        if (callHint.active) {
                            callHint.showLiveCall();
                        }
                    }
                }
            }
        }

        PanelMenu {
            id: __indicators
            objectName: "indicators"

            anchors {
                top: parent.top
                right: parent.right
            }
            width: root.indicatorMenuWidth
            minimizedPanelHeight: root.minimizedPanelHeight
            expandedPanelHeight: root.expandedPanelHeight
            openedHeight: root.height

            overFlowWidth: root.width
            enableHint: !fullscreenMode
            showOnClick: true
            panelColor: panelAreaBackground.color

            rowItemDelegate: IndicatorItem {
                id: indicatorItem
                objectName: identifier+"-panelItem"

                property int ownIndex: index
                property bool overflow: parent.width - x > __indicators.overFlowWidth
                property bool hidden: !expanded && (overflow || !indicatorVisible || hideSessionIndicator || hideKeyboardIndicator)
                // HACK for indicator-session
                readonly property bool hideSessionIndicator: identifier == "indicator-session" && Math.min(Screen.width, Screen.height) <= units.gu(60)
                // HACK for indicator-keyboard
                readonly property bool hideKeyboardIndicator: identifier == "indicator-keyboard" && (AccountsService.keymaps.length < 2 || keyboardsModel.count == 0)

                height: parent.height
                expanded: indicators.expanded
                selected: ListView.isCurrentItem

                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath

                opacity: hidden ? 0.0 : 1.0
                Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

                width: ((expanded || indicatorVisible) && !hideSessionIndicator && !hideKeyboardIndicator) ? implicitWidth : 0

                Behavior on width { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
            }

            pageDelegate: PanelMenuPage {
                id: page
                objectName: modelData.identifier + "-page"
                submenuIndex: 0

                menuModel: delegate.menuModel

                factory: IndicatorMenuItemFactory {
                    context: modelData.identifier
                    rootModel: delegate.menuModel
                }

                IndicatorDelegate {
                    id: delegate
                    busName: modelData.indicatorProperties.busName
                    actionsObjectPath: modelData.indicatorProperties.actionsObjectPath
                    menuObjectPath: modelData.indicatorProperties.menuObjectPath
                }
            }

            enabled: !applicationMenus.expanded
            opacity: !applicationMenus.expanded ? 1 : 0
            Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

            onEnabledChanged: {
                if (!enabled) hide();
            }
        }
    }

    InputDeviceModel {
        id: keyboardsModel
        deviceFilter: InputInfo.Keyboard
    }

    IndicatorsLight {
        id: indicatorLights
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
                anchors.topMargin: indicators.state === "initial" ? - minimizedPanelHeight : 0
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
