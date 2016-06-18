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
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3

Label {
    property real fadeDistance: units.gu(8)

    layer.enabled: contentWidth > width
    layer.effect: ShaderEffect {
        property real fadeThreshold: Math.min(1, Math.max(0, 1 - fadeDistance / width))

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform sampler2D source;
            uniform lowp float fadeThreshold;
            void main(void)
            {
                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                lowp float alpha = 1.0;
                if (qt_TexCoord0.x > fadeThreshold && fadeThreshold < 1.0)
                    alpha = (1.0 - qt_TexCoord0.x) / (1.0 - fadeThreshold);
                gl_FragColor = sourceColor * alpha * qt_Opacity;
            }"
    }
}
