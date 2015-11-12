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
import Ubuntu.Components.Popups 1.3
import "Filters" as Filters

Popover {
    id: root
    objectName: "filtersPopover"

    Flickable {
        id: flickable
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        // Popover doesn't like being 75% or bigger than the screen (counting the "empty" part on top)
        height: Math.min(root.parent.height * 3 / 4 - flickable.mapToItem(null, 0, 0).y - 1, column.height);
        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            Repeater {
                model: scopeView.scope.filters

                delegate: Filters.FilterWidgetFactory {
                    width: parent.width

                    widgetId: id
                    widgetType: type
                    widgetData: filter
                }
            }
        }
    }
}
