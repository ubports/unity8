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

Item {
    id: root
    anchors.fill: sourceItem
    anchors.margins: -units.gu(2)
    visible: sourceItem !== null

    property var sourceItem: null
    property int maskX: 0
    property int maskY: 0
    property int maskWidth: 0
    property int maskHeight: 0

    property real opacityValue: 1

    Item {
        id: opacityMask
        anchors.fill: parent

        Rectangle {
            id: clipRect
            color: "black"
            x: root.maskX - root.anchors.margins
            y: root.maskY - root.anchors.margins
            width: root.maskWidth
            height: root.maskHeight
            opacity: 1 - root.opacityValue
        }
    }

    ShaderEffect {
        id: opacityEffect
        anchors.fill: parent

        property variant source: ShaderEffectSource {
            id: shaderEffectSource
            sourceItem: root.sourceItem
            sourceRect: root.sourceItem ? Qt.rect(sourceItem.x + root.anchors.margins,
                                                sourceItem.y + root.anchors.margins,
                                                sourceItem.width - root.anchors.margins * 2,
                                                sourceItem.height - root.anchors.margins * 2)
                                        : Qt.rect(0,0,0,0)
            hideSource: true
        }

        property var mask: ShaderEffectSource {
            sourceItem: opacityMask
            hideSource: true
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform sampler2D mask;
            void main(void)
            {
                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                highp vec4 maskColor = texture2D(mask, qt_TexCoord0);

                sourceColor *= 1.0 - maskColor.a;

                gl_FragColor = sourceColor;
            }"
    }
}
