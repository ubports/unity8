/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import "../../../Components"

TestCase {
    name: "OpenEffectTest"

    function test_openeffect_enabled() {
        compare(openEffect1.enabled, true, "OpenEffect should be enabled if gap is greather than 0.0")
    }

    function test_openeffect_shadereffectsource() {
        compare(openEffect1.source.hideSource, true, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceItem, rectangle2, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.live, false, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.x, 0, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.y, 0, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.width, 50, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.height, 71, "OpenEffect ShaderEffectSource is incorrect")
        openEffect1.gap=2.0
        compare(openEffect1.source.sourceRect.x, 0, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.y, 0, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.width, 50, "OpenEffect ShaderEffectSource is incorrect")
        compare(openEffect1.source.sourceRect.height, 72, "OpenEffect ShaderEffectSource is incorrect")
    }

    Rectangle {
        id: rectangle1

        width: 100; height: 100

        Rectangle {
            id: rectangle2
            width: 50; height: 50
        }

        OpenEffect {
            id: openEffect1
            anchors {
                fill: parent
            }

            property real gap: 1.0

            topGapPx: (1 - gap) * positionPx
            topOpacity: (1 - gap * 1.2)
            bottomGapPx: positionPx + gap * 10
            bottomOverflow: 20 + gap
            bottomOpacity: 1 - (gap * 0.8)

            positionPx: gap
            sourceItem: rectangle2
        }
    }
}
