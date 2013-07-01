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
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1

/*
 A DirectionalDragArea wrapper that provides some well-chosen defaults
 for its gesture recognition parameters.
*/
DirectionalDragArea {

    // TODO: Re-evaluate those or even the recognition heuristics itself once
    // we have gesture cancelling/forwarding in place.
    //
    // The idea here is that it's better having lax rules than false negatives.
    // False negatives are very frustrating to the user.
    maxDeviation: units.gu(3)
    wideningAngle: 50
    distanceThreshold: units.gu(1.5)
    minSpeed: units.gu(0) // some people were getting false negatives with it enabled.
}
