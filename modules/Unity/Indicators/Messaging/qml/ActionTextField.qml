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

Item {
    property alias actionGroup: __sendButton.actionGroup
    property alias action: __sendButton.action

    property alias text: __replyField.text
    property alias buttonText: __sendButton.text

    TextField {
        id: __replyField

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: __sendButton.left
        anchors.rightMargin: units.gu(1)
        placeholderText: "Reply"
        hasClearButton: false

        onEnabledChanged: {
            //Make sure that the component lost focus when enabled = false,
            //otherwise it will get focus again when enable = true
            if (!enabled) {
                focus = false;
            }
        }
    }

    ActionButton {
        id: __sendButton

        actionParameter: __replyField.text
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: units.gu(9)
        enabled: __replyField.text !== ""
        color: enabled ? "#c94212" : "#bababa"
    }
}
