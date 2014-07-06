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
    property var style: Object()

    /*! \brief Calculate luminance of the passed color

        \note If not fully opaque, luminance is dependant on blending.
     */
    function luminance(color) {
        return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    }

    /// Color used for text and symbolic icons
    // FIXME: should be taken from the theme
    readonly property color foreground: style && "foreground-color" in style ? style["foreground-color"] : "grey"

    /// Color used for the overall background
    readonly property color background: style && "background-color" in style ? style["background-color"] : "transparent"

    /*! \brief Luminance threshold for switching between fore and background color

        \note If background colour is not fully opaque, it's not taken into account.
     */
    readonly property real threshold: background.a !== 1.0 ? d.foregroundLuminance : (d.foregroundLuminance + d.backgroundLuminance) / 2

    /// Whether back- and foreground colors are inversed (light on dark instead of dark on light)
    readonly property bool inverse: d.foregroundLuminance < (background.a !== 1.0 ? 0.5 : d.backgroundLuminance)

    property var d: QtObject {
        readonly property real foregroundLuminance: luminance(foreground)
        readonly property real backgroundLuminance: luminance(background)
    }
}
