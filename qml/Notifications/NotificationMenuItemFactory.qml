/*
 * Copyright 2013-2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import QMenuModel 0.1
import "../Components"

Loader {
    id: menuFactory

    property QtObject menuModel: null
    property QtObject menuData: null
    property int menuIndex : -1
    property int maxHeight
    readonly property bool fullscreen: menuData.type === "com.canonical.snapdecision.pinlock"
    property url background: ""

    signal accepted()

    property var _map:  {
        "com.canonical.snapdecision.textfield": textfield,
        "com.canonical.snapdecision.pinlock" : pinLock,
    }

    sourceComponent: {
        if (menuData.type !== undefined) {
            var component = _map[menuData.type];
            if (component !== undefined) {
                if (component === pinLock && shell.hasLockedApp) {
                    // In case we are in emergency mode, just skip this unlock.
                    // Happens with two locked SIMs but the user clicks
                    // Emergency Call on the first unlock dialog.
                    // TODO: if we ever allow showing the indicators in
                    // emergency mode, we'll need to differentiate between
                    // user-initiated ones which we *do* want to show and the
                    // dialogs that appear on boot, which we don't.  But for
                    // now we can get away with skipping all such dialogs.
                    menuModel.activate(menuIndex, false);
                    return null;
                }
                return component;
            }
        }
    }

    function getExtendedProperty(object, propertyName, defaultValue) {
        if (object && object.hasOwnProperty(propertyName)) {
            return object[propertyName];
        }
        return defaultValue;
    }

    Component {
        id: textfield

        Column {
            spacing: notification.margins

            anchors {
                left: parent.left
                right: parent.right
                margins: spacing
            }

            Component.onCompleted: {
                menuModel.loadExtendedAttributes(menuIndex, {"x-echo-mode-password": "bool"});
                checkBox.checked = menuData.ext.xEchoModePassword ? false : true
                checkBoxRow.visible = menuData.ext.xEchoModePassword
            }

            Label {
                text: menuData.label
                color: theme.palette.normal.backgroundSecondaryText
            }

            TextField {
                // TODO using Qt.ImhNoPredictiveText here until lp #1291575 is fixed for ubuntu-ui-toolkit
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                anchors {
                    left: parent.left
                    right: parent.right
                }
                echoMode: checkBox.checked ? TextInput.Normal : TextInput.Password
                height: units.gu(5)
                Component.onCompleted: {
                    forceActiveFocus();
                }
                onTextChanged: {
                    menuModel.changeState(menuIndex, text);
                }
                onAccepted: {
                    menuFactory.accepted()
                }
            }

            Row {
                id: checkBoxRow

                spacing: notification.margins

                CheckBox {
                    id: checkBox

                    checked: false
                    activeFocusOnPress: false
                }

                Label {
                    anchors.verticalCenter: checkBox.verticalCenter
                    text: i18n.tr("Show password")
                    color: theme.palette.normal.backgroundSecondaryText

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { checkBox.checked = !checkBox.checked }
                    }
                }
            }
        }
    }

    Component {
        id: pinLock

        Lockscreen {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: menuFactory.maxHeight
            infoText: notification.summary
            errorText: errorAction.valid ? errorAction.state : ""
            retryText: notification.body
            background: menuFactory.background
            darkenBackground: 0.4

            onEntered: {
                menuModel.changeState(menuIndex, passphrase);
                clear(false);
            }

            onCancel: {
                menuModel.activate(menuIndex, false);
            }

            onEmergencyCall: {
                shell.startLockedApp("dialer-app");
                menuModel.activate(menuIndex, false);
            }

            property var extendedData: menuData && menuData.ext || undefined

            property var pinMinMaxAction : UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPinMinMax", "")

                onStateChanged: {
                    var min = pinMinMaxAction.state[0];
                    var max =  pinMinMaxAction.state[1];

                    if (min === 0) min = -1;
                    if (max === 0) max = -1;

                    minPinLength = min
                    maxPinLength = max
                }
            }

            property var popupAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPinPopup", "")
                onStateChanged: {
                    if (state !== "")
                        showInfoPopup("", state);
                }
            }
            onInfoPopupConfirmed: {
                popupAction.activate();
            }

            Timer {
                id: errorTimer
                interval: 4000;
                running: false;
                repeat: false
                onTriggered: {
                    errorAction.activate();
                }
            }
            property var errorAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPinError", "")
                onStateChanged: {
                    errorText = state;
                    if (state !== "") {
                        clear(true);
                        errorTimer.running = true;
                    }
                }
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-pin-min-max': 'string',
                                                             'x-canonical-pin-popup': 'string',
                                                             'x-canonical-pin-error': 'string'});
            }
            Component.onCompleted: {
                loadAttributes();
            }
        }
    }
}
