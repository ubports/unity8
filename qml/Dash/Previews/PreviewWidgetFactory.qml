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

import QtQuick 2.4

//! \brief This component loads the widgets based on widgetData["type"].

Loader {
    id: root

    //! Identifier of the widget.
    property string widgetId: ""

    //! Type of the widget to display.
    property string widgetType: ""

    //! Widget data, forwarded to the widget as is.
    property var widgetData: null

    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Should the widget show in expanded mode (For those that support it)
    property bool expanded: widgetType !== "expandable" || widgetData["expanded"] === true

    //! Set to true if the parent preview is displayed.
    property bool isCurrentPreview: false

    //! Set margins width.
    property real widgetMargins: status === Loader.Ready ? item.widgetMargins : units.gu(1)

    /// The parent (vertical) flickable this widget is in (if any)
    property var parentFlickable: null

    //! Triggered signal forwarded from the widgets.
    signal triggered(string widgetId, string actionId, var data)

    //! MakesureVisible signal forwarded from the widgets.
    signal makeSureVisible(var item)

    source: widgetSource

    //! \cond private
    property url widgetSource: {
        switch (widgetType) {
            case "actions": return "PreviewActions.qml";
            case "audio": return "PreviewAudioPlayback.qml";
            case "comment": return "PreviewComment.qml";
            case "comment-input": return "PreviewCommentInput.qml";
            case "expandable": return "PreviewExpandable.qml";
            case "gallery": return "PreviewImageGallery.qml";
            case "header": return "PreviewHeader.qml";
            case "icon-actions": return "PreviewIconActions.qml";
            case "image": return "PreviewZoomableImage.qml";
            case "progress": return "PreviewProgress.qml";
            case "payments": return "PreviewPayments.qml";
            case "rating-input": return "PreviewRatingInput.qml";
            case "rating-edit": return "PreviewRatingEdit.qml";
            case "reviews": return "PreviewRatingDisplay.qml";
            case "table": return "PreviewTable.qml";
            case "text": return "PreviewTextSummary.qml";
            case "video": return "PreviewVideoPlayback.qml";
            default: return "";
        }
    }
    //! \endcond

    onLoaded: {
        item.widgetId = Qt.binding(function() { return root.widgetId } )
        item.widgetData = Qt.binding(function() { return root.widgetData } )
        item.isCurrentPreview = Qt.binding(function() { return root.isCurrentPreview } )
        item.expanded = Qt.binding(function() { return root.expanded } )
        item.scopeStyle = Qt.binding(function() { return root.scopeStyle } )
        item.parentFlickable = Qt.binding(function() { return root.parentFlickable } )
    }

    Connections {
        target: root.item
        onTriggered: root.triggered(widgetId, actionId, data)
        onMakeSureVisible: root.makeSureVisible(item)
    }
}
