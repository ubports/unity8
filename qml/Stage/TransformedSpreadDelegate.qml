/*
 * Copyright 2014,2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

import QtQuick 2.4
import Utils 0.1
import Ubuntu.Components 1.3

SpreadDelegate {
    id: root

    // Set this to true when this tile is selected in the spread. The animation will change to bring the tile to front.
    property bool selected: false
    // Set this to true when another tile in the spread is selected. The animation will change to fade this tile out.
    property bool otherSelected: false

    // The progress animates the tiles. A value > 0 makes it appear from the right edge. At 1 it reaches the end position.
    property real progress: 0
    // This is required to snap tile 1 during phase 1 and 2.
    property real animatedProgress: 0

    property real startAngle: 0
    property real endAngle: 0

    property real startScale: 1
    property real endScale: 1

    // Specific to just one tile
    property real tile1StartScale: startScale + .4
    property real tile0SnapAngle: 10

    property real startDistance: units.gu(5)
    property real endDistance: units.gu(.5)

    // Whether first app is displayed entirely vs just on the spread edge
    property bool focusFirstApp: true

    // Whether this delegate is displayed to the user outside of the spread
    readonly property bool isFocused: focusFirstApp && index === 0

    // Adjusted index for any spread animation calculations
    readonly property int spreadIndex: index - (focusFirstApp ? 1 : 0)

    // How far left this delegate has been translated
    readonly property alias xTranslate: priv.xTranslate

    onSelectedChanged: {
        if (selected) {
            priv.snapshot();
        }
        priv.isSelected = selected;
    }

    onOtherSelectedChanged: {
        if (otherSelected) {
            priv.snapshot();
        }
        priv.otherSelected = otherSelected;
    }

    Connections {
        target: spreadView
        onPhaseChanged: {
            if (root.focusFirstApp && spreadView.phase == 1) {
                if (index === 0) {
                    priv.phase2startTranslate = priv.easingAnimation(0, spreadView.positionMarker4, 0, -spreadView.width, spreadView.positionMarker4) + spreadView.width;
                    priv.phase2startAngle = priv.easingAnimation(0, spreadView.positionMarker4, root.startAngle, root.endAngle, spreadView.positionMarker4);
                    priv.phase2startScale = priv.easingAnimation(0, spreadView.positionMarker4, root.startScale, root.endScale, spreadView.positionMarker4);
                    priv.phase2startTopMarginProgress = priv.easingAnimation(0, 1, 0, 1, spreadView.positionMarker4);
                } else if (index == 1) {
                    // find where the main easing for Tile 1 would be when reaching phase 2
                    var phase2Progress = spreadView.positionMarker4 - spreadView.tileDistance / spreadView.width;
                    priv.phase2startTranslate = priv.easingAnimation(0, phase2Progress, 0, -spreadView.width + root.endDistance, phase2Progress);
                    priv.phase2startAngle = priv.easingAnimation(0, phase2Progress, root.startAngle, root.endAngle, phase2Progress);
                    priv.phase2startScale = priv.easingAnimation(0, phase2Progress, root.startScale, root.endScale, phase2Progress);
                    priv.phase2startTopMarginProgress = priv.easingAnimation(0, 1, 0, spreadView.positionMarker4, phase2Progress);
                }
            }
        }
    }

    QtObject {
        id: priv
        property bool isSelected: false
        property bool otherSelected: false
        property real selectedProgress
        property real selectedXTranslate
        property real selectedAngle
        property real selectedScale
        property real selectedOpacity
        property real selectedTopMarginProgress

        // Those values are needed as target values for the end of phase 1.
        // As they are static values, lets calculate them once when entering phase 1 instead of calculating them in each animation pass.
        property real phase2startTranslate
        property real phase2startAngle
        property real phase2startScale
        property real phase2startTopMarginProgress

        function snapshot() {
            selectedProgress = root.progress;
            selectedXTranslate = xTranslate;
            selectedAngle = angle;
            selectedScale = scale;
            selectedOpacity = opacity;
            selectedTopMarginProgress = topMarginProgress;
        }

        function linearAnimation(startProgress, endProgress, startValue, endValue, progress) {
            // progress : progressDiff = value : valueDiff => value = progress * valueDiff / progressDiff
            return (progress - startProgress) * (endValue - startValue) / (endProgress - startProgress) + startValue;
        }

        function easingAnimation(startProgress, endProgress, startValue, endValue, progress) {
            helperEasingCurve.progress = progress - startProgress;
            helperEasingCurve.period = endProgress - startProgress;
            return helperEasingCurve.value * (endValue - startValue) + startValue;
        }

        // The following blocks handle the animation of the tile in the spread.
        // At the beginning, each tile is attached at the right edge, outside the screen.
        // The progress for each tile starts at 0 and it reaches its end position at a progress of 1.
        // The first phases are handled special for the first 2 tiles. as we do the alt-tab and snapping
        // in there. Once we reached phase 3, the animation is the same for all tiles.
        // When a tile is selected, the animation state is snapshotted, and the spreadView is unwound.
        // All tiles are kept in place and faded out to 0 opacity except
        // the selected tile, which is animated from the snapshotted position to be fullscreen.

        readonly property real xTranslate: {
            if (!spreadView.active) {
                return 0;
            }

            if (otherSelected) {
                if (spreadView.phase < 2 && root.isFocused) {
                    return linearAnimation(selectedProgress, 0, selectedXTranslate,
                                           selectedXTranslate - spreadView.tileDistance, root.progress);
                }

                return selectedXTranslate;
            }

            if (root.focusFirstApp && index === 0) {
                if (spreadView.phase == 0) {
                    return Math.min(0, linearAnimation(0, spreadView.positionMarker2,
                                                       0, -spreadView.width * .25, root.animatedProgress));
                } else if (spreadView.phase == 1){
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           -spreadView.width * .25, priv.phase2startTranslate, root.progress);
                } else if (!priv.isSelected){ // phase 2
                    // Apply the same animation as with the rest but add spreadView.width to align it with the others.
                    return -easingCurve.value * spreadView.width + spreadView.width;
                } else {
                    return linearAnimation(selectedProgress, 0, selectedXTranslate, 0, root.progress);
                }
            } else if (root.focusFirstApp && index === 1) {
                if (spreadView.phase == 0 && !priv.isSelected) {
                    return linearAnimation(0, spreadView.positionMarker2,
                                           0, -spreadView.width * spreadView.snapPosition, root.animatedProgress);
                } else if (spreadView.phase == 1 && !priv.isSelected) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           -spreadView.width * spreadView.snapPosition, priv.phase2startTranslate,
                                           root.progress);
                }
            }

            if (priv.isSelected) {
                // Distance to left edge
                var targetTranslate = -spreadView.width - (root.spreadIndex * root.startDistance);
                return linearAnimation(selectedProgress, 0,
                                       selectedXTranslate, targetTranslate, root.progress);
            }

            // Fix it at the right edge...
            var rightEdgeOffset =  -(root.spreadIndex * root.startDistance);
            // ...and use our easing to move them to the left. Stop a bit earlier for each tile
            var animatedEndDistance = linearAnimation(0, 2, root.endDistance, 0, root.progress);
            return -easingCurve.value * spreadView.width + (index * animatedEndDistance) + rightEdgeOffset;

        }

        readonly property real angle: {
            if (!spreadView.active) {
                return 0;
            }

            if (priv.otherSelected) {
                return priv.selectedAngle;
            }
            if (priv.isSelected) {
                return linearAnimation(selectedProgress, 0, selectedAngle, 0, root.progress);
            }
            if (root.focusFirstApp && index === 0) {
                if (spreadView.phase == 0) {
                    return Math.max(0, linearAnimation(0, spreadView.positionMarker2,
                                                       0, root.tile0SnapAngle, root.animatedProgress));
                } else if (spreadView.phase == 1) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           root.tile0SnapAngle, phase2startAngle, root.progress);
                }
            } else if (root.focusFirstApp && index === 1) {
                if (spreadView.phase == 0) {
                    return linearAnimation(0, spreadView.positionMarker2, root.startAngle,
                                           root.startAngle * (1-spreadView.snapPosition), root.animatedProgress);
                } else if (spreadView.phase == 1) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           root.startAngle * (1-spreadView.snapPosition), priv.phase2startAngle,
                                           root.progress);
                }
            }
            return root.startAngle - easingCurve.value * (root.startAngle - root.endAngle);
        }

        readonly property real scale: {
            if (!spreadView.active) {
                return 1;
            }
            if (priv.otherSelected) {
                return priv.selectedScale;
            }
            if (priv.isSelected) {
                return linearAnimation(selectedProgress, 0, selectedScale, 1, root.progress);
            }

            if (root.focusFirstApp && index === 0) {
                if (spreadView.phase == 0) {
                    return 1;
                } else if (spreadView.phase == 1) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           1, phase2startScale, root.progress);
                }
            } else if (root.focusFirstApp && index === 1) {
                if (spreadView.phase == 0) {
                    var targetScale = tile1StartScale - ((tile1StartScale - 1) * spreadView.snapPosition);
                    return linearAnimation(0, spreadView.positionMarker2,
                                           root.tile1StartScale, targetScale, root.animatedProgress);
                } else if (spreadView.phase == 1) {
                    var startScale = tile1StartScale - ((tile1StartScale - 1) * spreadView.snapPosition);
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           startScale, priv.phase2startScale, root.progress);
                }
            }
            return root.startScale - easingCurve.value * (root.startScale - root.endScale);
        }

        readonly property real opacity: {
            if (priv.otherSelected) {
                return linearAnimation (selectedProgress, Math.max(0, selectedProgress - .5),
                                        selectedOpacity, 0, root.progress);
            }
            if (root.isFocused) {
                switch (spreadView.phase) {
                case 0:
                    return linearAnimation(0, spreadView.positionMarker2, 1, .7, root.animatedProgress);
                case 1:
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           .7, 1, root.animatedProgress);
                }
            }

            return 1;
        }

        readonly property real topMarginProgress: {
            if (priv.isSelected) {
                return linearAnimation(selectedProgress, 0, selectedTopMarginProgress, 0, root.progress);
            }

            if (root.focusFirstApp && index === 0) {
                if (spreadView.phase == 0) {
                    return 0;
                } else if (spreadView.phase == 1) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           0, priv.phase2startTopMarginProgress, root.progress);
                }
            } else if (root.focusFirstApp && index === 1) {
                if (spreadView.phase == 0) {
                    return 0;
                } else if (spreadView.phase == 1) {
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                           0, priv.phase2startTopMarginProgress, root.progress);
                }
            }

            return easingCurve.value;
        }
    }

    transform: [
        Rotation {
            origin { x: 0; y: spreadView.height / 2 }
            axis { x: 0; y: 1; z: 0 }
            angle: priv.angle
        },

        // The next two transformations are to ensure that fullscreen and rotated
        // windows all have the same size and position as an unrotated (0 degrees)
        // non-fullscreen window when they're stacked on top of each other on the
        // far left of the spread.
        Translate {
            y: !root.fullscreen && appWindowRotation === 180
                   ? priv.topMarginProgress * maximizedAppTopMargin
                   : 0
        },
        Scale {
            origin {
                x: appWindowRotation === 270 ? spreadView.width : 0
                y: spreadView.height
            }

            xScale: {
                switch (appWindowRotation) {
                case 90:
                case 270:
                    if (root.fullscreen) {
                        return 1;
                    } else {
                        return 1 + priv.topMarginProgress * maximizedAppTopMargin / spreadView.width;
                    }
                break;
                default:
                    return 1;
                }
            }

            yScale: {
                switch (appWindowRotation) {
                case 0:
                    if (root.fullscreen) {
                        return 1 - priv.topMarginProgress * maximizedAppTopMargin / spreadView.height;
                    } else {
                        return 1;
                    }
                break;
                case 90:
                case 270:
                    return 1 - priv.topMarginProgress * maximizedAppTopMargin / spreadView.height;
                break;
                default:
                    return 1;
                }
            }
        },

        Scale {
            origin { x: 0; y: spreadView.height / 2 }
            xScale: priv.scale
            yScale: xScale
        },
        Translate {
            x: priv.xTranslate
        }
    ]

    opacity: spreadView.phase == 2 ? priv.opacity : 1

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: spreadView.phase < 2 ? 1 - priv.opacity : 0
    }

    EasingCurve {
        id: easingCurve
        type: EasingCurve.OutSine
        period: 1 - spreadView.positionMarker2
        progress: root.progress
    }

    // This is used as a calculation helper to figure values for progress other than the current one
    // Do not bind anything to this...
    EasingCurve {
        id: helperEasingCurve
        type: easingCurve.type
        period: easingCurve.period
    }
}
