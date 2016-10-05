/*
 * Copyright (C) 2013,2016 Canonical, Ltd.
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

Canvas {
    id: root
    property color color
    property real circleScale
    property var centerCircle

    onColorChanged: requestPaint()
    onCircleScaleChanged: requestPaint()
    onCenterCircleChanged: requestPaint()

    onPaint: {
        if (circleScale <= 0) {
            return;
        }

        var ctx = getContext("2d");

        // draw big circle
        ctx.save();
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(width / 2, height / 2, circleScale * width / 2, 0, 2 * Math.PI, false);
        ctx.fill();
        ctx.restore();

        // chop out inner infographics circle
        if (centerCircle) {
            var circleMiddle = mapFromItem(centerCircle,
                                           centerCircle.width / 2,
                                           centerCircle.height / 2);
            ctx.save();
            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();
            ctx.arc(circleMiddle.x, circleMiddle.y, centerCircle.width / 2, 0, 2 * Math.PI, false);
            ctx.fill();
            ctx.restore();
        }
    }
}
