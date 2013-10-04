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

function threeColorByIndex(index, total, colors) {
    var red, green, blue;
    var p = 0.0;

    if(total > 0) {
        p = index / total;
    }

    if (p < 0.5) {
        red = (colors.main.r * p * 2.0) + colors.start.r * (0.5 - p) * 2.0;
        green = (colors.main.g * p * 2.0) + colors.start.g * (0.5 - p) * 2.0;
        blue = (colors.main.b * p * 2.0) + colors.start.b * (0.5 - p) * 2.0;
    } else {
        red = colors.end.r * (p - 0.5) * 2.0 + colors.main.r * (1.0 - p) * 2.0;
        green = colors.end.g * (p - 0.5) * 2.0 + colors.main.g * (1.0 - p) * 2.0;
        blue = colors.end.b * (p - 0.5) * 2.0 + colors.main.b * (1.0 - p) * 2.0;
    }

    return Qt.rgba(red, green, blue, 1);
}
