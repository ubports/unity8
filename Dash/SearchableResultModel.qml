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

import Utils 0.1
import Unity 0.1

SortFilterProxyModel {
    id: root

    property string searchQuery: ""
    property bool hideOnSearch: false

    filterRole: CategoryResults.RoleTitle

    onSearchQueryChanged: {
        if (searchQuery.length == 0) {
            filterRegExp = RegExp("");
            filterCaseSensitivity = Qt.CaseInsensitive;
        } else if (!hideOnSearch) {
            setFilterWildcard(searchQuery);
            filterCaseSensitivity = Qt.CaseInsensitive;
        } else {
            filterRegExp = /^$/;
            filterCaseSensitivity = Qt.CaseInsensitive;
        }
    }
}
