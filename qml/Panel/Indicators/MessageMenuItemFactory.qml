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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Settings.Menus 0.1 as Menus
import QMenuModel 0.1 as QMenuModel
import Utils 0.1 as Utils

Loader {
    id: messageFactoryItem
    objectName: "messageItem"
    property var menuModel: null
    property QtObject menuData: null
    property int menuIndex: -1

    property bool selected: false
    signal menuSelected
    signal menuDeselected

    property var extendedData: menuData && menuData.ext || undefined
    property var actionsDescription: getExtendedProperty(extendedData, "xCanonicalMessageActions", undefined)

    // TODO - bug #1260728
    property var timeFormatter: Utils.RelativeTimeFormatter {
        time: getExtendedProperty(extendedData, "xCanonicalTime", 0) / 1000000
    }

    onMenuModelChanged: {
        loadAttributes();
    }
    onMenuIndexChanged: {
        loadAttributes();
    }

    sourceComponent: loadMessage(actionsDescription)

    function loadMessage(actions)
    {
        var parameterType = ""
        for (var actIndex in actions) {
            var desc = actions[actIndex];
            if (desc["parameter-type"] !== undefined) {
                parameterType += desc["parameter-type"];
            } else {
                parameterType += "_";
            }
        }

        if (parameterType === "") {
            return simpleMessage;
        } else if (parameterType === "s") {
            return textMessage;
        } else if (parameterType === "_s") {
            return snapDecision;
        } else {
            console.debug("Unknown paramater type: " + parameterType);
        }
        return undefined;
    }

    function loadAttributes() {
        if (!menuModel || menuIndex == -1) return;
        menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-time': 'int64',
                                                     'x-canonical-text': 'string',
                                                     'x-canonical-message-actions': 'variant',
                                                     'icon': 'icon',
                                                     'x-canonical-app-icon': 'icon'});
    }

    function getExtendedProperty(object, propertyName, defaultValue) {
        if (object && object.hasOwnProperty(propertyName)) {
            return object[propertyName];
        }
        return defaultValue;
    }

    Component {
        id: simpleMessage

        Menus.SimpleMessageMenu {
            id: message
            objectName: "simpleTextMessage"
            // text
            title: menuData && menuData.label || ""
            time: timeFormatter.timeString
            body: getExtendedProperty(extendedData, "xCanonicalText", "")
            // icons
            avatar: getExtendedProperty(extendedData, "icon", "image://theme/contact")
            icon: getExtendedProperty(extendedData, "xCanonicalAppIcon", "image://theme/message")
            // actions
            enabled: menuData && menuData.sensitive || false
            removable: !selected
            confirmRemoval: true
            selected: messageFactoryItem.selected

            onIconActivated: {
                menuModel.activate(menuIndex, true);
            }
            onDismissed: {
                menuModel.activate(menuIndex, false);
            }
            onTriggered: {
                if (selected) {
                    menuDeselected();
                } else {
                    menuSelected();
                }
            }
        }
    }

    Component {
        id: textMessage

        Menus.TextMessageMenu {
            id: message
            objectName: "textMessage"
            property var replyActionDescription: actionsDescription && actionsDescription.length > 0 ? actionsDescription[0] : undefined

            property var replyAction: QMenuModel.UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(replyActionDescription, "name", "")
            }

            // text
            title: menuData && menuData.label || ""
            time: timeFormatter.timeString
            body: getExtendedProperty(extendedData, "xCanonicalText", "")
            replyButtonText: getExtendedProperty(replyActionDescription, "label", i18n.tr("Send"))
            replyHintText: i18n.ctr("Label: Hint in message indicator line edit", "Reply")
            // icons
            avatar: getExtendedProperty(extendedData, "icon", "image://theme/contact")
            icon: getExtendedProperty(extendedData, "xCanonicalAppIcon", "image://theme/message")
            // actions
            replyEnabled: replyAction.valid && replyAction.enabled
            enabled: menuData && menuData.sensitive || false
            removable: !selected
            confirmRemoval: true
            selected: messageFactoryItem.selected
            highlightWhenPressed: false

            onIconActivated: {
                menuModel.activate(menuIndex, true);
            }
            onDismissed: {
                menuModel.activate(menuIndex, false);
            }
            onReplied: {
                replyAction.activate(value);
            }
            onTriggered: {
                if (selected) {
                    menuDeselected();
                } else {
                    menuSelected();
                }
            }
        }
    }

    Component {
        id: snapDecision

        Menus.SnapDecisionMenu {
            id: message
            objectName: "snapDecision"
            property var activateActionDescription: actionsDescription && actionsDescription.length > 0 ? actionsDescription[0] : undefined
            property var replyActionDescription: actionsDescription && actionsDescription.length > 1 ? actionsDescription[1] : undefined

            property var activateAction: QMenuModel.UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(activateActionDescription, "name", "")
            }
            property var replyAction: QMenuModel.UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(replyActionDescription, "name", "")
            }

            // text
            title: menuData && menuData.label || ""
            time: timeFormatter.timeString
            body: getExtendedProperty(extendedData, "xCanonicalText", "")
            actionButtonText: getExtendedProperty(activateActionDescription, "label", i18n.tr("Call back"))
            replyButtonText: getExtendedProperty(replyActionDescription, "label", i18n.tr("Send"))
            // icons
            avatar: getExtendedProperty(extendedData, "icon", "image://theme/contact")
            icon: getExtendedProperty(extendedData, "xCanonicalAppIcon", "image://theme/missed-call")
            // actions
            actionEnabled: activateAction.valid && activateAction.enabled
            replyEnabled: replyAction.valid && replyAction.enabled
            enabled: menuData && menuData.sensitive || false
            removable: !selected
            confirmRemoval: true
            selected: messageFactoryItem.selected
            highlightWhenPressed: false

            onIconActivated: {
                menuModel.activate(menuIndex, true);
            }
            onDismissed: {
                menuModel.activate(menuIndex, false);
            }
            onActionActivated: {
                activateAction.activate();
            }
            onReplied: {
                replyAction.activate(value);
            }
            onTriggered: {
                if (selected) {
                    menuDeselected();
                } else {
                    menuSelected();
                }
            }
        }
    }
}
