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
import Ubuntu.Components.ListItems 1.3 as ListItems
import "Filters" as Filters

Item {
    id: root

    readonly property real searchesHeight: recentSearchesRepeater.count > 0 ? searchColumn.height + recentSearchesLabels.height + recentSearchesLabels.anchors.topMargin : 0

    implicitHeight: searchesHeight + dashNavigation.implicitHeight + dashNavigation.anchors.topMargin + primaryFilter.height + primaryFilter.anchors.topMargin

    // Set by parent
    property ListModel searchHistory
    property var scope: null
    property real windowHeight

    // Used by PageHeader
    readonly property bool hasContents: searchHistory.count > 0 || scope && scope.hasNavigation || scope && scope.primaryNavigationFilter

    signal historyItemClicked(string text)
    signal dashNavigationLeafClicked()

    function resetNavigation() {
        dashNavigation.resetNavigation();
    }

    Rectangle {
        color: "white"
        anchors.fill: parent
    }

    ListItems.ThinDivider {
        anchors.top: parent.top
    }

    Label {
        id: recentSearchesLabels
        text: i18n.tr("Recent Searches")
        visible: recentSearchesRepeater.count > 0
        anchors {
            top: parent.top
            left: parent.left
            margins: units.gu(2)
            topMargin: units.gu(3)
        }
    }

    Label {
        text: i18n.tr("Clear All")
        fontSize: "small"
        visible: recentSearchesRepeater.count > 0
        anchors {
            top: parent.top
            right: parent.right
            margins: units.gu(2)
            topMargin: units.gu(3)
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

            delegate: ListItem {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                }
                height: units.gu(5)

                Icon {
                    id: searchIcon
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                    height: units.gu(1.5)
                    width: height
                    name: "search"
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: searchIcon.right
                        leftMargin: units.gu(1)
                        right: parent.right
                    }
                    text: query
                    color: "#888888"
                }

                divider.visible: index != repeater.count - 1 || (scope && scope.hasNavigation) || primaryFilter.active

                onClicked: root.historyItemClicked(query)
            }
        }
    }

    DashNavigation {
        id: dashNavigation
        scope: root.scope
        anchors {
            top: recentSearchesRepeater.count > 0 ? searchColumn.bottom : parent.top
            topMargin: implicitHeight && recentSearchesRepeater.count > 0 ? units.gu(2) : 0
            left: parent.left
            right: parent.right
        }
        availableHeight: windowHeight * 4 / 6 - searchesHeight

        onLeafClicked: root.dashNavigationLeafClicked();
    }

    Filters.FilterWidgetFactory {
        id: primaryFilter
        active: scope && !scope.hasNavigation

        property var filter: active ? scope.primaryNavigationFilter : null

        anchors {
            top: recentSearchesRepeater.count > 0 ? searchColumn.bottom : parent.top
            topMargin: active && recentSearchesRepeater.count > 0 ? units.gu(2) : 0
            left: parent.left
            right: parent.right
        }

        widgetId: filter ? filter.filterId : ""
        widgetType: filter ? filter.filterType : -1
        widgetData: filter
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
