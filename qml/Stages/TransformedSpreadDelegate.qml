import QtQuick 2.0
import Utils 0.1
import Ubuntu.Components 0.1

SpreadDelegate {
    id: root

    property real progress: 0
//    onProgressChanged: if (index == 0) print("tile", index, "progress changed:", progress)
    property real animatedProgress: 0

    property real startAngle: 0
    property real endAngle: 0

    property real startScale: 1
    property real endScale: 1

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

        property real negativeProgress: (index - 1) * spreadView.positionMarker1


        property real xTranslate: {
            var translation = 0;
            switch (index) {
            case 0:
                if (spreadView.stage == 0) {
                    // Need to compensate the flickable movement (fixing first tile at the left edge)
                    var compensation = root.progress * spreadView.width

                    // Calculating the small movement of the first tile
                    var progress = root.animatedProgress
                    var progressDiff = spreadView.positionMarker2
                    var translateDiff = -spreadView.width * 0.25
                    // progress : progressDiff = translate : translateDiff
                    var movement = progress * translateDiff / progressDiff

                    translation = compensation + movement;
                } else if (spreadView.stage == 1){
                    // Need to compensate the flickable movement (fixing first tile at the left edge)
                    var compensation = spreadView.contentX - spreadRow.x

                    // When we start, we need to continue from where state 0 left
                    var stage0Movement = -spreadView.width * 0.25

                    var progress = root.progress - spreadView.positionMarker2
                    var progressDiff = spreadView.positionMarker4 - spreadView.positionMarker2
                    var translateDiff = -stage0Movement;

                    var movement = progress * translateDiff / progressDiff

                    translation = compensation + stage0Movement + movement;
                } else { // Stage 2
                    // Move the first tile a bit to the left to be aligned with the others
                    translation += spreadView.contentX - spreadRow.x + spreadView.width
                    // apply the same animation as with the rest
                    translation += -easingCurve.value * spreadView.width
                }
                break;
            case 1:
                if (spreadView.stage == 0) {
                    // Need to compensate the flickable movement (fix it to the right edge)
                    var compensation = root.progress * spreadView.width

                    // Calculate movemoent for the first app coming from the right
                    var progress = root.animatedProgress
                    var progressDiff = spreadView.positionMarker2
                    var translateDiff = -spreadView.width * spreadView.snapPosition
                    // progress : progressDiff = translate : translateDiff
                    var movement = progress * translateDiff / progressDiff

                    translation = compensation + movement;
                    break;
                } else if (spreadView.stage == 1) {
                    // Need to compensate the flickable movement (fix it to the right edge)
                    var compensation = root.progress * spreadView.width + spreadView.width/2

                    // Add where stage 0 has moved it to
                    var stage0Movement = -spreadView.width * spreadView.snapPosition;

                    // Calclulate animation between stage0Movement and targetTranslate
                    var progress = root.progress
                    var progressDiff = spreadView.positionMarker4 - spreadView.positionMarker2

                    // find where the main easing would be when reaching positionMarker4
                    helperEasingCurve.progress = progressDiff;
                    var targetTranslate = -helperEasingCurve.value * spreadView.width + root.endDistance

                    var translateDiff = targetTranslate - stage0Movement;
                    var movement = progress * translateDiff / progressDiff

                    translation = compensation + stage0Movement + movement;
                    break;
                }

            default:
                // Fix it at the right edge...
                translation += spreadView.contentX - spreadRow.x - ((index - 1) * root.startDistance)
                // ...and use our easing to move them to the left. Stop a bit earlier for each tile
                translation += -easingCurve.value * spreadView.width + (index * root.endDistance)
                if (isSelected) {
                    var progressDiff = negativeProgress + selectedProgress
                    var progress = progressDiff - (root.progress + negativeProgress);
                    var translateDiff = spreadView.width - (selectedXTranslate - translation)

                    // Fix it where it was when selected
                    translation = selectedXTranslate - progress * spreadView.width

                    // Distance to left edge
                    var targetTranslate = spreadView.contentX - spreadView.width - spreadRow.x - ((index - 1) * root.startDistance)

                    // The distance to animate is from the selection position to the left edge
                    var translateDiff = targetTranslate - translation

                    translation += progress * translateDiff / progressDiff;
                }
            }
            return translation;
        }
        property real angle: {
            var newAngle = 0;
            switch (index) {
            case 0:
                if (spreadView.stage == 0) {
                    var progress = root.animatedProgress;
                    var progressDiff = spreadView.positionMarker2;
                    var angleDiff = root.endAngle * spreadView.snapPosition;
                    // progress : progressDiff = angle : angleDiff
                    newAngle = progress * angleDiff / progressDiff;
                    break;
                } else if (spreadView.stage == 1) {
                    var stage0Angle = root.endAngle * spreadView.snapPosition;

                    var progress = root.progress - spreadView.positionMarker2;
                    var angleDiff = root.endAngle;
                    var progressDiff = 1 - spreadView.positionMarker2;
                    var angleTransform = progress * angleDiff / progressDiff;
                    newAngle = stage0Angle + angleTransform;
                    newAngle = Math.min(root.endAngle, newAngle);
                    break;
                }
            case 1:
                if (spreadView.stage == 0) {
                    var progress = root.animatedProgress;
                    var progressDiff = spreadView.positionMarker2;
                    var angleDiff = root.startAngle * spreadView.snapPosition

                    // progress : progressDiff = angle : angleDiff
                    var angleTranslate = progress * angleDiff / progressDiff;

                    newAngle = root.startAngle - angleTranslate;
                    break;
                } else if (spreadView.stage == 1) {
                    var stage0Angle = root.startAngle - (root.startAngle * spreadView.snapPosition)

                    var progress = root.progress
                    var progressDiff = spreadView.positionMarker4 - spreadView.positionMarker2
                    var angleDiff = root.endAngle - stage0Angle;

                    // progress : progressDiff = angle : angleDiff
                    var angleTranslate = progress * angleDiff / progressDiff;
                    newAngle = stage0Angle + angleTranslate;
                    break;
                }

            default:
                newAngle = root.startAngle - easingCurve.value * (root.startAngle - root.endAngle)
                if (isSelected) {
                    var progressDiff = negativeProgress + selectedProgress
                    var progress = progressDiff - (root.progress + negativeProgress);
                    var angleDiff = -selectedAngle;
                    var angleTranslate = progress * angleDiff / progressDiff;

                    newAngle = selectedAngle + angleTranslate;

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
                } else if(spreadView.stage == 1) {
                    var progress = root.progress - spreadView.positionMarker2
                    var progressDiff = spreadView.positionMarker4 - spreadView.positionMarker2
                    var scaleDiff = 1 - root.endScale;
                    // progress : progressDiff = angle : angleDiff
                    newScale = 1 - (progress * scaleDiff / progressDiff);

                } else {
                    var progress = root.progress - spreadView.positionMarker2;
                    var scaleDiff = 1 - root.endScale;
                    var progressDiff = 1 - spreadView.positionMarker2;
                    // progress : progressDiff = angle : angleDiff
                    newScale = 1 - (progress * scaleDiff / progressDiff);
                    newScale = Math.max(root.endScale, newScale);
                }

                break;
            case 1:
                if (spreadView.stage == 0) {
                    var progress = root.animatedProgress;
                    var progressDiff = spreadView.positionMarker2;
                    var scaleDiff = (root.startScale - 1) * spreadView.snapPosition

                    // progress : progressDiff = angle : angleDiff
                    var scaleTranslate = progress * scaleDiff / progressDiff;

                    newScale = root.startScale - scaleTranslate;
                    break;
                } else if (spreadView.stage == 1) {
                    var stage0Scale = root.startScale - (root.startScale - 1) * spreadView.snapPosition

                    var progress = root.progress
                    var progressDiff = spreadView.positionMarker4 - spreadView.positionMarker2

                    // find where the main easing would be when reaching positionMarker4
                    helperEasingCurve.progress = progressDiff;
                    var targetScale = root.startScale - helperEasingCurve.value * (root.startScale - root.endScale)

                    var scaleDiff = stage0Scale - targetScale;

                    // progress : progressDiff = angle : angleDiff
                    var scaleTranslate = progress * scaleDiff / progressDiff;

                    return stage0Scale - scaleTranslate;
                }

            default:
                newScale = root.startScale - easingCurve.value * (root.startScale - root.endScale)
                if (isSelected) {
                    var progressDiff = negativeProgress + selectedProgress
                    var progress = progressDiff - (root.progress + negativeProgress);
                    var scaleDiff = 1 - selectedScale

                    // progress : progressDiff = angle : angleDiff
                    var scaleTranslate = progress * scaleDiff / progressDiff;

                    newScale = selectedScale + scaleTranslate;
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
