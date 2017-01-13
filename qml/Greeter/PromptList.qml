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
                readonly property var modelData: model

                sourceComponent: isLabel ? infoLabel : greeterPrompt

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

                Binding {
                    target: loader.item
                    property: "model"
                    value: loader.modelData
                }
            }
        }
    }

    Component {
        id: infoLabel

        FadingLabel {
            objectName: "infoLabel" + model.index
            width: root.width

            property var model
            readonly property bool isPrompt: false

            color: model.type === LightDMService.prompts.Message ? theme.palette.normal.raisedText
                                                          : theme.palette.normal.negative
            fontSize: "small"
            textFormat: Text.PlainText
            text: model.text

            Behavior on opacity { UbuntuNumberAnimation {} }
            opacity: 0
        }
    }

    Component {
        id: greeterPrompt

        GreeterPrompt {
            objectName: "greeterPrompt" + model.index
            width: root.width

            property var model

            interactive: root.interactive
            isAlphanumeric: model.text !== "" || root.alphanumeric
            isPrompt: model.type !== LightDMService.prompts.Button
            isSecret: model.type === LightDMService.prompts.Secret
            text: model.text ? model.text : (isAlphanumeric ? i18n.tr("Passphrase") : i18n.tr("Passcode"))

            onClicked: root.clicked()
            onAccepted: {
                // If there is another GreeterPrompt, focus it.
                for (var i = model.index + 1; i < repeater.count; i++) {
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
