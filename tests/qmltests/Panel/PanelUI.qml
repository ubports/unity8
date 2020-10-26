/*
 * Copyright 2013-2015 Canonical Ltd.
 * Copyright 2020 UBports Foundation
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
import QtQuick.Layouts 1.1
import QtTest 1.0
import Unity.Test 0.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Application 0.1
import QMenuModel 0.1
import Ubuntu.Telephony 0.1 as Telephony
import AccountsService 0.1
import Unity.InputInfo 0.1
import "../../../qml/Panel"
import "../../../qml/Components/PanelState"
import "../Stage"
import ".."

PanelTest {
    id: root
    width: units.gu(120)
    height: units.gu(71)
    color: "black"

    property alias panel: panel
    property alias mouseEmulation: mouseEmulation
    property alias appMenuData: appMenuData
    property alias aboutToShowCalledSpy: aboutToShowCalledSpy
    property alias itemArea: itemArea
    property alias backgroundMouseArea: backgroundMouseArea
    property alias phoneCall: phoneCall

    Binding {
        target: QuickUtils
        property: "keyboardAttached"
        value: keyboardAttached.checked
    }

    SurfaceManager { id: sMgr }
    ApplicationMenuDataLoader {
        id: appMenuData
        surfaceManager: sMgr
    }

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    Rectangle {
        anchors.fill: parent
        color: "darkgrey"
    }

    SignalSpy {
        id: aboutToShowCalledSpy
        signalName: "aboutToShowCalled"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        clip: true

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: backgroundMouseArea.pressed ? "black" : "gray"

            MouseArea {
                id: backgroundMouseArea
                anchors.fill: parent
                hoverEnabled: true

                Panel {
                    id: panel
                    anchors.fill: parent
                    mode: modeSelector.model[modeSelector.selectedIndex]

                    applicationMenus {
                        model: menuData.checked ? menuModel : null

                        readonly property var menuModel: UnityMenuModel {
                            modelData: appMenuData.generateTestData(10, 4, 2, 3, "menu")
                        }

                        hides: [ panel.indicators ]
                    }

                    indicators {
                        model: root.indicatorsModel
                        hides: [ panel.applicationMenus ]
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            ListItem.ItemSelector {
                id: modeSelector
                Layout.fillWidth: true
                activeFocusOnPress: false
                text: "Mode"
                model: ["staged", "windowed" ]
                onSelectedIndexChanged: {
                    panel.mode = model[selectedIndex];
                    keyboardAttached.checked = panel.mode == "windowed"
                    windowControlsCB.checked = panel.mode == "windowed"
                }
            }

            Button {
                Layout.fillWidth: true
                text: panel.indicators.shown ? "Hide Indicators" : "Show Indicators"
                onClicked: {
                    if (panel.indicators.shown) {
                        panel.indicators.hide();
                    } else {
                        panel.indicators.show();
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                text: panel.applicationMenus.shown ? "Hide Menu" : "Show Menu"
                onClicked: {
                    if (panel.applicationMenus.shown) {
                        panel.applicationMenus.hide();
                    } else {
                        panel.applicationMenus.show();
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                text: callManager.hasCalls ? "Remove call" : "Add call"
                onClicked: {
                    if (callManager.foregroundCall) {
                        callManager.foregroundCall = null;
                    } else {
                        callManager.foregroundCall = phoneCall;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: fullscreenCB
                    checked: false
                }
                Label {
                    text: "Main app is fullscreen"
                    color: "white"
                }
            }

            Binding {
                target: panel
                property: "fullscreenMode"
                value: fullscreenCB.checked
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: menuData
                    checked: true
                }
                Label {
                    text: "Application Menu has data"
                    color: "white"
                }
            }

            Binding {
                target: PanelState
                property: "decorationsVisible"
                value: windowControlsCB.checked
            }

            Binding {
                target: PanelState
                property: "title"
                value: "Fake window title"
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: windowControlsCB
                    onClicked: PanelState.decorationsVisible = checked
                }
                Label {
                    text: "Show window decorations"
                    color: "white"
                }
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Repeater {
                model: root.originalModelData
                RowLayout {
                    CheckBox {
                        checked: true
                        onCheckedChanged: checked ? insertIndicator(index) : removeIndicator(index);
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData["identifier"]
                        color: "white"
                    }

                    CheckBox {
                        checked: true
                        onCheckedChanged: setIndicatorVisible(index, checked);
                    }
                    Label {
                        text: "visible"
                        color: "white"
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            MouseTouchEmulationCheckbox {
                id: mouseEmulation
                color: "white"
                checked: panel.mode == "staged"
            }

            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: keyboardAttached
                }
                Label {
                    text: "Keyboard Attached"
                    color: "white"
                }
            }
        }
    }

    Telephony.CallEntry {
        id: phoneCall
        phoneNumber: "+447812221111"
    }
}
