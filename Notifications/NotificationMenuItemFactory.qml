/*
 * Copyright 2013 Canonical Ltd.
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
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
import "../Greeter"

Loader {
    id: menuFactory

    property QtObject menuModel: null
    property QtObject menuData: null
    property int menuIndex
    property var notification

    property var _map:  {
        "com.canonical.snapdecision.textfield": textfield,
        "com.canonical.snapdecision.pinlock" : pinLock,
    }

    sourceComponent: {
        if (menuData.type !== undefined) {
            var component = _map[menuData.type];
            if (component !== undefined) {
                return component;
            }
        }
    }

    Component {
        id: textfield

        Column {
            spacing: units.gu(2)

            anchors.left: parent.left; anchors.right: parent.right

            Component.onCompleted: {
                menuModel.loadExtendedAttributes(menuIndex, {"x-echo-mode-password": "bool"});
                textfield.echoMode = menuData.ext.xEchoModePassword ? TextInput.Password : TextInput.Normal
            }

            Label {
                text: menuData.label
            }

            TextField {
                id: textfield

                anchors.left: parent.left; anchors.right: parent.right
                height: units.gu(5)
                onTextChanged: {
                    menuModel.changeState(menuIndex, text);
                }
            }
        }
    }

    Component {
        id: pinLock

        Lockscreen {
            anchors.left: parent.left; anchors.right: parent.right
            height: units.gu(60)
            skipBackground: true

            Component.onCompleted: {
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-pin-length': 'int'});
                pinLength = menuData.ext.xCanonicalPinLength;
            }

            onEntered: {
                menuModel.changeState(menuIndex, passphrase);
                entryEnabled = false;
            }

            onCancel: {
                menuModel.activate(menuIndex, false);
            }
        }
    }
}
