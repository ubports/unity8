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

import QtQuick 2.0
import GSettings 1.0

QtObject {
    id: root

    property string usageMode: "Staged"

    // FIXME: Works around a bug where if we change a Loader's source in response to a GSettings
    // property change in the same event loop, the Loader's previously loaded component does not
    // get destroyed and its bindings continue to operate!
    //
    // Shouldn't be needed after
    // https://code.launchpad.net/~lukas-kde/gsettings-qt/queued-processing/+merge/259883 gets
    // merged.
    property var timer: Timer {
        interval: 1
        onTriggered: { root.usageMode = root.wrapped.usageMode; }
    }
    property var wrappedConnections: Connections {
        target: root.wrapped
        ignoreUnknownSignals: true // don't spam us
        onUsageModeChanged: { root.timer.start(); }
    }
    property var wrapped: GSettings {
        schema.id: "com.canonical.Unity8"
        Component.onCompleted: {
            // init the value. it's a dynamic prop, so we have to check first
            if (root.usageMode) {
                root.usageMode = root.wrapped.usageMode;
            }
        }
    }
}
