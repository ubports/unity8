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
import "../../../Components/carousel.js" as Carousel

TestCase {
    name: "Carousel"

    property real carouselWidth
    property int itemCount
    property real tileWidth

    property real contentWidth: itemCount * tileWidth
    // following variables are copied from Carousel.qml
    // I'm not using the variables directly from there, as then tileWidth and others would be affected as well
    property real gapToMiddlePhase: Math.min(carouselWidth / 2 - tileWidth / 2, (contentWidth - carouselWidth) / 2)
    property real gapToEndPhase: contentWidth - carouselWidth - gapToMiddlePhase
    property real kMiddleIndex: (carouselWidth / 2) / tileWidth - 0.5
    property real kGapEnd: kMiddleIndex * (1 - gapToEndPhase / gapToMiddlePhase)
    property real kXBeginningEnd: 1 / tileWidth + kMiddleIndex / gapToMiddlePhase

    // test for the getContinuousIndex() function
    function test_getContinuousIndex_data() {
        // testing for 10  items of size 100 pixel
        return [ {tag:"at start",
                  x: 0, carouselWidth:400, tileWidth:100, itemCount:10, result: 0},
                 {tag:"in startup",
                  x: 100, carouselWidth:400, tileWidth:100, itemCount:10, result: 2},
                 {tag:"in the middle",
                  x: 350, carouselWidth:400, tileWidth:100, itemCount:10, result: 5},
                 {tag:"at end",
                  x: 600, carouselWidth:400, tileWidth:100, itemCount:10, result: 9},
               ]
    }

    function test_getContinuousIndex(data) {
        carouselWidth = data.carouselWidth
        tileWidth = data.tileWidth
        itemCount = data.itemCount

        var index = Carousel.getContinuousIndex(data.x,
                                                data.tileWidth,
                                                gapToMiddlePhase,
                                                gapToEndPhase,
                                                kGapEnd,
                                                kMiddleIndex,
                                                kXBeginningEnd)
        compare(index, data.result)
    }

    // test for the getXFromContinuousIndex() function
    function test_getXFromContinuousIndex_data() {
        return [ {tag:"at start",
                  index: 0, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:0, result: 0},
                 {tag:"in startup",
                  index: 2, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:0, result: 100},
//                 {tag:"in startup with drawBuffer",
//                  index: 2, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:100, result: 0},
                 {tag:"in the middle",
                  index: 5, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:0, result: 350},
//                 {tag:"in the middle with drawBuffer",
//                  index: 5, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:100, result: 250},
                 {tag:"at end",
                  index: 9, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:0, result: 600},
//                 {tag:"at end with drawBuffer",
//                  index: 9, carouselWidth:400, tileWidth:100, itemCount:10, drawBuffer:100, result: 500},
               ]
    }

    function test_getXFromContinuousIndex(data) {
        carouselWidth = data.carouselWidth
        tileWidth = data.tileWidth
        itemCount = data.itemCount

        var x = Carousel.getXFromContinuousIndex(data.index,
                                                 data.carouselWidth,
                                                 contentWidth,
                                                 data.tileWidth,
                                                 gapToMiddlePhase,
                                                 gapToEndPhase,
                                                 data.drawBuffer)
        compare(x, data.result)
    }

    // test for the getViewTranslation() function
    function test_getViewTranslation_data() {
        return [ {tag:"at start - viewfactor 1",
                  x: 0, carouselWidth:400, tileWidth:100, itemCount:10, translationXViewFactor:1, result: 150},
                 {tag:"at start - viewfactor 2",
                  x: 0, carouselWidth:400, tileWidth:100, itemCount:10, translationXViewFactor:2, result: 300},
                 {tag:"in startup",
                  x: 100, carouselWidth:400, tileWidth:100, itemCount:10, translationXViewFactor:1, result: 50},
                 {tag:"in the middle",
                  x: 350, carouselWidth:400, tileWidth:100, itemCount:10, translationXViewFactor:1, result: 0},
                 {tag:"at end",
                  x: 600, carouselWidth:400, tileWidth:100, itemCount:10, translationXViewFactor:1, result: -150},
               ]
    }

    function test_getViewTranslation(data) {
        carouselWidth = data.carouselWidth
        tileWidth = data.tileWidth
        itemCount = data.itemCount

        var x = Carousel.getViewTranslation(data.x,
                                            data.tileWidth,
                                            gapToMiddlePhase,
                                            gapToEndPhase,
                                            data.translationXViewFactor)
        compare(x, data.result)
    }

    // test for the getItemScale() function
    function test_getItemScale_data() {
        return [ // tests for distance
                 {distance: 0, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 1},
                 {distance: 9, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.01},
                 {distance: 999, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.01},
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.98}, // = 1 - (1 / 50)
                 {distance: 3, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.688230855}, // = 1 - (3^2.5 / 50)
                 // tests for continuousIndex
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.98}, // = 1 - (1 / 50)
                 {distance: 1, continuousIndex: 97, numberOfItems: 100, scaleFactor: 1, result: 0.99}, // = 1 - (1 / 100) - distanceToBounds is used
                 // tests for numberOfItems
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.98}, // = 1 - (1 / 50)
                 {distance: 1, continuousIndex: 50, numberOfItems: 53, scaleFactor: 1, result: 0.99}, // = 1 - (1 / 100) - distanceToBounds is used
                 // tests for scaleFactor
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 1, result: 0.98}, // = 1 - (1 / 50)
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 2, result: 0.99}, // = 1 - (1 / 100)
                 {distance: 1, continuousIndex: 50, numberOfItems: 100, scaleFactor: 0.5, result: 0.96}, // = 1 - (1 / 25)
                 {distance: 1, continuousIndex: 50, numberOfItems: 53, scaleFactor: 1, result: 0.99}, // = 1 - (1 / 100) - distanceToBounds is used
                 {distance: 1, continuousIndex: 50, numberOfItems: 53, scaleFactor: 2, result: 0.996666666}, // = 1 - (1 / 300) - distanceToBounds is used
               ]
    }

    function test_getItemScale(data) {
        var scale = Carousel.getItemScale(data.distance,
                                          data.continuousIndex,
                                          data.numberOfItems,
                                          data.scaleFactor)
        compare(scale, data.result)
    }

    // test for the getItemTranslation() function
    function test_getItemTranslation_data() {
        return [ // tests if distance only affects the sign
                 {distance: 1, scale: 0, maxScale: 1, maxTranslation: 10, result: 10},
//                 {distance: 99, scale: 0, maxScale: 1, maxTranslation: 10, result: 10},
                 {distance: 0, scale: 0, maxScale: 1, maxTranslation: 10, result: -10},
                 {distance: -1, scale: 0, maxScale: 1, maxTranslation: 10, result: -10},
                 // tests for the scale
                 {distance: 1, scale: 1, maxScale: 1, maxTranslation: 10, result: 0},
                 {distance: 1, scale: 0, maxScale: 1, maxTranslation: 10, result: 10},
                 {distance: 1, scale: 0.5, maxScale: 1, maxTranslation: 10, result: 5},
                 // tests for maxScale
                 {distance: 1, scale: 1, maxScale: 1, maxTranslation: 10, result: 0},
                 {distance: 1, scale: 1, maxScale: 2, maxTranslation: 10, result: 10},
//                 {distance: 1, scale: 1, maxScale: 0, maxTranslation: 10, result: 0},
//                 {distance: 1, scale: 1, maxScale: 99, maxTranslation: 10, result: 10},
                 // test for maxTranslation
                 {distance: 1, scale: 1, maxScale: 1, maxTranslation: 1, result: 0},
                 {distance: 1, scale: 0, maxScale: 1, maxTranslation: 1, result: 1},
                 {distance: 1, scale: 0, maxScale: 1, maxTranslation: 10, result: 10},
                 {distance: 1, scale: 0, maxScale: 1, maxTranslation: 0, result: 0},
               ]
    }

    function test_getItemTranslation(data) {
        var scale = Carousel.getItemTranslation(data.distance,
                                                data.scale,
                                                data.maxScale,
                                                data.maxTranslation)
        compare(scale, data.result)
    }
}
