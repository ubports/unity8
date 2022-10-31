/*
 * Copyright (C) 2015 Canonical Ltd.
 * Copyright (C) 2021 UBports Foundation
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
import Lomiri.Components 1.3

Item {
    id: root

    // Provide a list of wallpapers to resolve here, preferred ones first
    property var candidates: []

    property bool cache: true

    readonly property url background: {
        for (var i = 0; i < repeater.count; i++) {
            var image = repeater.itemAt(i);
            var expectedImageSource = Qt.resolvedUrl(candidates[i]);
            if (image.source != expectedImageSource)
                return "";
            if (image.status === Image.Ready)
                return candidates[i];
            if (image.status === Image.Loading)
                return "";
        }
        if (candidates.length > 0) {
            return candidates.slice(-1)[0]; // last item is last resort
        } else {
            return "";
        }
    }

    Repeater {
        id: repeater
        model: root.candidates.slice(0, -1)
        delegate: Image {
            source: modelData
            asynchronous: true
            cache: root.cache
            height: 0
            width: 0
            sourceSize.height: 1
            sourceSize.width: 1
        }
    }
}
