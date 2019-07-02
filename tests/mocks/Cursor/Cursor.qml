/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import UInput 0.1

Canvas {
    id: root

    property int topBoundaryOffset // effectively panel height
    property Item confiningItem

    signal pushedLeftBoundary(real amount, int buttons)
    signal pushedRightBoundary(real amount, int buttons)
    signal pushedTopBoundary(real amount, int buttons)
    signal pushedTopLeftCorner(real amount, int buttons)
    signal pushedTopRightCorner(real amount, int buttons)
    signal pushedBottomLeftCorner(real amount, int buttons)
    signal pushedBottomRightCorner(real amount, int buttons)
    signal pushStopped()
    signal mouseMoved()

    width: units.gu(2)
    height: units.gu(2)
    antialiasing: true

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.clearRect(0,0,width, height);
        ctx.strokeStyle = "#000000";
        ctx.lineWidth = 1
        ctx.fillStyle = "#ffffff";
        ctx.globalAlpha = 1.0;
        ctx.lineJoin = "round";
        ctx.beginPath();

        // put rectangle in the middle
        // draw the rectangle
        ctx.moveTo(width/2,height);
        ctx.lineTo(width, height/2);
        ctx.lineTo(0,0);

        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        ctx.restore();
    }

    Connections {
        target: UInput
        onMouseMoved: {
            var newX = root.x;
            newX += dx;
            if (newX < 0) newX = 0;
            else if (newX >= parent.width) newX = parent.width-1;

            var newY = root.y;
            newY += dy;
            if (newY < 0) newY = 0;
            else if (newY >= parent.height) newY = parent.height-1;

            root.x = newX;
            root.y = newY;
            root.mouseMoved();
        }
    }
}
