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
import "../Components"

Item {
    id: root

    property ListView list

    Binding {
        target: list
        property: "bottomMargin"
        value: d.bottomMargin
    }

    function setMakeSureVisibleItem(item) {
        d.previousVisibleHeight = d.visibleHeight;
        d.makeSureVisibleItem = item;
    }

    QtObject {
        id: d
        property var makeSureVisibleItem
        property real previousVisibleHeight: 0
        readonly property real visibleHeight: list.height - list.bottomMargin
        readonly property real bottomMargin: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0

        onVisibleHeightChanged: {
            if (makeSureVisibleItem && makeSureVisibleItem.activeFocus && previousVisibleHeight > visibleHeight) {
                var textAreaPos = makeSureVisibleItem.mapToItem(list, 0, 0);
                if (textAreaPos.y + makeSureVisibleItem.height > visibleHeight) {
                    list.contentY += textAreaPos.y + makeSureVisibleItem.height - visibleHeight
                }
            }
            previousVisibleHeight = visibleHeight;
        }
    }
}
