/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Unity 0.2

//! \brief This component loads the widgets based on widgetType.

Item {
    id: root
    //! Identifier of the widget.
    property string widgetId: ""

    //! Type of the widget to display.
    property int widgetType

    //! Widget data, forwarded to the widget as is.
    property var widgetData: null

    implicitHeight: title.height + title.anchors.topMargin + loader.height

    Label {
        id: title
        text: widgetData ? widgetData.title : ""
        height: text != "" ? implicitHeight : 0

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: height > 0 ? units.gu(1) : 0
            leftMargin: units.gu(2)
            rightMargin: anchors.leftMargin
        }
    }

    property alias active: loader.active

    Loader {
        id: loader

        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
        }

        source: widgetSource

        readonly property url widgetSource: {
            switch (widgetType) {
                case Filters.OptionSelectorFilter: return "FilterOptionSelector.qml";
                case Filters.RangeInputFilter: return "FilterRangeInput.qml";
                default: return "";
            }
        }

        onLoaded: {
            item.widgetId = Qt.binding(function() { return root.widgetId } )
            item.widgetData = Qt.binding(function() { return root.widgetData } )
        }
    }
}
