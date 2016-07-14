import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import 'cubic-bezier.js' as Bezier
import 'KeySpline.js' as KeySpline

Item {
    id: root

    property var controlPoint1: {'x':0, 'y':0}
    property var controlPoint2: {'x':0, 'y':0}
    property var controlPoint3: {'x':0.58, 'y':1}
    property var controlPoint4: {'x':1, 'y':1}

    function getValues(t) {
        if (t<0) t=0
        else if (t>1)t=1

        return Bezier.getBezier(t, controlPoint1, controlPoint2, controlPoint3, controlPoint4)
    }

    function getYFromX(x) {
        var spline = new KeySpline.keySpline(controlPoint2.x, controlPoint2.y, controlPoint3.x, controlPoint3.y)
        if (x<0) x=0
        else if (x>1)x=1

        return spline.get(x)
    }
}
