import QtQuick 2.0
import Utils 0.1
import Ubuntu.Components 0.1

SpreadDelegate {
    id: root

    property real progress: 0
    property real animatedProgress: 0

    property real startAngle: 0
    property real endAngle: 0

    property real startScale: 1
    property real endScale: 1
    property real tile1StartScale: startScale + .4

    property real startDistance: units.gu(5)
    property real endDistance: units.gu(.5)

    onClicked: {
        priv.selectedProgress = root.progress
        priv.selectedXTranslate = priv.xTranslate;
        priv.selectedAngle = priv.angle;
        priv.selectedScale = priv.scale;
        priv.isSelected = true;
    }

    Connections {
        target: spreadView
        onStageChanged: {
            if (stage == 0) {
                priv.isSelected = false;
            }
        }
    }

    QtObject {
        id: priv
        property bool isSelected: false
        property real selectedProgress
        property real selectedXTranslate
        property real selectedAngle
        property real selectedScale

        property real negativeProgress: {
            if (index == 0) {
                return spreadView.positionMarker2;
            } else if (index == 1) {
                return spreadView.positionMarker2 - (spreadView.tileDistance / spreadView.width);
            }
            return -(index - 2) * (spreadView.tileDistance / spreadView.width);
        }

        function linearAnimation(startProgress, endProgress, startValue, endValue, progress) {
            // progress : progressDiff = value : valueDiff
            return (progress - startProgress) * (endValue - startValue) / (endProgress - startProgress) + startValue;
        }

        function easingAnimation(startProgress, endProgress, startValue, endValue, progress) {
            helperEasingCurve.progress = progress - startProgress;
            helperEasingCurve.period = endProgress - startProgress;
            return helperEasingCurve.value * (endValue - startValue) + startValue;
        }

        property real xTranslate: {
            var translation = 0;
            switch (index) {
            case 0:
                if (spreadView.stage == 0) {
                    translation = linearAnimation(0, spreadView.positionMarker2, 0, -spreadView.width * .25, root.animatedProgress)
                    break;
                } else if (spreadView.stage == 1){
                    // find where the main easing would be when reaching stage 2
                    var targetTranslate = easingAnimation(0, spreadView.positionMarker4, 0, -spreadView.width, spreadView.positionMarker4) + spreadView.width
                    translation = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, -spreadView.width * .25, targetTranslate, root.progress)
                    break;
                } else if (!isSelected){ // Stage 2
                    // Move the first tile a bit to the right to be aligned with the others
                    translation += spreadView.width
                    // apply the same animation as with the rest
                    translation += -easingCurve.value * spreadView.width
                    break;
                } else if (isSelected) {
                    translation = linearAnimation(selectedProgress, negativeProgress, selectedXTranslate, 0, root.progress)
                    break;
                }

            case 1:
                if (spreadView.stage == 0) {
                    translation = linearAnimation(0, spreadView.positionMarker2, 0, -spreadView.width * spreadView.snapPosition, root.animatedProgress)
                    break;
                } else if (spreadView.stage == 1) {
                    // find where the main easing would be when reaching stage 2
                    var stage2Progress = spreadView.positionMarker4 - spreadView.tileDistance / spreadView.width;
                    targetTranslate = easingAnimation(0, stage2Progress, 0, -spreadView.width + root.endDistance, stage2Progress);

                    translation = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4,
                                                   -spreadView.width * spreadView.snapPosition, targetTranslate, root.progress);

                    break;
                }

            default:
                // Fix it at the right edge...
                translation +=  -((index - 1) * root.startDistance)
                // ...and use our easing to move them to the left. Stop a bit earlier for each tile
                translation += -easingCurve.value * spreadView.width + (index * root.endDistance)
                if (isSelected) {
                    // Distance to left edge
                    var targetTranslate = -spreadView.width - ((index - 1) * root.startDistance)
                    translation = linearAnimation(selectedProgress, negativeProgress, selectedXTranslate, targetTranslate, root.progress)
                }
            }
            return translation;
        }
        property real angle: {
            var newAngle = 0;
            switch (index) {
            case 0:
                if (spreadView.stage == 0) {
                    newAngle = linearAnimation(0, spreadView.positionMarker2, 0, root.endAngle * spreadView.snapPosition, root.animatedProgress)
                    break;
                } else if (spreadView.stage == 1) {
                    newAngle = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, root.endAngle * spreadView.snapPosition, root.endAngle, root.progress)
                    break;
                }
            case 1:
                if (spreadView.stage == 0) {
                    newAngle = linearAnimation(0, spreadView.positionMarker2, root.startAngle, root.startAngle * (1-spreadView.snapPosition), root.animatedProgress)
                    break;
                } else if (spreadView.stage == 1) {
                    // find where the main easing would be when reaching stage 2
                    var stage2Progress = spreadView.positionMarker4 - spreadView.tileDistance / spreadView.width;
                    var targetAngle = easingAnimation(0, stage2Progress, root.startAngle, root.endAngle, stage2Progress)
                    newAngle = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, root.startAngle * (1-spreadView.snapPosition), targetAngle, root.progress)
                    break;
                }

            default:
                newAngle = root.startAngle - easingCurve.value * (root.startAngle - root.endAngle)
                if (isSelected) {
                    newAngle = linearAnimation(selectedProgress, negativeProgress, selectedAngle, 0, root.progress)
                }
            }

            return newAngle;
        }
        property real scale: {
            var newScale = 1;
            switch (index) {
            case 0:
                if (spreadView.stage == 0) {
                    newScale = 1;
                    break
                } else if(spreadView.stage == 1) {
                    newScale = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, 1, root.endScale, root.progress)
                    break;
                }
            case 1:
                if (spreadView.stage == 0) {
                    newScale = linearAnimation(0, spreadView.positionMarker2, root.tile1StartScale, 1, root.animatedProgress)
                    break;
                } else if (spreadView.stage == 1) {
                    // find where the main easing would be when reaching positionMarker4
                    var targetScale = easingAnimation(0, spreadView.positionMarker4, root.startScale, root.endScale, spreadView.positionMarker4);
                    newScale = linearAnimation(spreadView.positionMarker2, spreadView.positionMarker4, 1, targetScale, root.progress)
                    break;
                }

            default:
                newScale = root.startScale - easingCurve.value * (root.startScale - root.endScale)
                if (isSelected) {
                    newScale = linearAnimation(selectedProgress, negativeProgress, selectedScale, 1, root.progress)
                }
            }
            return newScale;
        }
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
        Translate {
            x: priv.xTranslate
        }
    ]

    EasingCurve {
        id: easingCurve
        type: EasingCurve.OutQuad
        period: 1 - spreadView.positionMarker2
        progress: root.animatedProgress
    }

    // This is used as a calculation helper to figure values for progress other than the current one
    // Do not bind anything to this...
    EasingCurve {
        id: helperEasingCurve
        type: easingCurve.type
        period: easingCurve.period
    }
}
