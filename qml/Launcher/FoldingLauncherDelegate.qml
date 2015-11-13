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

import QtQuick 2.4
import Ubuntu.Components 1.3

LauncherDelegate {
    id: root

    // The angle used for rotating
    angle: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            if (priv.distanceFromEdge < 0) {
                // proportion equation: distanceFromTopEdge : angle = totalUnfoldedHeight/2 : maxAngle
                return Math.max(-maxAngle, priv.distanceFromEdge * maxAngle / (priv.foldingAreaHeight)) * priv.orientationFlag
            }
            return 0; // Don't fold first/last item as long as inside the view
        }

        // We reached the folded area... fold the last 5 degrees
        if (priv.overlapWithFoldedArea > 0) {
            // proportion equation: overlap : x = height : 5
            return ((maxAngle - 5) + (priv.overlapWithFoldedArea * 5 / priv.foldingAreaHeight)) * -priv.orientationFlag
        }

        // We are overlapping with the folding area, fold the icon to maxAngle - 5 degrees
        if (priv.overlapWithFoldingArea > 0) {
            // proportion equation: overlap: totalHeight = angle : (maxAngle - 5)
            return -priv.overlapWithFoldingArea * (maxAngle -5) / priv.foldingAreaHeight * priv.orientationFlag;
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

        // We stopped folding, move slower than the actual flicking speed.
        if (priv.overlapWithFoldedArea > 0) {
            return (priv.overlapWithFoldedArea * priv.totalEffectiveHeight / (priv.totalUnfoldedHeight + priv.listView.foldingStopHeight)) * priv.orientationFlag;
        }
        return 0;
    }

    itemOpacity: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {
            if (priv.distanceFromEdge < 0) {
                // Fade from 1 to 0 while traversing a distance of 2*foldingAreaHeight
                // proportion equation: 0.5 : x = -2*foldingAreaHeight : distance
                return 1 + (priv.distanceFromEdge / (priv.foldingAreaHeight * 2))
            }
            return 1; // Don't make first/last item transparent as long as inside the view
        }

        // Did we stop folding? Fade out to 0 in 2*foldingAreaHeight
        if (priv.overlapWithFoldedArea > 0) {
            // overlap : foldingAreaHeight = opacity : 0.75
            return 0.75 - (priv.overlapWithFoldedArea * 0.75 / (priv.foldingAreaHeight * 2));
        }

        // We are overlapping with the folding area, fade out to 0.75 transparency
        if (priv.overlapWithFoldingArea > 0) {
            // proportion equation: overlap : totalHeight = 1-opacity : 0.25
            return 1 - (priv.overlapWithFoldingArea * 0.25 / priv.foldingAreaHeight)
        }
        return 1;
    }

    brightness: {
        // First/last items are special
        if (index == 0 || index == priv.listView.count-1) {

            // Traversed one foldingAreaHeight. Stop at 0.3
            if (priv.distanceFromEdge < -priv.foldingAreaHeight) {
                return -0.3
            }

            // We started moving, fade to 0.3
            if (priv.distanceFromEdge < 0) {
                return -0.3 * (-priv.distanceFromEdge / (priv.foldingAreaHeight))
            }
            return 0;
        }

        // We stopped folding? Stop brightness change at 0.3
        if (priv.overlapWithFoldedArea > 0) {
            return -0.3;
        }

        // We are overlapping with the folding area, fade out to 0.3
        if (priv.overlapWithFoldingArea > 0) {
            return - (priv.overlapWithFoldingArea * 0.3 / priv.listView.foldingStartHeight);
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

        property real overlapWithFoldingArea: listView.foldingStartHeight - distanceFromEdge
        property real overlapWithFoldedArea: listView.foldingStopHeight - distanceFromEdge
        property real foldingAreaHeight: listView.foldingStartHeight - listView.foldingStopHeight
    }

}
