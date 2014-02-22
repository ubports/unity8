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

    // In case it can be expanded, should we filter it
    property bool filter: true

    property int collapsedRowCount: 1

    property int collapsedHeight: height

    property int columns: 1

    property int rows: 1

    // Index of the highlighted item
    property int highlightIndex: -1

    property int margins: 0

    property int uncollapsedHeight: height

    property var delegateCreationBegin: undefined

    property var delegateCreationEnd: undefined

    property real verticalSpacing: 0

    // The current item of the renderer
    property var currentItem

    // The model to renderer
    property var model

    /// Emitted when the user clicked on an item
    /// @param index is the index of the clicked item
    /// @param itemY is y of the clicked delegate
    signal clicked(int index, real itemY)

    /// Emitted when the user pressed and held on an item
    /// @param index is the index of the held item
    /// @param itemY is y of the held delegate
    signal pressAndHold(int index, real itemY)

    function startFilterAnimation(filter) {
    }

    /// Whether this is the first item in the list
    property bool firstItem: false

    /// Whether this is the last item in the list
    property bool lastItem: false

    Component.onCompleted: console.log(firstItem, lastItem)
    onFirstItemChanged: console.log(firstItem, lastItem)
    onLastItemChanged: console.log(firstItem, lastItem)

    Image {
        visible: !firstItem
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_lightgrad.png"
        z: -1
    }

    Image {
        visible: !lastItem
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        fillMode: Image.Stretch
        source: "graphics/dash_divider_top_darkgrad.png"
        z: -1
    }
}
