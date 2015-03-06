/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    id: swipeToAct

    width: parent.width
    height: childrenRect.height

    signal leftTriggered()
    signal rightTriggered()

    property string leftIconName
    property string rightIconName
    readonly property double sliderHeight: units.gu(8)
    readonly property double gap: units.gu(1)
    readonly property color sliderDefault: "#b2b2b2"
    readonly property double halfWay: mouseArea.drag.maximumX / 2

    // linearly interpolate between start- and end-color
    // with a normalized weight-factor
    // 0.0 meaning just the start-color being taken into
    // account and 1.0 only taking the end-color into
    // account
    function interpolate(start, end, factor) {
        var rdiff = start.r > end.r ? end.r - start.r : end.r - start.r
        var gdiff = start.g > end.g ? end.g - start.g : end.g - start.g
        var bdiff = start.b > end.b ? end.b - start.b : end.b - start.b
        var adiff = start.a > end.a ? end.a - start.a : end.a - start.a
        var r = start.r + factor * rdiff
        var g = start.g + factor * gdiff
        var b = start.b + factor * bdiff
        var a = start.a + factor * adiff
        return Qt.rgba(r,g,b,a)
    }

    UbuntuShape {
        id: row
        width: parent.width
        height: sliderHeight
        color: "#f4f4f4"

            UbuntuShape {
                id: leftShape
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: gap
                color: "#df382c" //UbuntuColors.red

                state: "normal"
                height: units.gu(6)
                width: units.gu(6)
                radius: "medium"
                opacity: slider.x <= halfWay ? 1.0 : 1.0 - ((slider.x - halfWay) / halfWay)
                UbuntuShape {
                    id: innerLeftShape
                    anchors.centerIn: parent
                    borderSource: "none"
                    width: parent.width - units.gu(.5)
                    height: parent.height - units.gu(.5)
                }
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3.5)
                    height: units.gu(3.5)
                    name: leftIconName
                    color: "white"
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: slider.left
                anchors.rightMargin: units.gu(1.5)
                spacing: -units.gu(1)
                visible: slider.x === halfWay
                Icon {
                    name: "back"
                    height: units.gu(2.5)
                    color: "#b2b2b2"
                    UbuntuNumberAnimation on opacity {
                        from: .5
                        to: 1
                        loops: Animation.Infinite
                        duration: UbuntuAnimation.SleepyDuration
                        easing.type: Easing.Linear
                    }
                }
                Icon {
                    name: "back"
                    height: units.gu(2.5)
                    color: "#b2b2b2"
                    UbuntuNumberAnimation on opacity {
                        from: 1
                        to: .5
                        loops: Animation.Infinite
                        duration: UbuntuAnimation.SleepyDuration
                        easing.type: Easing.Linear
                    }
                }
            }

            UbuntuShape {
                id: slider
                objectName: "slider"
                anchors.top: parent.top
                anchors.margins: gap

                Component.onCompleted: {
                    x = halfWay
                }

                Behavior on x {
                    UbuntuNumberAnimation {
                        duration: UbuntuAnimation.FastDuration
                        easing.type: Easing.OutBounce
                    }
                }

                Behavior on opacity {
                    UbuntuNumberAnimation {
                        duration: UbuntuAnimation.FastDuration
                    }
                }

                onXChanged: {
                    var factor
                    if (slider.x <= gap + leftShape.width)
                    {
                        factor = (slider.x - gap) / leftShape.width
                        slider.color = interpolate(leftShape.color, sliderDefault, factor)
                    } else if (slider.x >= rightShape.x - slider.width) {
                        factor = (slider.x - rightShape.x + rightShape.width) / rightShape.width
                        slider.color = interpolate(sliderDefault, rightShape.color, factor)
                    } else {
                        slider.color = "#b2b2b2"
                    }
                }

                z: 1
                color: "#b2b2b2"
                height: units.gu(6)
                width: units.gu(6)
                borderSource: "none"
                radius: "medium"
                Icon {
                    anchors.fill: parent
                    anchors.margins: units.gu(1.5)
                    source: "grip-large.svg"
                    color: "white"
                }
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: slider.right
                anchors.leftMargin: units.gu(1.5)
                spacing: -units.gu(1)
                visible: slider.x === halfWay
                Icon {
                    name: "next"
                    height: units.gu(2.5)
                    color: "#b2b2b2"
                    UbuntuNumberAnimation on opacity {
                        from: 1
                        to: .5
                        loops: Animation.Infinite
                        duration: UbuntuAnimation.SleepyDuration
                        easing.type: Easing.Linear
                    }
                }
                Icon {
                    name: "next"
                    height: units.gu(2.5)
                    color: "#b2b2b2"
                    UbuntuNumberAnimation on opacity {
                        from: .5
                        to: 1
                        loops: Animation.Infinite
                        duration: UbuntuAnimation.SleepyDuration
                        easing.type: Easing.Linear
                    }
                }
            }

            UbuntuShape {
                id: rightShape
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: gap
                color: "#38b44a" // UbuntuColors.green

                state: "normal"
                height: units.gu(6)
                width: units.gu(6)
                radius: "medium"
                opacity: slider.x >= halfWay ? 1.0 : slider.x / halfWay
                UbuntuShape {
                    id: innerRightShape
                    anchors.centerIn: parent
                    borderSource: "none"
                    width: parent.width - units.gu(.5)
                    height: parent.height - units.gu(.5)
                }
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3.5)
                    height: units.gu(3.5)
                    name: rightIconName
                    color: "white"
                }
            }
        }

        MouseArea {
            id: mouseArea
            objectName: "swipeMouseArea"

            anchors.fill: row
            drag.target: slider
            drag.axis: Drag.XAxis
            drag.minimumX: gap
            drag.maximumX: row.width - slider.width - gap

            onReleased: {
                if (slider.x !== drag.minimumX || slider.x !== drag.maximumX) {
                    slider.x = halfWay
                }
                if (slider.x === drag.minimumX) {
                    slider.x = drag.minimumX
                    enabled = false
                    leftTriggered()
                }
                if (slider.x === drag.maximumX) {
                    slider.x = drag.maximumX
                    enabled = false
                    rightTriggered()
                }
            }
    }
}
