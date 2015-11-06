/*
 * Copyright (C)  2015 Canonical, Ltd.
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

/*
 * This is a shim greeter that is only used to provide a shell,
 * running without a greeter, the requisite information
 *
 */

/* FIXME: this shuld be fine as a QtObject, but bug lp:1447391
 * dictates wrapping as an item instead
 */
Item {
    id: shimGreeter

    readonly property bool active: false
    readonly property bool hasLockedApp: lockedApp !== ""
    readonly property bool locked: false
    readonly property bool shown: false
    readonly property bool waiting: false

    property string lockedApp: ""

    // Since ShimGreeter is never active, these can just return
    property var forceShow: (function() { return; })
    property var notifyAboutToFocusApp: (function(appId) { return; })
    property var notifyAppFocused: (function(appId) { return; })
    property var notifyShowingDashFromDrag: (function(appId) { return false; })

}
