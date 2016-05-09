/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Dash 0.1

Rectangle {
    width: 300
    height: 542
    color: "lightblue"

    ListModel {
        id: model

        function insertItem(index, size, type) {
            insert(index, { size: size, type: type });
        }

        function removeItems(index, count) {
            remove(index, count);
        }

        function moveItems(indexFrom, indexTo, count) {
            move(indexFrom, indexTo, count);
        }

        ListElement { type: "Agressive"; size: 150 }
        ListElement { type: "Regular"; size: 200 }
        ListElement { type: "Mild"; size: 350 }
        ListElement { type: "Bold"; size: 350 }
        ListElement { type: "Bold"; size: 350 }
        ListElement { type: "Lazy"; size: 350 }
    }

    Component {
        id: otherRect
        Rectangle {
            height: 35
            width: parent.width
            color: index % 2 == 0 ? "yellow" : "purple"
        }
    }

    ListViewWithPageHeader {
        id: listView
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: model
        cacheBuffer: height * 0.5
        delegate: Rectangle {
            property bool timerDone: false
            width: parent.width - 20
            x: 10
            color: index % 2 == 0 ? "red" : "blue"
            height: timerDone ? size : 350
            Text {
                text: index
            }
            Timer {
                id: sizeTimer
                interval: 10;
                onTriggered: {
                    timerDone = true
                }
            }
            Component.onCompleted: {
                sizeTimer.start()
            }
        }

        pageHeader: Rectangle {
            color: "transparent"
            width: parent.width
            height: 50
            implicitHeight: 50
            Text {
                anchors.fill: parent
                text: "APPS"
                font.pixelSize: 40
            }
        }

        sectionProperty: "type"
        sectionDelegate: Component {
            Rectangle {
                color: "green"
                height: section === "" ? 0 : section != "halfheight" ? 40 : 20;
                Text { text: section; font.pixelSize: 34 }
                anchors { left: parent.left; right: parent.right }
            }
        }
    }
}
