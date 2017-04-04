/*
 * Copyright (C) 2013-2017 Canonical, Ltd.
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

import "../ApplicationMenus"
import "../Components"
import "../Components/PanelState"
import ".."
import "Indicators"

Item {
    id: root
    readonly property real panelHeight: panelArea.y + minimizedPanelHeight

    property real minimizedPanelHeight: units.gu(3)
    property real expandedPanelHeight: units.gu(7)
    property real indicatorMenuWidth: width
    property real applicationMenuWidth: width
    property alias applicationMenuContentX: __applicationMenus.menuContentX

    property alias applicationMenus: __applicationMenus
    property alias indicators: __indicators
    property bool fullscreenMode: false
    property real panelAreaShowProgress: 1.0
    property bool greeterShown: false
    property bool hasKeyboard: false

    property string mode: "staged"

    MouseArea {
        id: backMouseEater
        anchors.fill: parent
        anchors.topMargin: panelHeight
        visible: !indicators.fullyClosed || !applicationMenus.fullyClosed
        enabled: visible
        hoverEnabled: true // should also eat hover events, otherwise they will pass through

        onClicked: {
            __applicationMenus.hide();
            __indicators.hide();
        }
    }

    Binding {
        target: PanelState
        property: "panelHeight"
        value: minimizedPanelHeight
    }

    RegisteredApplicationMenuModel {
        id: registeredMenuModel
        persistentSurfaceId: PanelState.focusedPersistentSurfaceId
    }

    QtObject {
        id: d

        property bool revealControls: !greeterShown &&
                                      !applicationMenus.shown &&
                                      !indicators.shown &&
                                      (decorationMouseArea.containsMouse || menuBarLoader.menusRequested)

        property bool showWindowDecorationControls: (revealControls && PanelState.decorationsVisible) ||
                                                    PanelState.decorationsAlwaysVisible

        property bool showPointerMenu: revealControls && enablePointerMenu &&
                                       (PanelState.decorationsVisible || mode == "staged")

        property bool enablePointerMenu: applicationMenus.available &&
                                         applicationMenus.model

        property bool showTouchMenu: !greeterShown &&
                                     !showPointerMenu &&
                                     !showWindowDecorationControls

        property bool enableTouchMenus: showTouchMenu &&
                                        applicationMenus.available &&
                                        applicationMenus.model
    }

    Item {
        id: panelArea
        objectName: "panelArea"

        anchors.fill: parent

        transform: Translate {
            y: indicators.state === "initial"
                ? (1.0 - panelAreaShowProgress) * - minimizedPanelHeight
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
            id: appmenuDropShadow
            anchors {
                fill: __applicationMenus
                margins: -units.gu(1)
            }
            visible: !__applicationMenus.fullyClosed
            source: "graphics/rectangular_dropshadow.sci"
        }

        BorderImage {
            id: panelDropShadow
            anchors {
                fill: panelAreaBackground
                bottomMargin: -units.gu(1)
            }
            visible: PanelState.dropShadow
            source: "graphics/rectangular_dropshadow.sci"
        }

        Rectangle {
            id: panelAreaBackground
            color: callHint.visible ? theme.palette.normal.positive : theme.palette.normal.background
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: minimizedPanelHeight

            Behavior on color { ColorAnimation { duration: UbuntuAnimation.FastDuration } }
        }

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

            onPressed: {
                if (!callHint.visible) {
                    // let it fall through to the window decoration of the maximized window behind, if any
                    mouse.accepted = false;
                }
                var menubar = menuBarLoader.item;
                if (menubar) {
                    menubar.invokeMenu(mouse);
                }
            }

            Row {
                anchors.fill: parent
                spacing: units.gu(2)

                // WindowControlButtons inside the mouse area, otherwise QML doesn't grok nested hover events :/
                // cf. https://bugreports.qt.io/browse/QTBUG-32909
                WindowControlButtons {
                    id: windowControlButtons
                    objectName: "panelWindowControlButtons"
                    height: indicators.minimizedPanelHeight
                    opacity: d.showWindowDecorationControls ? 1 : 0
                    visible: opacity != 0
                    Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

                    active: PanelState.decorationsVisible || PanelState.decorationsAlwaysVisible
                    windowIsMaximized: true
                    onCloseClicked: PanelState.closeClicked()
                    onMinimizeClicked: PanelState.minimizeClicked()
                    onMaximizeClicked: PanelState.restoreClicked()
                    closeButtonShown: PanelState.closeButtonShown
                }

                Loader {
                    id: menuBarLoader
                    objectName: "menuBarLoader"
                    height: parent.height
                    enabled: d.enablePointerMenu
                    opacity: d.showPointerMenu ? 1 : 0
                    visible: opacity != 0
                    Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }
                    active: d.showPointerMenu && !callHint.visible

                    width: parent.width - windowControlButtons.width - units.gu(2) - __indicators.barWidth

                    readonly property bool menusRequested: menuBarLoader.item ? menuBarLoader.item.showRequested : false

                    sourceComponent: MenuBar {
                        id: bar
                        objectName: "menuBar"
                        anchors.left: parent ? parent.left : undefined
                        anchors.margins: units.gu(1)
                        height: menuBarLoader.height
                        enableKeyFilter: valid && PanelState.decorationsVisible
                        unityMenuModel: __applicationMenus.model

                        Connections {
                            target: __applicationMenus
                            onShownChanged: bar.dismiss();
                        }

                        Connections {
                            target: __indicators
                            onShownChanged: bar.dismiss();
                        }

                        onDoubleClicked: PanelState.restoreClicked()
                        onPressed: mouse.accepted = false // let the parent mouse area handle this, so it can both unsnap window and show menu
                    }
                }
            }

            ActiveCallHint {
                id: callHint
                objectName: "callHint"

                anchors.centerIn: parent
                height: minimizedPanelHeight

                visible: active && indicators.state == "initial" && __applicationMenus.state == "initial"
                greeterShown: root.greeterShown
            }
        }

        PanelMenu {
            id: __applicationMenus

            x: menuContentX
            model: registeredMenuModel.model
            width: root.applicationMenuWidth
            minimizedPanelHeight: root.minimizedPanelHeight
            expandedPanelHeight: root.expandedPanelHeight
            openedHeight: root.height
            alignment: Qt.AlignLeft
            enableHint: !callHint.active && !fullscreenMode
            showOnClick: false
            adjustDragHandleSizeToContents: false
            panelColor: panelAreaBackground.color

            onShowTapped: {
                if (callHint.active) {
                    callHint.showLiveCall();
                }
            }

            hideRow: !expanded
            rowItemDelegate: ActionItem {
                id: actionItem
                property int ownIndex: index
                objectName: "appMenuItem"+index
                enabled: model.sensitive

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
                    color: enabled ? theme.palette.normal.backgroundText : theme.palette.disabled.backgroundText
                }
            }

            pageDelegate: PanelMenuPage {
                readonly property bool isCurrent: modelIndex == __applicationMenus.currentMenuIndex
                onIsCurrentChanged: {
                    if (isCurrent && menuModel) {
                        menuModel.aboutToShow(modelIndex);
                    }
                }

                menuModel: __applicationMenus.model
                submenuIndex: modelIndex

                factory: ApplicationMenuItemFactory {
                    rootModel: __applicationMenus.model
                }
            }

            enabled: d.enableTouchMenus
            opacity: d.showTouchMenu ? 1 : 0
            visible: opacity != 0
            Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

            onEnabledChanged: {
                if (!enabled) hide();
            }
        }

        Label {
            id: rowLabel
            objectName: "panelTitle"
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: __indicators.left
                rightMargin: units.gu(1)
            }
            height: root.minimizedPanelHeight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
            fontSize: "medium"
            font.weight: Font.Medium
            color: theme.palette.selected.backgroundText
            opacity: __applicationMenus.visible && !__applicationMenus.expanded ? 1 : 0
            visible: opacity != 0
            Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.SnapDuration } }
            text: PanelState.title
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
            enableHint: !callHint.active && !fullscreenMode
            showOnClick: !callHint.visible
            panelColor: panelAreaBackground.color

            onShowTapped: {
                if (callHint.active) {
                    callHint.showLiveCall();
                }
            }

            rowItemDelegate: IndicatorItem {
                id: indicatorItem
                objectName: identifier+"-panelItem"

                property int ownIndex: index
                readonly property bool overflow: parent.width - x > __indicators.overFlowWidth
                readonly property bool hidden: !expanded && (overflow || !indicatorVisible || hideSessionIndicator || hideKeyboardIndicator)
                // HACK for indicator-session
                readonly property bool hideSessionIndicator: identifier == "indicator-session" && Math.min(Screen.width, Screen.height) <= units.gu(60)
                // HACK for indicator-keyboard
                readonly property bool hideKeyboardIndicator: identifier == "indicator-keyboard" && !hasKeyboard

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
                objectName: modelData.identifier + "-page"
                submenuIndex: 0

                menuModel: delegate.menuModel

                factory: IndicatorMenuItemFactory {
                    indicator: {
                        var context = modelData.identifier;
                        if (context && context.indexOf("fake-") === 0) {
                            context = context.substring("fake-".length)
                        }
                        return context;
                    }
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
            opacity: !callHint.visible && !applicationMenus.expanded ? 1 : 0
            Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

            onEnabledChanged: {
                if (!enabled) hide();
            }
        }
    }

    IndicatorsLight {
        id: indicatorLights
    }

    states: [
        State {
            name: "onscreen" //fully opaque and visible at top edge of screen
            when: !fullscreenMode
            PropertyChanges {
                target: panelArea;
                anchors.topMargin: 0
                opacity: 1;
            }
        },
        State {
            name: "offscreen" //pushed off screen
            when: fullscreenMode
            PropertyChanges {
                target: panelArea;
                anchors.topMargin: {
                    if (indicators.state !== "initial") return 0;
                    if (applicationMenus.state !== "initial") return 0;
                    return -minimizedPanelHeight;
                }
                opacity: indicators.fullyClosed && applicationMenus.fullyClosed ? 0.0 : 1.0
            }
            PropertyChanges {
                target: indicators.showDragHandle;
                anchors.bottomMargin: -units.gu(1)
            }
            PropertyChanges {
                target: applicationMenus.showDragHandle;
                anchors.bottomMargin: -units.gu(1)
            }
        }
    ]

    transitions: [
        Transition {
            to: "onscreen"
            UbuntuNumberAnimation { target: panelArea; properties: "anchors.topMargin,opacity" }
        },
        Transition {
            to: "offscreen"
            UbuntuNumberAnimation { target: panelArea; properties: "anchors.topMargin,opacity" }
        }
    ]
}
