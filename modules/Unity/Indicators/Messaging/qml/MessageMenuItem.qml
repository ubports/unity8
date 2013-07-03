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

Indicators.BasicMenuItem {
    property variant actionsDescription: menu ? menu.extra.canonical_message_actions : undefined

    onActionGroupChanged: loadItem()
    onActionsDescriptionChanged: loadItem()
    implicitHeight: contents.status == Loader.Ready ? contents.item.implicitHeight : 0

    Loader {
        id: contents

        anchors.fill: parent
        // Binding all properties for the item, to make sure that any change in the
        // property will be propagated to the contents.item at any time
        Binding {
            target: contents.item
            property: "menuActivated"
            value: menuActivated
            when: (contents.status == Loader.Ready)
        }

        Binding {
            target: contents.item
            property: "actionGroup"
            value: actionGroup
            when: (contents.status == Loader.Ready)
        }

        Binding {
            target: contents.item
            property: "menu"
            value: menu
            when: (contents.status == Loader.Ready)
        }

        Binding {
            target: contents.item
            property: "actionsDescription"
            value: actionsDescription
            when: (contents.status == Loader.Ready)
        }

        Connections {
            target: contents.item ? contents.item : null
            onActivateMenu: activateMenu()
            onDeactivateMenu: deactivateMenu()
        }
    }


    function loadItem()
    {
        var parameterType = ""
        for (var actIndex in actionsDescription) {
            var desc = actionsDescription[actIndex];
            if (desc["parameter-type"] !== undefined) {
                parameterType += desc["parameter-type"];
            } else {
                parameterType += "_";
            }
        }

        if (parameterType === "") {
            contents.source = "SimpleTextMessage.qml";
        } else if (parameterType === "s") {
            contents.source = "TextMessage.qml";
        } else if (parameterType === "_s") {
            contents.source = "SnapDecision.qml";
        } else {
            console.debug("Unknown paramater type: " + parameterType);
        }
    }
}
