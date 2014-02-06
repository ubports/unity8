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
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(20)
    height: units.gu(10)
    color: "black"

    RatingStars {
        id: ratingStars
        anchors.centerIn: parent
        maximumRating: 5
        rating: 3
    }

    UT.UnityTestCase {
        name: "RatingStars"
        when: windowShown

        function init() {
            ratingStars.maximumRating = 5
            ratingStars.rating = 3
        }

        function test_interactive_rating_data() {
            return [
                {tag: "first star without interactive", interactive: false, maximumRating: 5, index: 0, rating: 3},
                {tag: "first star", interactive: true, maximumRating: 5, index: 0, rating: 1},
                {tag: "second star with big maximumRating", interactive: true, maximumRating: 100, index: 1, rating: 40},
                {tag: "last star", interactive: true, maximumRating: 5, index: 4, rating: 5},
            ];
        }

        function test_interactive_rating(data) {
            ratingStars.interactive = data.interactive
            ratingStars.maximumRating = data.maximumRating

            var ratingStar = findChild(ratingStars, "ratingStar"+data.index)
            mouseClick(ratingStar, ratingStar.width / 2, ratingStar.height / 2)
            compare(ratingStars.rating, data.rating)

            ratingStars.interactive = false
        }

        function test_rating_init() {
            compare(ratingStars.effectiveRating, ratingStars.rating, "EffectiveRating not initialized properly")
        }

        function test_rating_negative() {
            ratingStars.rating = -3
            compare(ratingStars.effectiveRating, 0, "EffectiveRating not calculated correctly")
        }

        function test_rating_set_ok() {
            ratingStars.rating = 2
            compare(ratingStars.effectiveRating, ratingStars.rating, "EffectiveRating not calculated correctly")
        }

        function test_rating_set_too_big() {
            ratingStars.rating = 200
            compare(ratingStars.effectiveRating, ratingStars.maximumRating, "EffectiveRating not calculated correctly")
        }

        function test_rating_set_min() {
            ratingStars.rating = 0
            compare(ratingStars.effectiveRating, 0, "EffectiveRating not calculated correctly")
        }

        function test_rating_set_max() {
            ratingStars.rating = ratingStars.maximumRating
            compare(ratingStars.effectiveRating, ratingStars.maximumRating, "EffectiveRating not calculated correctly")
        }
    }
}
