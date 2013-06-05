/*
 * Copyright 2013 Canonical Ltd.
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

import QtQuick 2.0
import Unity 0.1

FocusScope {
    id: fakeLensView
    property Lens lens : null
    property bool isCurrent : false

    property alias rect_color1 : rect1.color
    property alias rect_color2 : rect2.color
    property alias rect_color3 : rect3.color

    property ListModel searchHistory

    signal endReached
    signal movementStarted
    signal positionedAtBeginning

    onEndReached: {
        if (shell != undefined && shell.lens_status != undefined) {
            shell.lens_status[lens.id].endReached++;
        }
    }
    onMovementStarted: {
        if (shell != undefined && shell.lens_status != undefined) {
            shell.lens_status[lens.id].movementStarted++;
        }
    }
    onPositionedAtBeginning: {
        if (shell != undefined && shell.lens_status != undefined) {
            shell.lens_status[lens.id].positionedAtBeginning++;
        }
    }


    Column {
        anchors.fill: parent
        Rectangle {
            id: rect1
            height: parent.height/3; width: parent.width;

            Text {
                id: label1
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: lens ? lens.id : ""
            }
        }

        Rectangle {
            id: rect2
            height: parent.height/3; width: parent.width

            Text {
                id: label2
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: lens ? lens.id : ""
            }
        }

        Rectangle {
            id: rect3
            height: parent.height/3; width: parent.width

            Text {
                id: label3
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: lens ? lens.id : ""
            }
        }
    }
}
