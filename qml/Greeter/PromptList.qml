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
import AccountsService 0.1
import "../Components"
import "." 0.1

FocusScope {
    id: root
    height: childrenRect.height

    property bool isLandscape
    property string usageMode
    property bool alphanumeric: true
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false
    // don't allow custom pincode prompt for multi user in phone context as it will hide the login list
    readonly property string pinCodeManager: LightDMService.users.count > 1  && root.usageMode === "phone" && root.isLandscape ? AccountsService.defaultPinCodePromptManager : AccountsService.pinCodePromptManager

    property real defaultPromptWidth: units.gu(20)
    property real maxPromptHeight: isLandscape ? root.width - units.gu(10) : root.width

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
                // we want to have properties set at component loading time
                readonly property var modelText: model.text
                readonly property var modelType: model.type
                readonly property var modelIndex: model.index

                sourceComponent: isLabel ? infoLabel : greeterPrompt
                anchors.horizontalCenter: parent.horizontalCenter

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
             width: root.defaultPromptWidth

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
            width: isAlternativePinPrompt ? root.width : root.defaultPromptWidth
            implicitHeight:  isAlternativePinPrompt ? root.maxPromptHeight : units.gu(5)

            property bool isAlphanumeric: modelText !== "" || root.alphanumeric
            property bool isAlternativePinPrompt:  (isPinPrompt && pinCodeManager !== AccountsService.defaultPinCodePromptManager)

            interactive: root.interactive
            pinCodeManager: root.pinCodeManager
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
