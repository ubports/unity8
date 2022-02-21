/*
 * Copyright (C) 2017 Canonical, Ltd.
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
import "../Components"
import "." 0.1

FocusScope {
    id: root
    height: childrenRect.height

    property bool alphanumeric: true
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false

    signal responded(string text)
    signal clicked()
    signal canceled()

    function showFakePassword() {
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i).item;
            if (item.isPrompt) {
                item.showFakePassword();
            }
        }
    }

    QtObject {
        id: d

        function sendResponse() {
            for (var i = 0; i < repeater.count; i++) {
                var item = repeater.itemAt(i).item;
                if (item.isPrompt) {
                    root.responded(item.enteredText);
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: units.gu(0.5)

        Repeater {
            id: repeater
            model: LightDMService.prompts

            delegate: Loader {
                id: loader

                readonly property bool isLabel: model.type == LightDMService.prompts.Message ||
                                                model.type == LightDMService.prompts.Error
                readonly property var modelText: model.text
                readonly property var modelType: model.type
                readonly property var modelIndex: model.index

                sourceComponent: isLabel ? infoLabel : greeterPrompt

                active: root.visible

                onLoaded: {
                    for (var i = 0; i < repeater.count; i++) {
                        var item = repeater.itemAt(i);
                        if (item && !item.isLabel) {
                            item.focus = true;
                            break;
                        }
                    }
                    loader.item.opacity = 1;
                }
            }
        }
    }

    Component {
        id: infoLabel

        FadingLabel {
            objectName: "infoLabel" + modelIndex
            width: root.width

            readonly property bool isPrompt: false

            color: modelType === LightDMService.prompts.Message ? theme.palette.normal.raisedSecondaryText
                                                          : theme.palette.normal.negative
            fontSize: "small"
            textFormat: Text.PlainText
            text: modelText

            visible: modelType === LightDMService.prompts.Message

            Behavior on opacity { UbuntuNumberAnimation {} }
            opacity: 0
        }
    }

    Component {
        id: greeterPrompt

        GreeterPrompt {
            objectName: "greeterPrompt" + modelIndex
            width: root.width

            property bool isAlphanumeric: modelText !== "" || root.alphanumeric

            interactive: root.interactive
            isPrompt: modelType !== LightDMService.prompts.Button
            isSecret: modelType === LightDMService.prompts.Secret
            isPinPrompt: isPrompt && !isAlphanumeric && isSecret
            loginError: root.loginError
            hasKeyboard: root.hasKeyboard
            text: modelText ? modelText : (isAlphanumeric ? i18n.tr("Passphrase") : i18n.tr("Passcode"))

            onClicked: root.clicked()
            onAccepted: {
                // If there is another GreeterPrompt, focus it.
                for (var i = modelIndex + 1; i < repeater.count; i++) {
                    var item = repeater.itemAt(i).item;
                    if (item.isPrompt) {
                        item.forceActiveFocus();
                        return;
                    }
                }

                // Nope we're the last one; just send our response.
                d.sendResponse();
            }
            onCanceled: root.canceled()

            Behavior on opacity { UbuntuNumberAnimation {} }
            opacity: 0
        }
    }
}
