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

import QtQuick 2.0
import Ubuntu.Components 0.1

import "../../../Components/ListItems" as ListItems

Item {
    id: overviewGrid

    height: childrenRect.height

    property var model

    UbuntuShape {
        id: gridBackground
        anchors.fill: grid
        color: "#282421" // FIXME missing palette
        radius: "medium"
    }

    GridView {
        id: grid
        objectName: "overviewGrid"

        property int columnCount: 3
        property int rowCount: Math.ceil(model.count / columnCount)

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: units.gu(3)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
        height: cellWidth * rowCount
        cellWidth: Math.floor((width) / columnCount)
        cellHeight: cellWidth
        model: overviewGrid.model
        visible: opacity != 0
        interactive: false
        delegate:
            AbstractButton {
                objectName: "overviewGridButton" + index
                width: grid.cellWidth
                height: grid.cellHeight
                Image {
                    id: imageIcon
                    objectName: "overviewGridButtonImage"
                    source: iconSource
                    width: units.gu(4)
                    height: units.gu(4)
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -units.gu(1)
                    }
                    sourceSize.width: width
                    sourceSize.height: height
                    visible: labelIcon.text === ""
                }

                Label {
                    id: labelIcon
                    text: label
                    color: Theme.palette.selected.backgroundText
                    opacity: 0.8
                    font.family: "Ubuntu"
                    fontSize: "large"
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -units.gu(1)
                    }
                }

                Label {
                    text: title
                    color: Theme.palette.selected.backgroundText
                    fontSize: "small"
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: units.gu(0.5)
                        rightMargin: units.gu(0.5)
                        bottomMargin: units.gu(1.5)
                    }
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter

                }
                onClicked: overview.menuSelected(index)
            }
    }

    Item {
        id: gridOverlay
        anchors.fill: grid

        Column {
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: grid.cellHeight
            y: grid.cellHeight - units.dp(1)
            Repeater {
                model: grid.rowCount - 1
                ListItems.ThinDivider {
                    anchors.margins: units.dp(1)
                }
            }
        }

        Row {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            spacing: grid.cellWidth - units.dp(1)
            x: grid.cellWidth - units.dp(1)
            Repeater {
                model: grid.columnCount - 1
                ListItems.VerticalThinDivider {
                    anchors.margins: units.dp(1)
                }
            }
        }
    }
}
