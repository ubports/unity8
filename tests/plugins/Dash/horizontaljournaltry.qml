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

Item {
    id: root
    signal add(int width)
    signal remove()

    ListViewWithPageHeader {
        id: lvwph
        model: listModel
        height: parent.height
        width: parent.width - controls.width

        delegate: HorizontalJournal {
            id: hj
            model: vjModel
            rowHeight: 100
            columnSpacing: 10
            rowSpacing: 10
            width: parent.width
            height: implicitHeight > 100 ? implicitHeight : 100
            displayMarginBeginning: {
                if (hj.y + hj.height <= 0) {
                    // Not visible (item at top of the list viewport)
                    return -hj.height;
                } else if (hj.y >= lvwph.height) {
                    // Not visible (item at bottom of the list viewport)
                    return 0;
                } else {
                    return -Math.max(-hj.y, 0);
                }
            }
            displayMarginEnd: {
                if (hj.y + hj.height <= 0) {
                    // Not visible (item at top of the list viewport)
                    return 0;
                } else if (hj.y >= lvwph.height) {
                    // Not visible (item at bottom of the list viewport)
                    return -hj.height;
                } else {
                    return -Math.max(hj.height - lvwph.height + hj.y, 0)
                }
            }

            delegate: Rectangle {
                height: 100
                color: "red";
                width: modelWidth
                border.width: 3

                Text {
                    text: index + "\nx: " + parent.x + "\nwidth: " + parent.width
                    x: 10
                    y: 10
                }
            }
        }
    }

    Rectangle {
        id: controls
        height: parent.height
        width: 100
        anchors.right: parent.right
        color: "gray"
        opacity: 0.4

        Rectangle {
            id: addButton
            height: 50
            width: parent.width
            color: "blue"
            Text {
                text: "Add"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.add(addField.text)
            }
        }
        TextInput {
            id: addField
            anchors.top: addButton.bottom
            height: 30
            width: parent.width
        }
        Rectangle {
            anchors.top: addField.bottom
            height: 50
            width: parent.width
            color: "red"
            Text {
                text: "Remove"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.remove()
            }
        }
    }
}