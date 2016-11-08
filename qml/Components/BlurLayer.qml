/*
 * Copyright (C) 2015 Canonical, Ltd.
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

Item {
    id: root

    property alias source: shaderEffectSource.sourceItem
    property real saturation: 1
    property real brightness: 1
    property real blurRadius: 0

    readonly property alias ready: shaderEffectSource.ready

    ShaderEffect {
        id: desaturateEffect
        anchors.fill: root

        property real saturationValue: Math.min(Math.max(root.saturation, 0), 1)
        property real brightnessValue: Math.min(Math.max(root.brightness, 0), 1)

        property variant source: ShaderEffectSource {
            id: shaderEffectSource
            hideSource: root.visible
            live: !root.visible
            property bool ready: false;
            onLiveChanged: {
                if (!live) {
                    ready = false;
                    scheduleUpdate();
                }
            }
            onScheduledUpdateCompleted: ready = true;
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float saturationValue;
            uniform lowp float brightnessValue;
            void main(void)
            {
                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                highp vec4 scaledColor = sourceColor * vec4(0.3, 0.59, 0.11, 1.0);
                lowp float luminance = scaledColor.r + scaledColor.g + scaledColor.b ;
                highp vec4 tmp = mix(vec4(luminance, luminance, luminance, sourceColor.a), sourceColor, saturationValue);
                gl_FragColor = mix(vec4(0, 0, 0, 1), tmp, brightnessValue);
            }"
    }

    FastBlur {
        id: fastBlur
        anchors.fill: parent
        source: desaturateEffect
        visible: radius > 0
        radius: Math.max(root.blurRadius, 0)
    }
}
