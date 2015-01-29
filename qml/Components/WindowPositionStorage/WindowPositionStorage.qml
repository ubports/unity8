/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import QtQuick 2.2
import QtQuick.LocalStorage 2.0

QtObject {

    property var priv: QtObject {
        property var db: null

        function openDB() {
            if (db !== null) return;

            db = LocalStorage.openDatabaseSync("unity8", "0.1", "", 100000);
            try {
                db.transaction(function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS windowproperties(windowId TEXT UNIQUE, x INTEGER, y INTEGER, width INTEGER, height INTEGER)');
                });
            } catch (err) {
                console.log("Error creating table in database: " + err);
            };
        }
    }

    function savePosition(windowId, x, y, width, height) {
        priv.openDB();
        priv.db.transaction( function(tx){
            tx.executeSql('INSERT OR REPLACE INTO windowproperties VALUES(?, ?, ?, ?, ?)', [windowId, x, y, width, height]);
        });
    }

    function getPosition(windowId) {
        priv.openDB();
        var res = new Object();
        priv.db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT x, y, width, height FROM windowproperties WHERE windowId=?;', [windowId]);
            if (rs.rows.length === 0) {
                res = undefined;
            } else {
                res.x = rs.rows.item(0).x
                res.y = rs.rows.item(0).y
                res.width = rs.rows.item(0).width
                res.height = rs.rows.item(0).height
            }
        });
        return res;
    }
}
