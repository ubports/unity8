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
    readonly property color foreground: "foreground-color" in style ? style["foreground-color"] : d.defaultDark

    /// Color used for the overall background
    readonly property color background: "background-color" in style ? style["background-color"] : "transparent"

    /*! \brief Luminance threshold for switching between fore and background color

        \note If background colour is not fully opaque, the defaultLightLuminance it's taken into account instead of it.
     */
    readonly property real threshold: background.a !== 1.0 ? (d.foregroundLuminance + d.defaultLightLuminance) / 2: (d.foregroundLuminance + d.backgroundLuminance) / 2

    /*! \brief The lighter of foreground and background colors

        \note If background color is not fully opaque, it's not taken into account
              and defaults to the theme-provided light color.
     */
    readonly property color light: {
        if (background.a !== 1.0) return d.foregroundLuminance > d.defaultLightLuminance ? foreground : d.defaultLight;
        return d.foregroundLuminance > d.backgroundLuminance ? foreground : background;
    }

    /*! \brief The darker of foreground and background colors

        \note If background color is not fully opaque, it's not taken into account
              and defaults to the theme-provided dark color.
     */
    readonly property color dark: {
        if (background.a !== 1.0) return d.foregroundLuminance < d.defaultDarkLuminance ? foreground : d.defaultDark;
        return d.foregroundLuminance < d.backgroundLuminance ? foreground : background;
    }

    /// Source of the logo image for the header
    readonly property url headerLogo: "logo" in d.headerStyle ? d.headerStyle["logo"] : ""

    //! @cond
    property var d: QtObject {
        readonly property real foregroundLuminance: luminance(foreground)
        readonly property real backgroundLuminance: luminance(background)

        // FIXME: should be taken from the theme
        readonly property color defaultLight: "white"
        readonly property color defaultDark: "grey"
        readonly property real defaultLightLuminance: luminance(defaultLight)
        readonly property real defaultDarkLuminance: luminance(defaultDark)

        readonly property var headerStyle: "page-header" in style ? style["page-header"] : { }
    }
    //! @endcond
}
