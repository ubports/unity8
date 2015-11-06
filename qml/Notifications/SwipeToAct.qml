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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: swipeToAct

    height: clickToAct ? leftButton.height : childrenRect.height

    signal leftTriggered()
    signal rightTriggered()

    property string leftIconName
    property string rightIconName

    property bool clickToAct

    QtObject {
        id: priv

        property double opacityDelta
        readonly property double sliderHeight: units.gu(8)
        readonly property double gap: units.gu(1)
        readonly property color sliderMainColor: "#b2b2b2"
        readonly property color sliderBGColor: "#f4f4f4"
        readonly property double halfWay: mouseArea.drag.maximumX / 2

        UbuntuNumberAnimation on opacityDelta {
            from: 0
            to: .5
            loops: Animation.Infinite
            duration: UbuntuAnimation.SleepyDuration
            easing.type: Easing.Linear
        }

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
    }

    Button {
        id: leftButton
        objectName: "leftButton"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        iconName: leftIconName
        visible: clickToAct
        width: (parent.width / 2) - priv.gap
        color: UbuntuColors.red
        onClicked: {
            leftTriggered()
        }
    }

    Button {
        id: rightButton
        objectName: "rightButton"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        iconName: rightIconName
        visible: clickToAct
        width: (parent.width / 2) - priv.gap
        color: UbuntuColors.green
        onClicked: {
            rightTriggered()
        }
    }

    UbuntuShape {
        id: row
        width: parent.width
        height: priv.sliderHeight
        backgroundColor: priv.sliderBGColor
        aspect: UbuntuShape.Flat
        visible: !clickToAct

        UbuntuShape {
            id: leftShape
            objectName: "leftArea"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: priv.gap
            backgroundColor: UbuntuColors.red
            aspect: UbuntuShape.Flat

            state: "normal"
            height: units.gu(6)
            width: units.gu(6)
            radius: "medium"
            opacity: slider.x <= priv.halfWay ? 1.0 : 1.0 - ((slider.x - priv.halfWay) / priv.halfWay)

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
            visible: slider.x === priv.halfWay
            Icon {
                name: "back"
                height: units.gu(2.5)
                color: priv.sliderMainColor
                opacity: .5 + priv.opacityDelta
            }
            Icon {
                name: "back"
                height: units.gu(2.5)
                color: priv.sliderMainColor
                opacity: 1 - priv.opacityDelta
            }
        }

        UbuntuShape {
            id: slider
            objectName: "slider"
            anchors.top: parent.top
            anchors.margins: priv.gap
            x: priv.halfWay

            Component.onCompleted: {
                xBehavior.enabled = true
            }

            Behavior on x {
                id: xBehavior
                enabled: false
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
                if (slider.x <= priv.gap + leftShape.width)
                {
                    factor = (slider.x - priv.gap) / leftShape.width
                    slider.color = priv.interpolate(leftShape.color, priv.sliderMainColor, factor)
                } else if (slider.x >= rightShape.x - slider.width) {
                    factor = (slider.x - rightShape.x + rightShape.width) / rightShape.width
                    slider.color = priv.interpolate(priv.sliderMainColor, rightShape.color, factor)
                } else {
                    slider.color = priv.sliderMainColor
                }
            }

            z: 1
            backgroundColor: priv.sliderMainColor
            height: units.gu(6)
            width: units.gu(6)
            aspect: UbuntuShape.Flat
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
            visible: slider.x === priv.halfWay
            Icon {
                name: "next"
                height: units.gu(2.5)
                color: priv.sliderMainColor
                opacity: 1 - priv.opacityDelta
            }
            Icon {
                name: "next"
                height: units.gu(2.5)
                color: priv.sliderMainColor
                opacity: 0.5 + priv.opacityDelta
            }
        }

        UbuntuShape {
            id: rightShape
            objectName: "rightArea"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: priv.gap
            backgroundColor: UbuntuColors.green
            aspect: UbuntuShape.Flat

            state: "normal"
            height: units.gu(6)
            width: units.gu(6)
            radius: "medium"
            opacity: slider.x >= priv.halfWay ? 1.0 : slider.x / priv.halfWay

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
        enabled: !clickToAct

        anchors.fill: row
        drag.target: slider
        drag.axis: Drag.XAxis
        drag.minimumX: priv.gap
        drag.maximumX: row.width - slider.width - priv.gap

        onReleased: {
            if (slider.x !== drag.minimumX || slider.x !== drag.maximumX) {
                slider.x = priv.halfWay
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
