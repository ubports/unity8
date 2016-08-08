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

.pragma library

/* TODO the "8" is is DEFAULT_GRID_UNIT_PX, we use it to normalize the values with the current grid unit size.
   Add a way to fetch this default grid unit px value from UITK. */

function getFlickDeceleration(gridUnit) {
    return 1500 * gridUnit / 8;
}

function getMaximumFlickVelocity(gridUnit) {
    return 2500 * gridUnit / 8;
}