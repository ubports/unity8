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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    // Provide a list of wallpapers to resolve here, preferred ones first
    property var candidates: []

    readonly property url background: {
        for (var i = 0; i < repeater.count; i++) {
            if (repeater.itemAt(i).status === Image.Ready)
                return candidates[i];
        }
        if (i > 0) {
            return candidates[i - 1]; // last item is last resort
        } else {
            return "";
        }
    }

    Repeater {
        id: repeater
        model: root.candidates
        delegate: Image {
            source: modelData
            height: 0
            width: 0
            sourceSize.height: 0
            sourceSize.width: 0
        }
    }
}
