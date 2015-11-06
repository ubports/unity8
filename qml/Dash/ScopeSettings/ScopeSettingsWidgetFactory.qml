/*
 * Copyright (C) 2014 Canonical, Ltd.
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

//! \brief This component loads the widgets based on type.

Loader {
    id: root

    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Variable used to contain widget's data
    property var widgetData: null

    //! Triggered signal forwarded from the widgets.
    signal updated(var value)

    //! makeSureVisible signal forwarded from the widgets.
    signal makeSureVisible(var item)

    source: widgetSource

    //! \cond private
    property url widgetSource: {
        switch (widgetData.type) {
            case "boolean": return "ScopeSettingBoolean.qml";
            case "list": return "ScopeSettingList.qml";
            case "number": return "ScopeSettingNumber.qml";
            case "string": return "ScopeSettingString.qml";
            default: return "";
        }
    }
    //! \endcond

    onLoaded: {
        if (item.hasOwnProperty("initialValue")) item.initialValue = root.widgetData.value;
        item.widgetData = Qt.binding(function() { return root.widgetData; } )
        item.scopeStyle = Qt.binding(function() { return root.scopeStyle; } )
    }

    Connections {
        target: root.item
        onUpdated: if (value !== widgetData.value) root.updated(value)
        onMakeSureVisible: root.makeSureVisible(item)
    }
}
