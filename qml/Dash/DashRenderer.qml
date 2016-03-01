/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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

Item {
    property real collapsedHeight

    property real expandedHeight

    property int collapsedItemCount: -1

    property int cacheBuffer: 0

    property int displayMarginBeginning: 0

    property int displayMarginEnd: 0

    property real originY: 0

    property bool growsVertically: true

    // If growsVertically the width of the item inside the renderer
    property real innerWidth: 0

    // The model to renderer
    property var model

    /// CardTool component.
    property var cardTool: null

    /// ScopeStyle component.
    property var scopeStyle: null

    /// Emitted when the user clicked on an item
    /// @param index is the index of the clicked item
    /// @param result result model of the clicked item, used for activation
    /// @param item item that has been clicked
    /// @param itemModel model of the item
    signal clicked(int index, var result, var item, var itemModel)

    /// Emitted when the user pressed and held on an item
    /// @param index is the index of the held item
    /// @param result result model of the clicked item, used for activation
    /// @param itemModel model of the item
    signal pressAndHold(int index, var result, var itemModel)

    /// Emitted when the user clicked on an item action
    /// @param index is the index of the clicked item
    /// @param result result model of the clicked item, used for activation
    /// @param actionId id of the clicked action
    signal action(int index, var result, var actionId)
}
