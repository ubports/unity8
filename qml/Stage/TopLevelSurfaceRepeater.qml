/*
 * Copyright (C) 2016 Canonical, Ltd.
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

Repeater {
    id: root
    // FIXME: This is a hack around us not knowing whether the Repeater has finished creating its
    // delegates on start up.
    // This is a problem when the stage gets a TopLevelSurfaceList already populated with several
    // rows.
    property bool startingUp: true
    onStartingUpChanged: {
        if (!startingUp) {
            // the top-most surface must be the focused one.
            var topmostDelegate = itemAt(0);
            topmostDelegate.focus = true;
        }
    }

    onItemAdded: {
        if (startingUp) {
            checkIfStillStartingUp();
        }
    }

    function checkIfStillStartingUp() {
        var i = 0;
        var missingDelegate = false;
        for (i = 0; i < model.count && !missingDelegate; ++i) {
            if (!itemAt(i)) {
                missingDelegate = true;
            }
        }
        if (!missingDelegate) {
            startingUp = false;
        }
    }
}
