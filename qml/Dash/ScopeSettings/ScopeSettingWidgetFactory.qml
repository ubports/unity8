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

import QtQuick 2.2

//! \brief This component loads the widgets based on type.

Loader {
    id: root

    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Variable used to contain widget's data
    property var widgetData: null

    //! Triggered signal forwarded from the widgets.
    signal triggered(var value)

    source: widgetSource

    //! \cond private
    property url widgetSource: {
        switch (widgetData.type) {
            case "boolean": return "ScopeSettingSwitch.qml";
            case "list": return "ScopeSettingSwitch.qml";
            case "number": return "ScopeSettingNumber.qml";
            case "string": return "ScopeSettingLabel.qml";
            default: return "";
        }
    }
    //! \endcond

    onLoaded: {
        item.widgetData = Qt.binding(function() { return root.widgetData } )
    }

    Connections {
        target: root.item
        onTriggered: root.triggered(value)
    }
}
