/*
 * Copyright (C) 2014 Canonical, Ltd.
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

.pragma library

/*! \brief Calculate average luminance of the passed colors

    \note If not fully opaque, luminance is dependant on blending.
 */
function luminance() {
    var sum = 0;
    // TODO this was originally
    // for (var k in arguments) {
    // but for some unkown reason was causing crashes in testDash/testDashContent
    // investigate when we have some time
    for (var k = 0; k < arguments.length; ++k) {
        // only way to convert string to color
        var c = Qt.lighter(arguments[k], 1.0);

        sum += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
    }

    return sum / arguments.length;
}
