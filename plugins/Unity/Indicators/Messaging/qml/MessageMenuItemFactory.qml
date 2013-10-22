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
import Unity.Indicators 0.1 as Indicators
import QMenuModel 0.1 as QMenuModel
import "utils.js" as Utils

Indicators.BaseMenuItem {
    id: menuItem
    property var actionsDescription: menu ? menu.ext.xCanonicalMessageActions : undefined

    implicitHeight: contents.status == Loader.Ready ? contents.item.implicitHeight : 0

    property var model: null

    Loader {
        id: contents
        anchors.fill: parent
        asynchronous: false

        sourceComponent: loadMessage(actionsDescription);

        Component {
            id: simpleTextMessage
            SimpleTextMessage {
                // text
                title: menu && menu.label ? menu.label : ""
                time: menu ? Utils.formatDate(menu.ext.xCanonicalTime) : ""
                message: menu && menu.ext.xCanonicalText ? menu.ext.xCanonicalText : ""
                // icons
                avatar: menu && menu.ext.icon !== undefined ? menu.ext.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: menu && menu.ext.xCanonicalAppIcon !== undefined ? menu.ext.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"

                onActivateApp: {
                    menuItem.model.activate(modelIndex, true);
                }
                onDismiss: {
                    menuItem.model.activate(modelIndex, false);
                }

                menuSelected: menuItem.menuSelected
                onSelectMenu: menuItem.selectMenu()
                onDeselectMenu: menuItem.deselectMenu()
            }
        }
        Component {
            id: textMessage
            TextMessage {
                property var replyAction: QMenuModel.UnityMenuAction {
                    model: menuItem.model
                    index: modelIndex
                    name: menu && actionsDescription[0].name ? actionsDescription[0].name : ""
                }

                // text
                title: menu && menu.label ? menu.label : ""
                time: menu ? Utils.formatDate(menu.ext.xCanonicalTime) : ""
                message: menu && menu.ext.xCanonicalText ? menu.ext.xCanonicalText : ""
                replyButtonText: actionsDescription && actionsDescription[0].label ? actionsDescription[0].label : "Send"
                // icons
                avatar: menu && menu.ext.icon !== undefined ? menu.ext.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: menu && menu.ext.xCanonicalAppIcon !== undefined ? menu.ext.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"
                // actions
                replyEnabled: replyAction.valid && replyAction.enabled

                onActivateApp: {
                    menuItem.model.activate(modelIndex, true);
                }
                onDismiss: {
                    menuItem.model.activate(modelIndex, false);
                }
                onReply: {
                    replyAction.activate(value);
                }

                menuSelected: menuItem.menuSelected
                onSelectMenu: menuItem.selectMenu()
                onDeselectMenu: menuItem.deselectMenu()
            }
        }
        Component {
            id: snapDecision
            SnapDecision {
                property var activateAction: QMenuModel.UnityMenuAction {
                    model: menuItem.model
                    index: modelIndex
                    name: menu && actionsDescription[0].name ? actionsDescription[0].name : ""
                }
                property var replyAction: QMenuModel.UnityMenuAction {
                    model: menuItem.model
                    index: modelIndex
                    name: menu && actionsDescription[1].name ? actionsDescription[1].name : ""
                }

                // text
                title: menu && menu.label ? menu.label : ""
                time: menu ? Utils.formatDate(menu.ext.xCanonicalTime) : ""
                message: menu && menu.ext.xCanonicalText ? menu.ext.xCanonicalText : ""
                actionButtonText: actionsDescription && actionsDescription[0].label ?  actionsDescription[0].label : "Call back"
                replyButtonText: actionsDescription && actionsDescription[1].label ? actionsDescription[1].label : "Send"
                replyMessages: actionsDescription && actionsDescription[1]["parameter-hint"] ? actionsDescription[1]["parameter-hint"] : ""
                // icons
                avatar: menu && menu.ext.icon !== undefined ? menu.ext.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: menu && menu.ext.xCanonicalAppIcon !== undefined ? menu.ext.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"
                // actions
                activateEnabled: activateAction.valid && activateAction.enabled
                replyEnabled: replyAction.valid && replyAction.enabled

                onActivateApp: {
                    menuItem.model.activate(modelIndex, true);
                }
                onDismiss: {
                    menuItem.model.activate(modelIndex, false);
                }
                onActivate: {
                    activateAction.activate();
                }
                onReply: {
                    replyAction.activate(value);
                }

                menuSelected: menuItem.menuSelected
                onSelectMenu: menuItem.selectMenu()
                onDeselectMenu: menuItem.deselectMenu()
            }
        }
    }

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
            return simpleTextMessage;
        } else if (parameterType === "s") {
            return textMessage;
        } else if (parameterType === "_s") {
            return snapDecision;
        } else {
            console.debug("Unknown paramater type: " + parameterType);
        }
        return undefined;
    }
}
