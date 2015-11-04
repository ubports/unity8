/*
 * Copyright 2014 Canonical Ltd.
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
import Unity.Application 0.1

SpreadDelegate {
    id: root

    // Set this to true when this tile is selected in the spread. The animation will change to bring the tile to front.
    property bool selected: false
    // Set this to true when another tile in the spread is selected. The animation will change to fade this tile out.
    property bool otherSelected: false
    // Set this to true when this tile a currently active on either the MS or the SS.
    property bool active: false

    property int zIndex
    property real progress: 0
    property real animatedProgress: 0

    property real startDistance: units.gu(5)
    property real endDistance: units.gu(.5)

    property real startScale: 1.1
    property real endScale: 0.7
    property real dragStartScale: startScale + .2

    property real startAngle: 15
    property real endAngle: 5

    property bool isInSideStage: false

    property int dragOffset: 0
    readonly property alias xTranslateAnimating: xTranslateAnimation.running

    dropShadow: spreadView.active ||
                (active
                 && (model.stage == ApplicationInfoInterface.MainStage || !priv.shellIsLandscape)
                 && priv.xTranslate != 0)

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
            if (spreadView.phase == 1) {
                var phase2Progress = spreadView.positionMarker4 - (root.zIndex * spreadView.tileDistance / spreadView.width);
                priv.phase2StartTranslate = priv.easingAnimation(0, 1, 0, -spreadView.width + (root.zIndex * root.endDistance), phase2Progress);
                priv.phase2StartScale = priv.easingAnimation(0, 1, root.startScale, root.endScale, phase2Progress);
                priv.phase2StartAngle = priv.easingAnimation(0, 1, root.startAngle, root.endAngle, phase2Progress);
                priv.phase2StartTopMarginProgress = priv.easingAnimation(0, 1, 0, 1, phase2Progress);
            }
        }
    }

    // Required to be an item because we're using states on it.
    Item {
        id: priv

        // true if this is the next tile on the stack that comes in when dragging from the right
        property bool nextInStack: spreadView.nextZInStack == zIndex
        // true if the next tile in the stack is the nextInStack one. This one will be moved a bit to the left
        property bool movedActive: spreadView.nextZInStack == zIndex + 1
        property real animatedEndDistance: linearAnimation(0, 2, root.endDistance, 0, root.progress)

        property real phase2StartTranslate
        property real phase2StartScale
        property real phase2StartAngle
        property real phase2StartTopMarginProgress

        property bool isSelected: false
        property bool otherSelected: false
        property real selectedProgress
        property real selectedXTranslate
        property real selectedAngle
        property real selectedScale
        property real selectedOpacity
        property real selectedTopMarginProgress

        function snapshot() {
            selectedProgress = root.progress;
            selectedXTranslate = xTranslate;
            selectedAngle = angle;
            selectedScale = priv.scale;
            selectedOpacity = priv.opacityTransform;
            selectedTopMarginProgress = topMarginProgress;
        }

        // This calculates how much negative progress there can be if unwinding the spread completely
        // the progress for each tile starts at 0 when it crosses the right edge, so the later a tile comes in,
        // the bigger its negativeProgress can be.
        property real negativeProgress: {
            if (nextInStack && spreadView.phase < 2) {
                return 0;
            }
            return -root.zIndex * spreadView.tileDistance / spreadView.width;
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

        Behavior on xTranslate {
            enabled: !spreadView.active &&
                     !snapAnimation.running &&
                     model.appId !== "unity8-dash" &&
                     !spreadView.sideStageDragging &&
                     spreadView.animateX &&
                     !spreadView.beingResized
            UbuntuNumberAnimation {
                id: xTranslateAnimation
                duration: UbuntuAnimation.FastDuration
            }
        }

        property real xTranslate: {
            var newTranslate = 0;

            if (otherSelected) {
                return priv.selectedXTranslate;
            }

            if (isSelected) {
                if (model.stage == ApplicationInfoInterface.MainStage) {
                    return linearAnimation(selectedProgress, negativeProgress, selectedXTranslate, -spreadView.width, root.progress);
                } else {
                    return linearAnimation(selectedProgress, negativeProgress, selectedXTranslate, -spreadView.sideStageWidth, root.progress);
                }
            }

            // The tile should move a bit to the left if a new one comes on top of it, but not for the Side Stage and not
            // when we're only dragging the side stage in on top of a main stage app
            var shouldMoveAway = spreadView.nextInStack >= 0 && priv.movedActive && model.stage === ApplicationInfoInterface.MainStage &&
                    ApplicationManager.get(spreadView.nextInStack).stage === ApplicationInfoInterface.MainStage;

            if (active) {
                newTranslate -= root.width
                // Only do the hide animation for active apps in the mainstage, and not if we only drag the ss in
                if (spreadView.phase == 0 && shouldMoveAway) {
                    newTranslate += linearAnimation(0, spreadView.positionMarker2, 0, -units.gu(4), root.animatedProgress);
                }
                newTranslate += root.dragOffset;
            }
            if (!spreadView.active && model.appId == "unity8-dash" && !root.active) {
                newTranslate -= root.width;
            }

            if (nextInStack && spreadView.phase == 0) {
                if (model.stage == ApplicationInfoInterface.MainStage) {
                    if (spreadView.sideStageVisible && root.progress > 0) {
                        // Move it so it appears from behind the side stage immediately
                        newTranslate += -spreadView.sideStageWidth;
                    }
                }

                if (model.stage == ApplicationInfoInterface.SideStage && !spreadView.sideStageVisible) {
                    // This is when we only drag the side stage in, without rotation or snapping
                    newTranslate = linearAnimation(0, spreadView.positionMarker2, 0, -spreadView.sideStageWidth, root.progress);
                } else {
                    newTranslate += linearAnimation(0, spreadView.positionMarker2, 0, -spreadView.sideStageWidth * spreadView.snapPosition, root.animatedProgress);
                }
            }

            if (spreadView.phase == 1) {
                if (nextInStack) {
                    if (model.stage == ApplicationInfoInterface.MainStage) {
                        var startValue = -spreadView.sideStageWidth * spreadView.snapPosition + (spreadView.sideStageVisible ? -spreadView.sideStageWidth : 0);
                        newTranslate += linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, startValue, priv.phase2StartTranslate, root.animatedProgress);
                    } else {
                        var endValue = -spreadView.width + spreadView.width * root.zIndex / 6;
                        if (!spreadView.sideStageVisible) {
                            newTranslate += linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, -spreadView.sideStageWidth, priv.phase2StartTranslate, root.progress);
                        } else {
                            newTranslate += linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, -spreadView.sideStageWidth * spreadView.snapPosition, priv.phase2StartTranslate, root.animatedProgress);
                        }
                    }
                } else if (root.active) {
                    var startProgress = spreadView.positionMarker2 - (zIndex * spreadView.positionMarker2 / 2);
                    var endProgress = spreadView.positionMarker4 - (zIndex * spreadView.tileDistance / spreadView.width);
                    var startTranslate = -root.width + (shouldMoveAway ? -units.gu(4) : 0);
                    newTranslate = linearAnimation(startProgress, endProgress, startTranslate, priv.phase2StartTranslate, root.progress);
                } else {
                    var startProgress = spreadView.positionMarker2 - (zIndex * spreadView.positionMarker2 / 2);
                    var endProgress = spreadView.positionMarker4 - (zIndex * spreadView.tileDistance / spreadView.width);
                    newTranslate = linearAnimation(startProgress, endProgress, 0, priv.phase2StartTranslate, root.progress);
                }
            }

            if (spreadView.phase == 2) {
                newTranslate = -easingCurve.value * (spreadView.width - root.zIndex * animatedEndDistance);
            }

            return newTranslate;
        }

        property real scale: {
            if (!spreadView.active) {
                return 1;
            }

            if (otherSelected) {
                return selectedScale;
            }

            if (isSelected) {
                return linearAnimation(selectedProgress, negativeProgress, selectedScale, 1, root.progress);
            }

            if (spreadView.phase == 0) {
                if (nextInStack) {
                    if (model.stage == ApplicationInfoInterface.SideStage && !spreadView.sideStageVisible) {
                        return 1;
                    } else {
                        var targetScale = root.dragStartScale - ((root.dragStartScale - 1) * spreadView.snapPosition);
                        return linearAnimation(0, spreadView.positionMarker2, root.dragStartScale, targetScale, root.animatedProgress);
                    }
                } else if (active) {
                    return 1;
                } else {
                    return linearAnimation(0, spreadView.positionMarker2, root.startScale, root.endScale, root.progress);
                }
            }

            if (spreadView.phase == 1) {
                if (nextInStack) {
                    var startScale = 1;
                    if (model.stage !== ApplicationInfoInterface.SideStage || spreadView.sideStageVisible) {
                        startScale = root.dragStartScale - ((root.dragStartScale - 1) * spreadView.snapPosition);
                    }
                    return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, startScale, priv.phase2StartScale, root.animatedProgress);
                }
                var startProgress = spreadView.positionMarker2 - (zIndex * spreadView.positionMarker2 / 2);
                var endProgress = spreadView.positionMarker4 - (zIndex * spreadView.tileDistance / spreadView.width);
                return linearAnimation(startProgress, endProgress, 1, priv.phase2StartScale, root.animatedProgress);
            }

            if (spreadView.phase == 2) {
                return root.startScale - easingCurve.value * (root.startScale - root.endScale);
            }

            return 1;
        }

        property real angle: {
            if (!spreadView.active) {
                return 0;
            }

            if (otherSelected) {
                return selectedAngle;
            }
            if (isSelected) {
                return linearAnimation(selectedProgress, negativeProgress, selectedAngle, 0, root.progress);
            }

            // The tile should rotate a bit when another one comes on top, but not when only dragging the side stage in
            var shouldMoveAway = spreadView.nextInStack >= 0 && movedActive &&
                    (ApplicationManager.get(spreadView.nextInStack).stage === ApplicationInfoInterface.MainStage ||
                     model.stage == ApplicationInfoInterface.SideStage);

            if (spreadView.phase == 0) {
                if (nextInStack) {
                    if (model.stage == ApplicationInfoInterface.SideStage && !spreadView.sideStageVisible) {
                        return 0;
                    } else {
                        return linearAnimation(0, spreadView.positionMarker2, root.startAngle, root.startAngle * (1-spreadView.snapPosition), root.animatedProgress);
                    }
                }
                if (shouldMoveAway) {
                    return linearAnimation(0, spreadView.positionMarker2, 0, root.startAngle * (1-spreadView.snapPosition), root.animatedProgress);
                }
            }
            if (spreadView.phase == 1) {
                if (nextInStack) {
                    if (model.stage == ApplicationInfoInterface.SideStage && !spreadView.sideStageVisible) {
                        return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, 0, priv.phase2StartAngle, root.animatedProgress);
                    } else {
                        return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, root.startAngle * (1-spreadView.snapPosition), priv.phase2StartAngle, root.animatedProgress);
                    }
                }
                var startProgress = spreadView.positionMarker2 - (zIndex * spreadView.positionMarker2 / 2);
                var endProgress = spreadView.positionMarker4 - (zIndex * spreadView.tileDistance / spreadView.width);
                var startAngle = shouldMoveAway ? root.startAngle * (1-spreadView.snapPosition) : 0;
                return linearAnimation(startProgress, endProgress, startAngle, priv.phase2StartAngle, root.progress);
            }
            if (spreadView.phase == 2) {
                return root.startAngle - easingCurve.value * (root.startAngle - root.endAngle);
            }

            return 0;
        }

        property real opacityTransform: {
            if (otherSelected && spreadView.phase == 2) {
                return linearAnimation(selectedProgress, negativeProgress, selectedOpacity, 0, root.progress);
            }

            return 1;
        }

        property real topMarginProgress: {
            if (priv.isSelected) {
                return linearAnimation(selectedProgress, negativeProgress, selectedTopMarginProgress, 0, root.progress);
            }
            switch (spreadView.phase) {
            case 0:
                return 0;
            case 1:
                return linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                       0, priv.phase2StartTopMarginProgress, root.progress);
            }
            return 1;
        }

        states: [
            State {
                name: "sideStageDragging"; when: spreadView.sideStageDragging && root.isInSideStage
                PropertyChanges { target: priv; xTranslate: -spreadView.sideStageWidth + spreadView.sideStageWidth * spreadView.sideStageDragProgress }
            }
        ]
    }

    transform: [
        Rotation {
            origin { x: 0; y: spreadView.height / 2 }
            axis { x: 0; y: 1; z: 0 }
            angle: priv.angle
        },
        Scale {
            origin { x: 0; y: spreadView.height / 2 }
            xScale: priv.scale
            yScale: xScale
        },
        Scale {
            origin { x: 0; y: (spreadView.height * priv.scale) + maximizedAppTopMargin * 3 }
            xScale: 1
            yScale: fullscreen ? 1 - priv.topMarginProgress * maximizedAppTopMargin / spreadView.height : 1
        },
        Translate {
            x: priv.xTranslate
        }
    ]
    opacity: priv.opacityTransform

    UbuntuNumberAnimation {
        id: fadeBackInAnimation
        target: root
        property: "opacity"
        duration: UbuntuAnimation.SlowDuration
        from: 0
        to: 1
    }

    EasingCurve {
        id: easingCurve
        type: EasingCurve.OutSine
        period: 1
        progress: root.progress
    }

    EasingCurve {
        id: helperEasingCurve
        type: easingCurve.type
        period: easingCurve.period
    }
}
