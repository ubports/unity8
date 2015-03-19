import QtQuick 2.2
import Utils 0.1

QtObject {
    id: root

    function desktopX(index, totalWidth, flickableX) {
        var distance = totalWidth / 5;
        var startProgress = 0;
        var endProgress = 1;
        var startValue = index * distance;
        var endValue = 0;
        var progress = 1.0 * flickableX / startValue;
        print("progress for tile", index, ":", startProgress, endProgress, startValue, endValue, progress)
        var x = easingAnimation(startProgress, endProgress, startValue, endValue, progress);
        print("resulting x:", x)
        return x;
    }

    function desktopY(sceneHeight, itemHeight) {
        return sceneHeight - itemHeight - (sceneHeight * 0.1);
    }

    function desktopAngle(index, flickableX) {
        return 20;
    }

    function desktopScale(sceneHeight, itemHeight) {
        var maxHeight = sceneHeight * 0.35;
        if (itemHeight > maxHeight) {
            return maxHeight / itemHeight
        }
        return 1;
    }

    function easingAnimation(startProgress, endProgress, startValue, endValue, progress) {
        easingCurve.progress = progress - startProgress;
        easingCurve.period = endProgress - startProgress;
        return easingCurve.value * (endValue - startValue) + startValue;
    }

    property var easingCurve: EasingCurve {
        type: EasingCurve.OutSine
        period: 1
    }
}
