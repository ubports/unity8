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

import QtQuick 2.4
import Ubuntu.Components 1.3

/*!
 \brief Base delegate for use with the Carousel component

 Use this as the base of your component in a Carousel, the properties
 will get updated and signals emitted accordingly.
*/

Item {
    /// True if this item is currently "focused" in the carousel.
    property bool explicitlyScaled

    /// Model index for this delegate.
    property int index

    /// Model data for this delegate.
    property var model

    /// Will be emitted when the item is tapped.
    signal clicked

    /// Will be emitted when the item is long-pressed.
    signal pressAndHold
}
