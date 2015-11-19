/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import "../../Components"

/*! \brief Preview widget for table.

    This widget shows two columns contained in widgetData["values"]
    as arrays of label,value along with a title that comes from widgetData["title"].

    In case the widget is collapsed it only shows 3 lines of values.
 */

PreviewWidget {
    id: root
    implicitHeight: column.implicitHeight

    readonly property int maximumCollapsedRowCount: 3

    Column {
        id: column
        objectName: "column"
        spacing: units.gu(1)
        width: parent.width

        Label {
            id: titleLabel
            objectName: "titleLabel"
            anchors {
                left: parent.left
                right: parent.right
            }
            height: visible ? implicitHeight : 0
            fontSize: "large"
            color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
            visible: text !== ""
            opacity: .8
            text: widgetData["title"] || ""
            elide: Text.ElideRight
        }

        GridLayout {
            objectName: "gridLayout"
            columns: 2
            columnSpacing: units.gu(2)
            Repeater {
                id: rowsRepeater
                model: widgetData["values"]

                delegate: Repeater {
                    id: perRowRepeater
                    readonly property int rowIndex: index
                    model: widgetData["values"][index]
                    delegate: Label {
                        objectName: "label"+rowIndex+index
                        fontSize: "small"
                        text: perRowRepeater.model[index]
                        visible: root.expanded || rowIndex < maximumCollapsedRowCount
                        color: root.scopeStyle ? root.scopeStyle.foreground : theme.palette.normal.baseText
                        font.bold: index == 0
                        wrapMode: Text.Wrap
                        Layout.alignment: Qt.AlignTop
                        Layout.maximumWidth: column.width - x
                    }
                }
            }
        }
    }
}
