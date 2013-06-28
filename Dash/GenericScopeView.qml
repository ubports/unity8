/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components 0.1
import "../Components"
import "../Components/ListItems" as ListItems
import "../Components/IconUtil.js" as IconUtil

ScopeView {
    id: scopeView

    onIsCurrentChanged: {
        pageHeader.resetSearch();
    }

    onMovementStarted: categoryView.showHeader()

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeader.searchQuery
    }

    Connections {
        target: panel
        onSearchClicked: if (isCurrent) {
            pageHeader.triggerSearch()
            categoryView.showHeader()
        }
    }

    ListViewWithPageHeader {
        id: categoryView
        anchors.fill: parent
        model: scopeView.categories
        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        delegate: ListItems.Base {
            highlightWhenPressed: false

            FilterGrid {
                id: filtergrid
                model: results

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                filter: false
                minimumHorizontalSpacing: units.gu(0.5)
                delegateWidth: units.gu(11)
                delegateHeight: units.gu(18)
                verticalSpacing: units.gu(2)

                delegate: Tile {
                    width: filtergrid.cellWidth
                    height: filtergrid.cellHeight
                    text: title ? title : "" // FIXME: this shouldn't be necessary
                    imageWidth: units.gu(11)
                    imageHeight: units.gu(16)
                    source: icon ? IconUtil.from_gicon(icon) : "" // FIXME: ditto
                }
            }
        }

        sectionProperty: "name"
        sectionDelegate: ListItems.Header {
            width: categoryView.width
            text: section
        }
        pageHeader: PageHeader {
            id: pageHeader
            objectName: "pageHeader"
            width: categoryView.width
            text: scopeView.scope.name
            searchEntryEnabled: true
        }
    }
}
