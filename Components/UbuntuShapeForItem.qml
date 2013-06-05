/*
 * Copyright (C) 2012 Canonical, Ltd.
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
import Ubuntu.Components 0.1 as Theming

/* FIXME: This component is duplicating the UbuntuShape from the SDK, but shapes more
 * general (Item-based) components. This ability should be incorporated into the SDK's
 * UbuntuShape so this file can be removed.
 * Bug: https://bugs.launchpad.net/tavastia/+bug/1089595
 */

Item {
    id: shape

    Theming.ItemStyle.class: "UbuntuShape-radius-" + radius

    property string radius: "small"
    property url maskSource: Theming.ComponentUtils.style(shape, "maskSource", "")
    property url borderSource: Theming.ComponentUtils.style(shape, "borderIdle", "")
    property Item image

    implicitWidth: units.gu(8)
    implicitHeight: units.gu(8)

    onWidthChanged: __updateImageDimensions()
    onHeightChanged: __updateImageDimensions()
    onImageChanged: __updateImageDimensions()

    function __updateImageDimensions() {
        if (!image) return;
        image.width = shape.width;
        image.height = shape.height;
        image.visible = false;
    }

    ShaderEffect {
        anchors.fill: parent
        visible: shape.image

        property ShaderEffectSource mask: ShaderEffectSource {
            sourceItem: BorderImage {
                width: shape.width
                height: shape.height
                source: shape.maskSource
                visible: false
            }
        }

        property ShaderEffectSource image: ShaderEffectSource {
            sourceItem: shape.image
        }

        fragmentShader:
            "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform sampler2D mask;
            uniform sampler2D image;

            void main(void)
            {
                lowp vec4 maskColor = texture2D(mask, qt_TexCoord0.st);
                lowp vec4 imageColor = texture2D(image, qt_TexCoord0.st);
                gl_FragColor = imageColor * maskColor.a * qt_Opacity;
            }
            "
    }

    BorderImage {
        id: border

        anchors.fill: parent
        source: shape.borderSource
    }
}
