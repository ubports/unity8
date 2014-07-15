/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 0.1

Flickable {
    id: root

    property alias model: cardFilterGrid.model
    property alias cardTool: cardFilterGrid.cardTool

    property real extraHeight: 0

    signal clicked(int index, var result, var item, var itemModel)
    signal pressAndHold(int index)

    contentHeight: cardFilterGrid.height + extraHeight
    contentWidth: cardFilterGrid.width

    function scopeCardPosition(scopeId) {
        var index = model.scopeIndex(scopeId);
        var pos = cardFilterGrid.cardPosition(index);
        pos.y = pos.y - root.contentY;
        return pos;
    }

    CardFilterGrid {
        id: cardFilterGrid
        width: parent.width

        Component.onCompleted: {
            setFilter(false, false);
        }

        onClicked: {
            root.clicked(index, result, item, itemModel);
        }
        onPressAndHold: {
            root.pressAndHold(index);
        }
    }
}
