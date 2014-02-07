/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity 0.1

//! \brief This component loads the widgets based on widgetData["type"].

Loader {
    id: root

    //! Widget data, forwarded to the widget as is.
    property var widgetData: null

    //! Triggered signal forwarded from the widgets.
    signal triggered(string widgetId, string actionId, var data)

    source: {
        switch (widgetData && widgetData["type"]) {
            case "audio": return "PreviewAudioPlayback.qml";
            case "text": return "PreviewTextSummary.qml";
            case "gallery": return "PreviewImageGallery.qml";
            case "actions": return "PreviewActions.qml";
            default: return "";
        }
    }

    Binding {
        target: root.item
        when: root.status === Loader.Ready
        property: "widgetData"
        value: root.widgetData
    }

    Connections {
        target: root.item
        onTriggered: root.triggered(widgetId, actionId, data)
    }
}
