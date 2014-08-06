/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1

// FIXME: copied with slight modifications from Ubuntu UI Toolkit's Ambiance's theme
Item {
    // styling properties
    anchors.fill: parent
    z: -1
    id: mainViewStyle

    /*!
      The background texture of the main view. The image will be drawn over the background color,
      so if it has (semi-)transparent pixels, in those pixels the background color will be visible.
     */
    property url backgroundSource: "graphics/background_paper.png"
    property var theme

    Gradient {
        id: backgroundGradient
        GradientStop { position: 0.0; color: styledItem.headerColor }
        GradientStop { position: 0.83; color: styledItem.backgroundColor }
        GradientStop { position: 1.0; color: styledItem.footerColor }
    }

    Rectangle {
        id: backgroundColor
        anchors.fill: parent
        color: styledItem.backgroundColor
        gradient: internals.isGradient ? backgroundGradient : null
    }

    Image {
        id: backgroundTexture
        anchors.fill: parent
        source: mainViewStyle.backgroundSource
        fillMode: Image.Tile
    }

    QtObject {
        id: internals
        property bool isGradient: styledItem.backgroundColor != styledItem.headerColor ||
                                  styledItem.backgroundColor != styledItem.footerColor
        /*
          As we don't know the order the property bindings and onXXXChanged signals are evaluated
          we should rely only on one property when changing the theme to avoid intermediate
          theme changes due to properties being evaluated separately.

          Qt bug: https://bugreports.qt-project.org/browse/QTBUG-11712
          */
        property string theme: (ColorUtils.luminance(styledItem.backgroundColor) >= 0.85) ? "Ambiance" :
                                (isGradient ? "SuruGradient" : "SuruDark")
    }

    // automatically select the appropriate theme depending on the background colors
    Binding {
        target: theme
        property: "name"
        value: internals.theme
        when: internals.theme !== ""
    }
}
