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

LensView {
    id: lensView

    //FIXME: a quick hack to get icons out of gicons and fallback to
    //base icon for annotated icons. Doesn't correctly handle all icons.
    //Proper global solution needed.
    function from_gicon(name) {
        var icon_name = name;
        var annotated_re = /^. UnityProtocolAnnotatedIcon/;
        if (annotated_re.test(name)) {
            var base_icon_re = /'base-icon':.+?'(.+?)'/;
            var base_icon = name.toString().match(base_icon_re);
            icon_name = base_icon[1];
        }
        else {
            var themed_re = /^. GThemedIcon\s*([^\s]+)\s*/;
            var themed = name.match(themed_re);
            if (themed) {
                return "image://gicon/" + themed[1];
            }
        }
        var remote_re = /^http/;
        if (remote_re.test(icon_name)) {
            return icon_name;
        }
        return "image://gicon/" + icon_name;
    }

    onIsCurrentChanged: {
        pageHeader.resetSearch();
    }

    onMovementStarted: categoryView.showHeader()

    Binding {
        target: lensView.lens
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
        model: lensView.categories
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
                    text: column_5 ? column_5 : "" // FIXME: this shouldn't be necessary
                    imageWidth: units.gu(11)
                    imageHeight: units.gu(16)
                    source: column_1 ? from_gicon(column_1) : "" // FIXME: ditto
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
            text: lensView.lens.name
            searchEntryEnabled: true
        }
    }
}
