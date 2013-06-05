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

.pragma library

var factors = {
    "second": [ 1000, "a second ago", "in a second", "%1 seconds ago", "in %1 seconds" ],
    "minute": [ 60, "a minute ago", "in a minute", "%1 minutes ago", "in %1 minutes" ],
    "hour":   [ 60, "an hour ago", "in an hour", "%1 hours ago", "in %1 hours" ],
    "day":    [ 24, "yesterday", "tomorrow", "%1 days ago", "in %1 days" ],
    "week":   [ 7, "a week ago", "in a week", "about %1 weeks ago", "in about %1 weeks" ],
    "month":  [ 4.35, "a month ago", "in a month", "%1 months ago", "in %1 months" ], // == 365.25 days / 12 months / 7 days
    "year":   [ 12, "a year ago", "in a year", "%1 years ago", "in %1 years" ]
}

function readableFromNow(date, now) {
    var then = new Date(date);
    if (isNaN(then)) return "";
    if (now === undefined) {
        now = new Date();
    } else if (isNaN(now)) throw "now is NaN";
    var diff = Math.abs(now - then);
    if (diff < 1000) return "just now";

    var future = now < then;
    var humanDiff;
    for (var k in factors) {
        diff /= factors[k][0];
        if (Math.floor(diff) == 1) {
            humanDiff = factors[k][future ? 2 : 1];
        } else if (Math.floor(diff) > 1) {
            humanDiff = factors[k][future ? 4 : 3].arg(Math.round(diff));
        } else break;
    }
    return humanDiff;
}
