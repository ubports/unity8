/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.2

/*! \brief Helper for processing scope customization options.

    It will take the customizations object passed by the scope and
    process it to provide the scope UI with data such as colors or
    image paths.
 */

QtObject {
    /// Style object passed from the scope
    property var style: {}

    /// Calculate luminance of the passed color
    function luminance(color) {
        return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    }

    /// Color used for text and symbolic icons
    // FIXME: should be taken from the theme
    readonly property color foreground: style && "foreground-color" in style ? style["foreground-color"] : "grey"

    /// Color used for text and symbolic icons
    readonly property color background: style && "background-color" in style ? style["background-color"] : "transparent"
}
