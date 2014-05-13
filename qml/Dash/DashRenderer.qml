/*
 * Copyright (C) 2013 Canonical, Ltd.
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

Item {
    // Can the item be expanded?
    property bool expandable: false

    // In case it can be expanded, is it filtered
    property bool filtered: true

    property int collapsedHeight: height

    property int margins: 0

    property int uncollapsedHeight: height

    property var delegateCreationBegin: undefined

    property var delegateCreationEnd: undefined

    property real originY: 0

    property real verticalSpacing: 0

    // The current item of the renderer
    property var currentItem

    // The model to renderer
    property var model

    /*!
     \brief CardTool component.
     */
    property var cardTool: undefined

    /// Emitted when the user clicked on an item
    /// @param index is the index of the clicked item
    /// @param itemY is y of the clicked delegate
    signal clicked(int index, real itemY)

    /// Emitted when the user pressed and held on an item
    /// @param index is the index of the held item
    /// @param itemY is y of the held delegate
    signal pressAndHold(int index, real itemY)

    function setFilter(filter, animate) {
    }
}
