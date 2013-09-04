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
import Utils 0.1
import Unity.Application 0.1

SortFilterProxyModel {
    id: root
    property int stage
    property variant focusedApplication: null

    function get(index) {
        print("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG get", index)
        return ApplicationManager.get(mapRowToSource(index));
    }

    function move(from, to) {
        var realFrom = mapRowToSource(from);
        if (realFrom == -1) {
            console.log("ERROR; invalid from=" + from + " index in move operation");
            return;
        }
        var realTo = mapRowToSource(to);
        if (realTo == -1) {
            // assuming wanting to move to end of list
            realTo = ApplicationManager.count;
        }
        ApplicationManager.move(realFrom, realTo);
    }

    model: ApplicationManager
    dynamicSortFilter: true
    filterRole: ApplicationManager.RoleStage
    filterRegExp: RegExp(stage)

    onLayoutChanged: {
        focusedApplication = get(0);
         print("LAYOUT CHANGED", focusedApplication.appId)
    }
}
