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

import QtQuick 2.4
import Utils 0.1
import GSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

/*! \brief Helper for processing scope customization options.

    It will take the customizations object passed by the scope and
    process it to provide the scope UI with data such as colors or
    image paths.
 */

QtObject {

    property var gsettings: GSettings {
          schema.id: "com.ubuntu.touch.system-settings"
      }

    /// Style object passed from the scope
    property var style: Object()

    /// Color used for text and symbolic icons
    property color foreground: gsettings.dashBackground ? "white" : d.defaultDark

    /// Luminance of the foreground color
    readonly property real foregroundLuminance: foreground ? Style.luminance(foreground) : Style.luminance(d.defaultDark)

    /// Color used for the overall background
    property color background: "background-color" in style ? style["background-color"] : gsettings.dashBackground ? "transparent" : "#00f5f5f5"

    /// Luminance of the background color
    readonly property real backgroundLuminance: background ? Style.luminance(background) : Style.luminance(d.defaultLight)

    /*! \brief Get the most contrasting available color based on luminance
     *
     * If background color is transparent, theme provided colors are taken into account
     */
    function getTextColor(luminance) {
        if (Math.abs(foregroundLuminance - luminance) >
            Math.abs(d.opaqueBackgroundLuminance - luminance)) {
            return foreground;
        } else {
            return d.opaqueBackground;
        }
    }

    /// Source of the logo image for the header
    readonly property url headerLogo: "logo" in d.headerStyle ? d.headerStyle["logo"] : ""

    /// Background style for the header
    property url headerBackground: "background" in d.headerStyle ? d.headerStyle["background"] : gsettings.dashBackground ? "color:///transparent" : "color:///#ffffff"

    /// Foreground color for the header
    property color headerForeground: "foreground-color" in d.headerStyle ? d.headerStyle["foreground-color"] : gsettings.dashBackground ? "white" : foreground

    /// Color of the header divider
    property color headerDividerColor: "divider-color" in d.headerStyle ? d.headerStyle["divider-color"] : gsettings.dashBackground ? "transparent" : "#e0e0e0"

    /// Background style for the navigation
    property url navigationBackground: "navigation-background" in d.headerStyle ? d.headerStyle["navigation-background"] : gsettings.dashBackground ? "color:///white" : "color:///#f5f5f5"

    /// Color of the primary preview button
    readonly property color previewButtonColor: "preview-button-color" in style ? style["preview-button-color"] : theme.palette.normal.positive

    //! @cond
    property var d: QtObject {
        // FIXME: should be taken from the theme
        readonly property color defaultLight: "white"
        readonly property color defaultDark: UbuntuColors.darkGrey
        readonly property real defaultLightLuminance: Style.luminance(defaultLight)
        readonly property real defaultDarkLuminance: Style.luminance(defaultDark)

        readonly property color opaqueBackground: {
            background.a > 0 ?
                        background :
                        (Math.abs(foregroundLuminance - defaultLightLuminance) >
                         Math.abs(foregroundLuminance - defaultDarkLuminance)) ?
                            defaultLight : defaultDark
        }
        readonly property real opaqueBackgroundLuminance: Style.luminance(opaqueBackground)

        readonly property var headerStyle: "page-header" in style ? style["page-header"] : { }
    }
    //! @endcond
}
