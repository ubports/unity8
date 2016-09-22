/*
 * Copyright (C) 2016 Canonical, Ltd.
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

Image {
    id: root

    property color color
    readonly property string fragColorShader:
        "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp vec4 color;
            uniform lowp float qt_Opacity;

            void main()
            {
                lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                gl_FragColor = color * sourceColor.a * qt_Opacity;
            }
        "

    fillMode: Image.PreserveAspectFit
    height: sourceSize.height

    ShaderEffect {
        readonly property color color: root.color
        readonly property Image source: parent

        height: source.height; width: source.width
        fragmentShader: fragColorShader
    }
}
