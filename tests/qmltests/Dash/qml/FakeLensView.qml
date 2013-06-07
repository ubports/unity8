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

    property ListModel searchHistory

    signal endReached
    signal movementStarted
    signal positionedAtBeginning

    property alias back_color : back.color

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

    Rectangle {
        id: back
        anchors.fill: parent
        color: "grey"
    }

    function randomBg()
    {
    var hex1=new Array("4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")
    var bg="#"+hex1[Math.floor(Math.random()*hex1.length)]+
                hex1[Math.floor(Math.random()*hex1.length)]+
                hex1[Math.floor(Math.random()*hex1.length)]+
                hex1[Math.floor(Math.random()*hex1.length)]+
                hex1[Math.floor(Math.random()*hex1.length)]+
                hex1[Math.floor(Math.random()*hex1.length)]
    return bg
    }


    ListView {
        id: list_view
        anchors.fill: parent
        model: lens ? lens.categories : null
        orientation: ListView.Vertical

        delegate:  Column {
            id: column
            width: list_view.width
            height: childrenRect.height

            Rectangle {
                width: list_view.width
                height: units.gu(3)
                color: randomBg()

                Text {
                    text: name
                    font.family: "Ubuntu"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            GridView {
                id: results_grid
                model: results
                cellWidth: units.gu(10); cellHeight: units.gu(10)
                height: childrenRect.height
                width: list_view.width
                interactive: false

                delegate:  Component {
                    id: resultDelegate
                    Item {
                        width: results_grid.cellWidth; height: results_grid.cellHeight
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            Image {
                                width: units.gu(5)
                                height: units.gu(5)
                                source: column_1
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text { text: column_4; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
               }
            }
        }
    }
}
