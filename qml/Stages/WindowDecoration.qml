/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
import Unity.Application 0.1 // For Mir singleton
import Ubuntu.Components 1.3
import "../Components"
import "../Components/PanelState"

MouseArea {
    id: root
    clip: true

    property Item target
    property alias title: titleLabel.text
    property bool active: false
    hoverEnabled: true

    signal close()
    signal minimize()
    signal maximize()

    onDoubleClicked: root.maximize()

    QtObject {
        id: priv
        property real distanceX
        property real distanceY
        property bool dragging
    }

    onPressedChanged: {
        if (pressed) {
            var pos = mapToItem(root.target, mouseX, mouseY);
            priv.distanceX = pos.x;
            priv.distanceY = pos.y;
            priv.dragging = true;
        } else {
            priv.dragging = false;
            Mir.cursorName = "";
        }
    }

    onPositionChanged: {
        if (priv.dragging) {
            Mir.cursorName = "grabbing";
            var pos = mapToItem(root.target.parent, mouseX, mouseY);
            root.target.x = pos.x - priv.distanceX;
            root.target.y = Math.max(pos.y - priv.distanceY, PanelState.panelHeight);
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: -radius
        radius: units.gu(.5)
        color: theme.palette.normal.background
    }

    Row {
        anchors {
            fill: parent
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
            topMargin: units.gu(0.5)
            bottomMargin: units.gu(0.5)
        }
        spacing: units.gu(3)

        WindowControlButtons {
            id: buttons
            height: parent.height
            active: root.active
            onClose: root.close();
            onMinimize: root.minimize();
            onMaximize: root.maximize();
        }

        Label {
            id: titleLabel
            objectName: "windowDecorationTitle"
            color: root.active ? "white" : "#5d5d5d"
            height: parent.height
            width: parent.width - buttons.width - parent.anchors.rightMargin - parent.anchors.leftMargin
            verticalAlignment: Text.AlignVCenter
            fontSize: "medium"
            font.weight: root.active ? Font.Light : Font.Normal
            elide: Text.ElideRight
        }
    }
}
