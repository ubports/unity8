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
import Unity 0.2

//! \brief This component loads the widgets based on widgetType.

Loader {
    id: root

    //! Identifier of the widget.
    property string widgetId: ""

    //! Type of the widget to display.
    property int widgetType

    //! Widget data, forwarded to the widget as is.
    property var widgetData: null

    source: widgetSource

    //! \cond private
    readonly property url widgetSource: {
        switch (widgetType) {
            case Filters.OptionSelectorFilter: return "FilterOptionSelector.qml";
            default: return "";
        }
    }
    //! \endcond

    onLoaded: {
        item.widgetId = Qt.binding(function() { return root.widgetId } )
        item.widgetData = Qt.binding(function() { return root.widgetData } )
    }
}
