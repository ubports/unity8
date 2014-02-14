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
import "../../../qml/Components"

TestCase {
    name: "RatingStars"

    property int maximumRating: 5
    property int rating: 3
    property alias effectiveRating: ratingStars.effectiveRating

    RatingStars {
        id: ratingStars
        maximumRating: parent.maximumRating
        rating: parent.rating
    }

    function test_rating_init() {
        compare(effectiveRating, rating, "EffectiveRating not initialized properly")
    }

    function test_rating_negative() {
        rating = -3
        compare(effectiveRating, 0, "EffectiveRating not calculated correctly")
    }

    function test_rating_set_ok() {
        rating = 2
        compare(effectiveRating, rating, "EffectiveRating not calculated correctly")
    }

    function test_rating_set_too_big() {
        rating = 200
        compare(effectiveRating, maximumRating, "EffectiveRating not calculated correctly")
    }

    function test_rating_set_min() {
        rating = 0
        compare(effectiveRating, 0, "EffectiveRating not calculated correctly")
    }

    function test_rating_set_max() {
        rating = maximumRating
        compare(effectiveRating, maximumRating, "EffectiveRating not calculated correctly")
    }
}
