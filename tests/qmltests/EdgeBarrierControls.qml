/*
 * Copyright 2015 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Test 0.1

RowLayout {
    id: root
    Layout.fillWidth: true

    property var target: null
    property string backgroundColor: "darkGrey"
    property alias text: label.text
    signal dragged(real amount);

    Binding {
        id: containsMouseBinding

        // only activate the binding once the controls start to get used in order to not
        // interfere with automated tests
        property bool activated: false

        when: root.target !== undefined && root.target !== null && activated
        target: root.target
        property: "_containsMouse"
        value: checkbox.checked
    }


    Rectangle {
        width: label.width + units.gu(1)
        height: units.gu(4)
        color: root.backgroundColor

        Rectangle {
            anchors.fill: parent
            color: "darkGreen"
            opacity: target ? target.progress : 0
        }

        Label {
            id: label
            color: "white"
            anchors.centerIn: parent
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property real lastX
            property bool dragging: false
            onPressedChanged: {
                if (pressed) {
                    containsMouseBinding.activated = true;
                    checkbox.checked = true;
                } else {
                    dragging = false;
                }
            }
            onMouseXChanged: {
                if (dragging) {
                    var amount = Math.abs(mouseX - lastX);
                    lastX = mouseX;
                    root.dragged(amount);
                } else {
                    lastX = mouseX;
                    dragging = true;
                }
            }
        }
    }

    CheckBox {
        id: checkbox
        checked: false
        activeFocusOnPress: false
        onCheckedChanged: {
            if (checked) {
                containsMouseBinding.activated = true;
            }
        }
    }
}
