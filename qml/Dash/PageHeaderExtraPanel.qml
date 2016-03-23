/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.3

Item {
    id: root

    readonly property real searchesHeight: recentSearchesRepeater.count > 0 ? searchColumn.height + recentSearchesLabels.height + recentSearchesLabels.anchors.margins : 0

    implicitHeight: searchesHeight + dashNavigation.implicitHeight

    // Set by parent
    property ListModel searchHistory
    property var scope: null
    property var scopeStyle: null
    property real windowHeight

    // Used by PageHeader
    readonly property bool hasContents: searchHistory.count > 0 || scope && scope.hasNavigation

    signal historyItemClicked(string text)
    signal dashNavigationLeafClicked()

    function resetNavigation() {
        dashNavigation.resetNavigation();
    }

    Rectangle {
        color: "white"
        anchors.fill: parent
    }

    Label {
        id: recentSearchesLabels
        text: i18n.tr("Recent Searches")
        visible: recentSearchesRepeater.count > 0
        anchors {
            top: parent.top
            left: parent.left
            margins: units.gu(1)
        }
    }

    Label {
        text: i18n.tr("Clear All")
        fontSize: "small"
        visible: recentSearchesRepeater.count > 0
        anchors {
            top: parent.top
            right: parent.right
            margins: units.gu(1)
        }

        AbstractButton {
            anchors.fill: parent
            onClicked: searchHistory.clear();
        }
    }

    Column {
        id: searchColumn
        anchors {
            top: recentSearchesLabels.bottom
            left: parent.left
            right: parent.right
        }

        Repeater {
            id: recentSearchesRepeater
            objectName: "recentSearchesRepeater"
            model: searchHistory

            delegate: Standard {
                showDivider: index < recentSearchesRepeater.count - 1
                height: units.gu(4)
                text: query
                iconName: "search"
                iconFrame: false
                onClicked: root.historyItemClicked(text)
            }
        }
    }

    DashNavigation {
        id: dashNavigation
        scope: root.scope
        anchors {
            top: recentSearchesRepeater.count > 0 ? searchColumn.bottom : parent.top
            left: parent.left
            right: parent.right
        }
        scopeStyle: root.scopeStyle
        availableHeight: windowHeight * 4 / 6 - searchesHeight

        onLeafClicked: root.dashNavigationLeafClicked();
    }

    // This is outside the item
    Image {
        anchors {
            top: parent.bottom
            left: parent.left
            right: parent.right
        }
        fillMode: Image.Stretch
        source: "graphics/navigation_shadow.png"
    }
}
