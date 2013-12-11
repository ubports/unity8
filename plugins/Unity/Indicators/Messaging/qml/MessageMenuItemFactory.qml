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

Indicators.BaseMenuItem {
    id: messageFactoryItem
    property var menuModel: null
    property QtObject menuData: null
    property var menuIndex: undefined

    property var extAttrib: menuData && menuData.ext ? menuData.ext : undefined
    property var actionsDescription: extAttrib && extAttrib.hasOwnProperty("xCanonicalMessageActions") ? extAttrib.xCanonicalMessageActions : undefined

    onMenuModelChanged: {
        loadAttributes();
    }
    onMenuIndexChanged: {
        loadAttributes();
    }

    function loadAttributes() {
        if (!menuModel || menuIndex == undefined) return;

        menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-time': 'int64',
                                                  'x-canonical-text': 'string',
                                                  'x-canonical-message-actions': 'variant',
                                                  'icon': 'icon',
                                                  'x-canonical-app-icon': 'icon'});
    }

    implicitHeight: contents.status == Loader.Ready ? contents.item.implicitHeight : 0

    Loader {
        id: contents
        anchors.fill: parent

        sourceComponent: loadMessage(actionsDescription);

        Component {
            id: simpleTextMessage
            SimpleTextMessage {
                // text
                title: menuData && menuData.label ? menuData.label : ""
                time: extAttrib && extAttrib.hasOwnProperty("xCanonicalTime") ? extAttrib.xCanonicalTime : 0
                message: extAttrib && extAttrib.hasOwnProperty("xCanonicalText") ? extAttrib.xCanonicalText : ""
                // icons
                avatar: extAttrib && extAttrib.hasOwnProperty("icon") ? extAttrib.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: extAttrib && extAttrib.hasOwnProperty("xCanonicalAppIcon") ? extAttrib.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"

                onActivateApp: {
                    menuModel.activate(menuIndex, true);
                    shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
                }
                onDismiss: {
                    menuModel.activate(menuIndex, false);
                }

                menuSelected: messageFactoryItem.menuSelected
                onSelectMenu: messageFactoryItem.selectMenu()
                onDeselectMenu: messageFactoryItem.deselectMenu()
            }
        }
        Component {
            id: textMessage
            TextMessage {
                property var replyActionDescription: actionsDescription && actionsDescription.length > 0 ? actionsDescription[0] : undefined

                property var replyAction: QMenuModel.UnityMenuAction {
                    model: menuModel
                    index: menuIndex
                    name: replyActionDescription !== undefined ? replyActionDescription.name : ""
                }

                // text
                title: menuData && menuData.label ? menuData.label : ""
                time: extAttrib && extAttrib.hasOwnProperty("xCanonicalTime") ? extAttrib.xCanonicalTime : 0
                message: extAttrib && extAttrib.hasOwnProperty("xCanonicalText") ? extAttrib.xCanonicalText : ""
                replyButtonText: replyActionDescription !== undefined && replyActionDescription.hasOwnProperty("label") ? replyActionDescription.label : "Send"
                // icons
                avatar: extAttrib && extAttrib.hasOwnProperty("icon") ? extAttrib.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: extAttrib && extAttrib.hasOwnProperty("xCanonicalAppIcon") ? extAttrib.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"
                // actions
                replyEnabled: replyAction.valid && replyAction.enabled

                onActivateApp: {
                    menuModel.activate(menuIndex, true);
                    shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
                }
                onDismiss: {
                    menuModel.activate(menuIndex, false);
                }
                onReply: {
                    replyAction.activate(value);
                }

                menuSelected: messageFactoryItem.menuSelected
                onSelectMenu: messageFactoryItem.selectMenu()
                onDeselectMenu: messageFactoryItem.deselectMenu()
            }
        }
        Component {
            id: snapDecision
            SnapDecision {
                property var activateActionDescription: actionsDescription && actionsDescription.length > 0 ? actionsDescription[0] : undefined
                property var replyActionDescription: actionsDescription && actionsDescription.length > 1 ? actionsDescription[1] : undefined

                property var activateAction: QMenuModel.UnityMenuAction {
                    model: menuModel
                    index: menuIndex
                    name: activateActionDescription !== undefined ? activateActionDescription.name : ""
                }
                property var replyAction: QMenuModel.UnityMenuAction {
                    model: menuModel
                    index: menuIndex
                    name: replyActionDescription !== undefined ? replyActionDescription.name : ""
                }

                // text
                title: menuData && menuData.label ? menuData.label : ""
                time: extAttrib && extAttrib.hasOwnProperty("xCanonicalTime") ? extAttrib.xCanonicalTime : ""
                message: extAttrib && extAttrib.hasOwnProperty("xCanonicalText") ? extAttrib.xCanonicalText : ""
                actionButtonText: activateActionDescription !== undefined && activateActionDescription.hasOwnProperty("label") ?  activateActionDescription.label : "Call back"
                replyButtonText: replyActionDescription !== undefined && replyActionDescription.hasOwnProperty("label") ? replyActionDescription.label : "Send"
                replyMessages: replyActionDescription !== undefined && replyActionDescription.hasOwnProperty("parameter-hint") ? replyActionDescription["parameter-hint"] : ""
                // icons
                avatar: extAttrib && extAttrib.hasOwnProperty("icon") ? extAttrib.icon : "qrc:/indicators/artwork/messaging/default_contact.png"
                appIcon: extAttrib && extAttrib.hasOwnProperty("xCanonicalAppIcon") ? extAttrib.xCanonicalAppIcon : "qrc:/indicators/artwork/messaging/default_app.svg"
                // actions
                activateEnabled: activateAction.valid && activateAction.enabled
                replyEnabled: replyAction.valid && replyAction.enabled

                onActivateApp: {
                    menuModel.activate(menuIndex, true);
                    shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
                }
                onDismiss: {
                    menuModel.activate(menuIndex, false);
                }
                onActivate: {
                    activateAction.activate();
                }
                onReply: {
                    replyAction.activate(value);
                }

                menuSelected: messageFactoryItem.menuSelected
                onSelectMenu: messageFactoryItem.selectMenu()
                onDeselectMenu: messageFactoryItem.deselectMenu()
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
