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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

ScopeSetting {
    id: root

    // FIXME workaround for: https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1355830
    height: listItem.currentlyExpanded ? listItem.itemHeight * widgetData.properties["values"].length + units.gu(6) : listItem.height

    property int initialValue: -1

    ListItem.ItemSelector {
        id: listItem
        objectName: "control"
        anchors {
            left: parent.left
            right: parent.right
        }
        text: widgetData.displayName
        model: widgetData.properties["values"]

        onSelectedIndexChanged: {
            if (root.initialValue >= 0) {
                var tmpValue = root.initialValue;
                root.initialValue = -1;
                selectedIndex = tmpValue;
                return;
            }

            root.updated(selectedIndex);
        }
    }
}
