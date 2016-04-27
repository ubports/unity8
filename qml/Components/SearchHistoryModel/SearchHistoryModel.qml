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

pragma Singleton
import QtQuick 2.4

// TODO sanitize input, move to persistent storage

ListModel {
    function addQuery(newQuery) {
        // strip whitespaces
        newQuery = newQuery.replace(/^\s+|\s+$/g, '');
        // ignore empty queries
        if (newQuery == "") return
        for (var i = 0; i < count; i++) {
            if (get(i).query == newQuery) {
                // promote existing entry
                move(i, 0, 1)
                return
            }
        }
        // add a new entry
        insert(0, { "query": newQuery })
        if (count > 3) {
            // remove entries if there's more than three
            remove(3)
        }
    }
}
