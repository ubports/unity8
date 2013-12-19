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

/*! get the element which is selected accordingly to x, the hero of the view
  @param x contentX of the ListView
  @param tileWidth width of a single tile
  @param gapToMiddlePhase gap in pixels between beginning and middle phase
  @param gapToEndPhase gap in pixels between middle and end phase
  @param kGapEnd
  @param kMiddleIndex
  @param kXBeginningEnd
*/
function getContinuousIndex(x, tileWidth, gapToMiddlePhase, gapToEndPhase, kGapEnd, kMiddleIndex, kXBeginningEnd) {
    if (x < gapToMiddlePhase) {
        // beginning
        return x * kXBeginningEnd
    } else if (x > gapToEndPhase) {
        // end
        return x * kXBeginningEnd + kGapEnd
    }

    // middle
    return x / tileWidth + kMiddleIndex
}

/*! obtain x position relative to an index, essentially an inverse of getContinuousIndex()
  @param index index of the item to calcualte the proper X value for
  @param viewWidth visible width of the view
  @param contentWidth width off all items in the view
  @param tileWidth width of one item
  @param gapToMiddlePhase
  @param gapToEndPhase
  @param drawBuffer width of the drawBuffer
*/
function getXFromContinuousIndex(index, viewWidth, contentWidth, tileWidth, gapToMiddlePhase, gapToEndPhase, drawBuffer) {
    var middleX = (index + 0.5) * tileWidth - viewWidth / 2

    if (middleX < gapToMiddlePhase) {
        // inverse of 'middleIndex - kGap' of getContinuousIndex()
        return index /
               ((1 / tileWidth) +
                (viewWidth / (2 * tileWidth * gapToMiddlePhase)) -
                1 / (2 * gapToMiddlePhase))
               - drawBuffer
    } else if (middleX > gapToEndPhase) {
        // inverse of 'middleIndex + kGap' of getContinuousIndex()
        return (index +
                1 -
                viewWidth / tileWidth +
                (contentWidth * viewWidth - viewWidth * viewWidth) / (2 * tileWidth * gapToMiddlePhase) +
                (viewWidth - contentWidth) / (2 * gapToMiddlePhase)) /
               (1 / tileWidth +
                viewWidth / (2 * tileWidth * gapToMiddlePhase) -
                1 / (2 * gapToMiddlePhase))
               - drawBuffer
    }

    // inverse of 'middleIndex' of getContinuousIndex()
    return middleX - drawBuffer
}

/*! get translation of the whole view, adds gaps on sides
  @param x contentX of the ListView
  @param gapToMiddlePhase
  @param gapToEndPhase
  @param translationXViewFactor
*/
function getViewTranslation(x, tileWidth, gapToMiddlePhase, gapToEndPhase, translationXViewFactor) {
    if (x < gapToMiddlePhase) {
        // beginning
        return (gapToMiddlePhase - x) * translationXViewFactor
    } else if (x > gapToEndPhase) {
        // end
        return (gapToEndPhase - x) * translationXViewFactor
    }

    // middle
    return 0
}

/*! item scale
  @param distance is the difference of the item's index to the continuousIndex
  @param continuousIndex the current index in real number
  @param numberOfItems the total number of items in the model
  @param scaleFactor if bigger than 1, the scaling is done slower (more distance needed)
*/
function getItemScale(distance, continuousIndex, numberOfItems, scaleFactor) {
    var distanceAbs = Math.abs(distance)
    var distanceToBounds = Math.min(continuousIndex, numberOfItems - continuousIndex)
    var k = Math.max(200 + 100 * (-distanceToBounds / (3 * scaleFactor)), 50)
    return Math.max(0.01, 1 - Math.pow(distanceAbs, 2.5) / (k * scaleFactor))
}

/*! item translation
 @param index index of the current item
 @param selectedIndex index of the selected item
 @param distance controls the direction wich is left/negative and right/positive
 @param scale is the current scale factor of the item
 @param maxScale the maximum scale factor (the one used when the index is on that item
 @param maxTranslation the maximum translation length in pixel
*/
function getItemTranslation(index, selectedIndex, distance, scale, maxScale, maxTranslation) {
    if (index === selectedIndex) return 0
    var sign = distance > 0 ? 1 : -1
    return sign * (maxScale - scale) * maxTranslation
}
