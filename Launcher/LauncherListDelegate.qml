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

LauncherDelegate {
    id: root

    // The angle used for rotating
    angle: {
        if (index == 1 || index == priv.listView.count - 2) {
            print("index", index, iconName, "overlaps with folding area", priv.overlapWithFoldingArea, priv.distanceFromEdge, priv.bottomDraggingDistanceOffset)
        }

        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            if (priv.distanceFromEdge < 0) {
                // proportion equation: distanceFromTopEdge : angle = totalUnfoldedHeight/2 : maxAngle
                return Math.max(-maxAngle, priv.distanceFromEdge * maxAngle / (priv.listView.foldingAreaHeight)) * priv.orientationFlag
            }
            return 0; // Don't fold first/last item as long as inside the view
        }

        // Are we in the already completely outside the flickable? Fold for the last 5 degrees
        if (priv.distanceFromEdge < 0) {
            // proportion equation: -distanceFromTopEdge : angle = totalUnfoldedHeight : 5
            return Math.max(-maxAngle, (priv.distanceFromEdge * 5 / priv.listView.foldingAreaHeight) - (maxAngle-5)) * priv.orientationFlag
        }

        // We are overlapping with the folding area, fold the icon to maxAngle - 5 degrees
        if (priv.overlapWithFoldingArea > 0) {
            // proportion equation: overlap: totalHeight = angle : (maxAngle - 5)
            return -priv.overlapWithFoldingArea * (maxAngle -5) / priv.listView.foldingAreaHeight * priv.orientationFlag;
        }
        return 0;
    }

    // This is the offset that keeps the items inside the panel
    offset: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            // Just keep them bound to the edges in case they're outside of the visible area
            if (priv.distanceFromEdge < 0) {
                return (-priv.distanceFromEdge - (height - effectiveHeight)) * priv.orientationFlag;
            }
            return 0;
        }

        // Are we already completely outside the flickable? Stop the icon here.
        if (priv.distanceFromEdge < -priv.totalUnfoldedHeight) {
            return (-priv.distanceFromEdge - (root.height - effectiveHeight)) * priv.orientationFlag;
        }

        // We're touching the edge, move slower than the actual flicking speed.
        if (priv.distanceFromEdge < 0) {
            return (Math.abs(priv.distanceFromEdge) * priv.totalEffectiveHeight / priv.totalUnfoldedHeight) * priv.orientationFlag
        }
        return 0;
    }

    itemOpacity: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            if (priv.distanceFromEdge < 0) {
                // Fade from 1 to 0 in the distance of 3 * foldingAreaHeight (which is when the next item reaches the edge)
                return 1.0 - (-priv.distanceFromEdge / (priv.listView.foldingAreaHeight * 3))
            }
            return 1; // Don't make first/last item transparent as long as inside the view
        }

        // Are we already completely outside the flickable? Fade from 0.75 to 0 in 2 items height
        if (priv.distanceFromEdge < 0) {
            // proportion equation: -distanceFromEdge : 1-opacity = totalUnfoldedHeight : 0.75
            return 0.75 - (-priv.distanceFromEdge * 0.75 / (priv.totalUnfoldedHeight*2))
        }

        // We are overlapping with the folding area, fade out to 0.75
        if (priv.overlapWithFoldingArea > 0) {
            // proportion equation: overlap : totalHeight = 1-opacity : 0.25
            return 1 - (priv.overlapWithFoldingArea * 0.25 / priv.listView.foldingAreaHeight)
        }
        return 1;
    }

    brightness: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            if (priv.distanceFromEdge < 0) {
                return -(-priv.distanceFromEdge / (priv.listView.foldingAreaHeight * 3))
            }
            return 0;
        }
        // Are we already completely outside the flickable? Fade from 0.7 to 0 in 2 items height
        if (priv.distanceFromEdge < 0) {
            return -0.3 - (-priv.distanceFromEdge * 0.1 / (priv.totalUnfoldedHeight*2))
        }

        // We are overlapping with the folding area, fade out to 0.7
        if (priv.overlapWithFoldingArea > 0) {
            return - (priv.overlapWithFoldingArea * 0.3 / priv.listView.foldingAreaHeight)
        }
        return 0;
    }

    QtObject {
        id: priv

        property ListView listView: root.ListView.view
        property real totalUnfoldedHeight: listView.itemHeight + listView.spacing
        property real totalEffectiveHeight: effectiveHeight + listView.spacing
        property real effectiveContentY: listView.contentY - listView.originY
        property real effectiveY: y - listView.originY
        property real bottomDraggingDistanceOffset: listView.draggedIndex > index ? totalUnfoldedHeight : 0
        property real distanceFromTopEdge: -(effectiveContentY + listView.topMargin - index*totalUnfoldedHeight)
        property real distanceFromBottomEdge: listView.height - listView.bottomMargin - (effectiveY+height) + effectiveContentY + bottomDraggingDistanceOffset

        property real distanceFromEdge: Math.abs(distanceFromBottomEdge) < Math.abs(distanceFromTopEdge) ? distanceFromBottomEdge : distanceFromTopEdge
        property real orientationFlag: Math.abs(distanceFromBottomEdge) < Math.abs(distanceFromTopEdge) ? -1 : 1

        property real overlapWithFoldingArea: listView.foldingAreaHeight - distanceFromEdge
    }

}
