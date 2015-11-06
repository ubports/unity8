/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Utils 0.1 as Utils

Loader {
    id: root
    anchors.fill: parent

    property url style
    readonly property var parsedStyle: String(style)
        .match(/^(color|gradient):\/\/\/(?:(#(?:[0-9a-f]{3,4}){1,2}|[a-z]{3,}))(?:\/(#(?:[0-9a-f]{3,4}){1,2}|[a-z]{3,}))?\/?$/i)
    readonly property var luminance: {
        if (!parsedStyle) return 0.5;
        if (parsedStyle[1] === "color") return Utils.Style.luminance(parsedStyle[2]);
        else if (parsedStyle[1] === "gradient") return Utils.Style.luminance(parsedStyle[2], parsedStyle[3]);
    }

    // FIXME this is only here for highlight purposes (see DashNavigation.qml, too)
    readonly property color topColor: parsedStyle ? parsedStyle[2] : UbuntuColors.lightGrey

    sourceComponent: {
        if (style == "") return null;
        if (!parsedStyle) return image;
        if (parsedStyle[1] === "color") return solid
        if (parsedStyle[1] === "gradient") return gradient
    }

    onLoaded: if (item.hasOwnProperty("parsedStyle")) {
        item.parsedStyle = Qt.binding(function() { return root.parsedStyle } );
    }

    Component {
        id: solid

        Rectangle {
            objectName: "solid"

            property var parsedStyle

            color: parsedStyle ? parsedStyle[2] : "#ffffff"
        }
    }

    Component {
        id: gradient

        Rectangle {
            objectName: "gradient"

            property var parsedStyle

            gradient: Gradient {
                GradientStop { position: 0; color: parsedStyle ? parsedStyle[2] : "#000000" }
                GradientStop { position: 1; color: parsedStyle ? parsedStyle[3] : "#000000" }
            }
        }
    }

    Component {
        id: image

        Image {
            objectName: "image"

            source: width > 0 && height > 0 && root.style || ""

            sourceSize.width: width
            sourceSize.height: height
        }
    }
}
