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

import QtQuick 2.0
import Dash 0.1

Item {
    id: root

    // Properties set by parent
    property var scope: null

    // Properties used by parent
    readonly property bool processing: false /*TODO*/

    // Signals
    signal backClicked()
    signal requestFavorite(string scopeId, bool favorite)

    ScopeStyle {
        id: scopeStyle
        style: { "foreground-color" : "gray",
                 "background-color" : "transparent",
                 "page-header": {
                    "background": "color:///transparent"
                 }
        }
    }

    DashBackground {
        anchors.fill: parent
    }

    PageHeader {
        id: header
        title: i18n.tr("My Feeds")
        width: parent.width
        showBackButton: true
        searchEntryEnabled: true
        onBackClicked: root.backClicked()
    }

    Flickable {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        contentWidth: root.width
        contentHeight: column.height
        onContentHeightChanged: console.log("column.height", column.height);
        Column {
            id: column
            Repeater {
                model: scope && scope.searchQuery == "" ? scope.categories : null

                delegate: Loader {
                    source: "ScopesListCategory.qml";
                    asynchronous: true
                    width: root.width
                    onLoaded: {
                        item.isFavoriteFeeds = index == 0;
                        item.scopeStyle = scopeStyle;
                        item.model = Qt.binding(function() { return results });
                        console.log(results, renderer);
                    }
                    Connections {
                        target: item
                        onRequestFavorite: root.requestFavorite(scopeId, favorite)
                    }
                }
            }
        }
    }
}
