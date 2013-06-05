/*
 * Copyright (C) 2013 Canonical, Ltd.
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

Item {
    id: effect
    property bool enabled: topGapPx != positionPx || bottomGapPx != positionPx
    property Item sourceItem
    property ShaderEffectSource source: ShaderEffectSource {
        sourceItem: effect.enabled ? effect.sourceItem : null
        hideSource: effect.enabled
        live: effect.enabled
        sourceRect: {
          if (effect.enabled) {
            Qt.rect(0, -effect.topOverflow, sourceItem.width, sourceItem.height + effect.topOverflow + effect.bottomOverflow)
          } else {
            Qt.rect(0, 0, 0, 0)
          }
        }
    }

    /*!
    \qmlproperty real positionPx
    The y coordinate of where to perform the split.

    \qmlproperty real topGapPx
    Gap's top edge.

    \qmlproperty real bottomGapPx
    Gap's bottom edge.

    \qmlproperty real topOverflow
    How much of the sourceItem should be sourced above its bounds.

    \qmlproperty real bottomOverflow
    How much of the sourceItem should be sourced below its bounds.
    */

    property real positionPx: 0
    property real topGapPx: 0
    property real bottomGapPx: height
    property real topOverflow: 0.0
    property real bottomOverflow: 0.0
    property real topOpacity: 1.0
    property real bottomOpacity: 1.0

    property real __roundedPositionPx: Math.round(positionPx)

    ShaderEffect {
        id: top
        visible: effect.enabled
        opacity: topOpacity
        property ShaderEffectSource source: effect.source
        property real positionPx: __roundedPositionPx
        property real factor: effect.height / height

        clip: true

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: -topOverflow - positionPx + topGapPx
        }
        height: topOverflow + positionPx

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 qt_TexCoord0;
            uniform highp float factor;

            void main() {
                highp vec4 pos = qt_Vertex;
                pos.y *= factor;
                gl_Position = qt_Matrix * pos;
                qt_TexCoord0 = qt_MultiTexCoord0;
            }
        "
    }

    ShaderEffect {
        id: bottom
        visible: effect.enabled
        opacity: bottomOpacity
        property ShaderEffectSource source: effect.source
        property real offset: effect.topOverflow + __roundedPositionPx
        property real factor: effect.height / height

        clip: true

        anchors {
            left: parent.left
            right: parent.right
        }
        y: topOverflow + bottomGapPx
        height: sourceItem.height - positionPx + bottomOverflow

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 qt_TexCoord0;
            uniform highp float factor;
            uniform highp float offset;

            void main() {
                highp vec4 pos = qt_Vertex;
                pos.y = (pos.y * factor) - offset;
                gl_Position = qt_Matrix * pos;
                qt_TexCoord0 = qt_MultiTexCoord0;
            }
        "
    }
}
