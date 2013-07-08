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
    id: fakeScopeView
    property Scope scope : null
    property bool isCurrent : false

    property ListModel searchHistory

    signal endReached
    signal movementStarted
    signal positionedAtBeginning

    property alias backColor : back.color

    onEndReached: {
        if (shell != undefined && shell.scopeStatus != undefined) {
            shell.scopeStatus[scope.id].endReached++;
        }
    }
    onMovementStarted: {
        if (shell != undefined && shell.scopeStatus != undefined) {
            shell.scopeStatus[scope.id].movementStarted++;
        }
    }
    onPositionedAtBeginning: {
        if (shell != undefined && shell.scopeStatus != undefined) {
            shell.scopeStatus[scope.id].positionedAtBeginning++;
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
        id: listView
        anchors.fill: parent
        model: scope ? scope.categories : null
        orientation: ListView.Vertical

        delegate:  Column {
            id: column
            width: listView.width
            height: childrenRect.height

            Rectangle {
                width: listView.width
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
                id: resultsGrid
                model: results
                cellWidth: units.gu(10); cellHeight: units.gu(10)
                height: childrenRect.height
                width: listView.width
                interactive: false

                delegate:  Component {
                    id: resultDelegate
                    Item {
                        width: resultsGrid.cellWidth; height: resultsGrid.cellHeight
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            Image {
                                width: units.gu(5)
                                height: units.gu(5)
                                source: icon
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text { text: title; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
               }
            }
        }
    }
}
