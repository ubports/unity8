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

// get the element which is selected accordingly to x, the hero of the view
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

// obtain x position relative to an index, essentially an inverse of getContinuousIndex()
function getXFromContinuousIndex(index, viewWidth, contentWidth, tileWidth, gapToMiddlePhase, gapToEndPhase) {
    var middleX = (index + 0.5) * tileWidth - viewWidth / 2

    if (middleX < gapToMiddlePhase) {
        // inverse of 'middleIndex - kGap' of getContinuousIndex()
        return index /
               ((1 / tileWidth) +
                (viewWidth / (2 * tileWidth * gapToMiddlePhase)) -
                1 / (2 * gapToMiddlePhase))
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
    }

    // inverse of 'middleIndex' of getContinuousIndex()
    return middleX
}

// get translation of the whole view, adds gaps on sides
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

// item scale
function getItemScale(distance, continuousIndex, end, scaleFactor) {
    var distanceAbs = Math.abs(distance)
    var distanceToBounds = Math.min(continuousIndex, end - continuousIndex)
    var k = Math.max(200 + 100 * (-distanceToBounds / (3 * scaleFactor)), 50)
    return Math.max(0.01, 1 - Math.pow(distanceAbs, 2.5) / (k * scaleFactor))
}

// item translation
function getItemTranslation(distance, scale, maxScale, translationFactor) {
    var sign = distance > 0 ? 1 : -1
    return sign * (maxScale - scale) * translationFactor
}
