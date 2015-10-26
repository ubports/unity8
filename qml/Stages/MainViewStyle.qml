/*
 * Copyright 2012 Canonical Ltd.
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
import QtQuick 2.4
import Ubuntu.Components 1.3

// FIXME: copied with slight modifications from Ubuntu UI Toolkit's Ambiance's theme
Item {
    anchors.fill: parent
    z: -1
    id: mainViewStyle

   property var theme

    /*!
      Color of the header's background.

      \sa backgroundColor, footerColor
    */
    property color headerColor: styledItem.headerColor

    /*!
      Color of the background.

      The background is usually a single color. However if \l headerColor
      or \l footerColor are set then a gradient of colors will be drawn.

      \sa footerColor, headerColor
    */
    property color backgroundColor: styledItem.backgroundColor

    /*!
      Color of the footer's background.

      \sa backgroundColor, headerColor
    */
    property color footerColor: styledItem.footerColor

    Gradient {
        id: backgroundGradient
        GradientStop { position: 0.0; color: mainViewStyle.headerColor }
        GradientStop { position: 0.83; color: mainViewStyle.backgroundColor }
        GradientStop { position: 1.0; color: mainViewStyle.footerColor }
    }

    Rectangle {
        id: backgroundColor
        anchors.fill: parent
        color: mainViewStyle.backgroundColor
        gradient: internals.isGradient ? backgroundGradient : null
    }

    QtObject {
        id: internals
        property bool isGradient: mainViewStyle.backgroundColor != mainViewStyle.headerColor ||
                                  mainViewStyle.backgroundColor != mainViewStyle.footerColor

        /*
          As we don't know the order the property bindings and onXXXChanged signals are evaluated
          we should rely only on one property when changing the theme to avoid intermediate
          theme changes due to properties being evaluated separately.

          Qt bug: https://bugreports.qt-project.org/browse/QTBUG-11712
          */
        property string theme: (ColorUtils.luminance(styledItem.backgroundColor) >= 0.85) ? "Ambiance" : "SuruDark"
    }

    // automatically select the appropriate theme depending on the background colors
    Binding {
        target: theme
        property: "name"
        value: internals.theme
        when: internals.theme !== ""
    }
}
