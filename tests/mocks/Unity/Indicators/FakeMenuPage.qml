/*
 * Copyright 2013 Canonical Ltd.
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

Flickable {
    objectName: "fakeMenuPlugin"
    // Make it compatible with the PluginItem interface
    function start() {
        if (shell != undefined && shell.indicator_status != undefined) {
            shell.indicator_status[objectName].started = true;
        }
    }
    function stop() {
        if (shell != undefined && shell.indicator_status != undefined) {
            shell.indicator_status[objectName].started = false;
        }
    }
    function reset() {
        if (shell != undefined && shell.indicator_status != undefined) {
            shell.indicator_status[objectName].reset++;
        }
    }
}
