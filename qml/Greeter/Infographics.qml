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

import "../Components"
import "Gradient.js" as Gradient
import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: infographic

    property var model

    property int animDuration: 10

    QtObject {
        id: d
        objectName: "infographicPrivate"
        property bool useDotAnimation: true
        property int circleModifier: useDotAnimation ? 1 : 2
        property bool animating: dotHideAnimTimer.running
                              || dotShowAnimTimer.running
                              || circleChangeAnimTimer.running
    }

    Connections {
        target: model
        ignoreUnknownSignals: model === undefined

        onDataAboutToAppear: startHideAnimation() // hide "no data" label
        onDataAppeared: startShowAnimation()

        onDataAboutToChange: startHideAnimation()
        onDataChanged: startShowAnimation()

        onDataAboutToDisappear: startHideAnimation()
        onDataDisappeared: startShowAnimation() // show "no data" label
    }

    function startShowAnimation() {
        dotHideAnimTimer.stop()
        notification.hideAnim.stop()

        if (d.useDotAnimation) {
            dotShowAnimTimer.startFromBeginning()
        }
        notification.showAnim.start()
    }

    function startHideAnimation() {
        dotShowAnimTimer.stop()
        circleChangeAnimTimer.stop()
        notification.showAnim.stop()

        if (d.useDotAnimation) {
            dotHideAnimTimer.startFromBeginning()
        } else {
            circleChangeAnimTimer.startFromBeginning()
        }
        notification.hideAnim.start()
    }

    visible: model.username !== ""

    Component.onCompleted: startShowAnimation()

    Item {
        id: dataCircle
        objectName: "dataCircle"

        property real divisor: 1.5

        width: Math.min(parent.height, parent.width) / divisor
        height: width

        anchors.centerIn: parent

        Timer {
            id: circleChangeAnimTimer

            property int pastCircleCounter
            property int presentCircleCounter

            interval: notification.duration
            running: false
            repeat: true
            onTriggered: {
                if (pastCircleCounter < pastCircles.count) {
                    var nextCircle = pastCircles.itemAt(pastCircleCounter++)
                    if (nextCircle !== null) nextCircle.pastCircleChangeAnim.start()
                }
                if (pastCircleCounter > pastCircles.count / 2) {
                    var nextCircle = presentCircles.itemAt(presentCircleCounter++)
                    if (nextCircle !== null) nextCircle.presentCircleChangeAnim.start()
                }
                if (presentCircleCounter > infographic.model.currentDay && pastCircleCounter >= pastCircles.count) {
                    stop()
                }
            }

            function startFromBeginning() {
                circleChangeAnimTimer.pastCircleCounter = 0
                circleChangeAnimTimer.presentCircleCounter = 0
                start()
            }
        }

        Repeater {
            id: pastCircles
            objectName: "pastCircles"
            model: infographic.model.secondMonth

            delegate: ObjectPositioner {
                property alias pastCircleChangeAnim: pastCircleChangeAnim

                index: model.index
                count: pastCircles.count
                radius: dataCircle.width / 2
                halfSize: pastCircle.width / 2
                posOffset: 0.0

                Circle {
                    id: pastCircle
                    objectName: "pastCircle" + index

                    property real divisor: 1.8
                    property real circleOpacity: 0.1

                    width: dataCircle.width / divisor
                    height: dataCircle.height / divisor
                    opacity: 0.0
                    scale: 0.0
                    visible: modelData !== undefined
                    color: "transparent"

                    SequentialAnimation {
                        id: pastCircleChangeAnim

                        loops: 1
                        ParallelAnimation {
                            PropertyAnimation {
                                target: pastCircle
                                property: "opacity"
                                to: pastCircle.circleOpacity
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                            PropertyAnimation {
                                target: pastCircle
                                property: "scale"
                                to: modelData
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                            ColorAnimation {
                                target: pastCircle
                                property: "color"
                                to: Gradient.threeColorByIndex(index, count, infographic.model.secondColor)
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                        }
                    }
                }
            }
        }

        Repeater {
            id: presentCircles
            objectName: "presentCircles"
            model: infographic.model.firstMonth

            delegate: ObjectPositioner {
                property alias presentCircleChangeAnim: presentCircleChangeAnim

                index: model.index
                count: presentCircles.count
                radius: dataCircle.width / 2
                halfSize: presentCircle.width / 2
                posOffset: 0.0

                Circle {
                    id: presentCircle
                    objectName: "presentCircle" + index

                    property real divisor: 1.8
                    property real circleOpacity: 0.3

                    width: dataCircle.width / divisor
                    height: dataCircle.height / divisor
                    opacity: 0.0
                    scale: 0.0
                    visible: modelData !== undefined
                    color: "transparent"

                    SequentialAnimation {
                        id: presentCircleChangeAnim

                        loops: 1

                        ParallelAnimation {
                            PropertyAnimation {
                                target: presentCircle
                                property: "opacity"
                                to: presentCircle.circleOpacity
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                            PropertyAnimation {
                                target: presentCircle
                                property: "scale"
                                to: modelData
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                            ColorAnimation {
                                target: presentCircle
                                property: "color"
                                to: Gradient.threeColorByIndex(index, infographic.model.currentDay, infographic.model.firstColor)
                                easing.type: Easing.OutCurve
                                duration: circleChangeAnimTimer.interval * d.circleModifier
                            }
                        }
                    }
                }
            }
        }

        Image {
            id: backgroundCircle
            objectName: "backgroundCircle"

            anchors.fill: parent

            source: "graphics/infographic_circle_back.png"
        }

        Timer {
            id: dotShowAnimTimer

            property int dotCounter: 0

            interval: animDuration * 0.5; running: false; repeat: true
            onTriggered: {
                if (dotCounter < dots.count) {
                    var nextDot = dots.itemAt(dotCounter);
                    if (nextDot) {
                        nextDot.unlockAnimation.start();
                        if (++dotCounter == Math.round(dots.count / 2)) {
                            circleChangeAnimTimer.startFromBeginning();
                        }
                    }
                } else {
                    stop()
                }
            }

            function startFromBeginning() {
                if (!dotShowAnimTimer.running)
                    dotCounter = 0

                start()
            }
        }

        Timer {
            id: dotHideAnimTimer

            property int dotCounter

            interval: animDuration * 0.5
            running: false
            repeat: true
            onTriggered: {
                if (dotCounter >= 0) {
                    var nextDot = dots.itemAt(dotCounter--)
                    nextDot.changeAnimation.start()
                } else {
                    stop()
                }
                if (dotCounter == 0) {
                    infographic.model.readyForDataChange()
                }
            }

            function startFromBeginning() {
                if (!dotHideAnimTimer.running)
                    dotCounter = dots.count - 1

                start()
            }
        }

        Repeater {
            id: dots
            objectName: "dots"

            model: infographic.model.firstMonth

            delegate: ObjectPositioner {
                property alias unlockAnimation: dotUnlockAnim
                property alias changeAnimation: dotChangeAnim

                property int currentDay: infographic.model.currentDay

                index: model.index
                count: dots.count
                radius: backgroundCircle.width / 2
                halfSize: dot.width / 2
                posOffset: radius / dot.width / 3
                state: dot.state

                Dot {
                    id: dot
                    objectName: "dot" + index

                    property real baseOpacity: 0.4

                    width: units.dp(5) * parent.radius / 200
                    height: units.dp(5) * parent.radius / 200
                    opacity: 0.0
                    smooth: true
                    state: index < currentDay ? "filled" : index == currentDay ? "pointer" : "unfilled"

                    PropertyAnimation {
                        id: dotUnlockAnim

                        target: dot
                        property: "opacity"
                        to: dot.baseOpacity
                        duration: dotShowAnimTimer.interval
                    }

                    PropertyAnimation {
                        id: dotChangeAnim

                        target: dot
                        property: "opacity"
                        to: 0.0
                        duration: dotHideAnimTimer.interval
                    }
                }
            }
        }

        Label {
            id: notification
            objectName: "label"

            property alias hideAnim: decreaseOpacity
            property alias showAnim: increaseOpacity

            property real baseOpacity: 0.6
            property real duration: dotShowAnimTimer.interval * 5

            height: 0.7 * backgroundCircle.width
            width: notification.height
            anchors.centerIn: parent

            text: infographic.model.label

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"

            PropertyAnimation {
                id: increaseOpacity

                target: notification
                property: "opacity"
                from: 0.0
                to: notification.baseOpacity
                duration: notification.duration * dots.count
            }

            PropertyAnimation {
                id: decreaseOpacity

                target: notification
                property: "opacity"
                from: notification.baseOpacity
                to: 0.0
                duration: notification.duration * dots.count
                onStopped: if (!d.useDotAnimation) infographic.model.readyForDataChange()
            }
        }
    }

    MouseArea {
        anchors.fill: dataCircle

        onDoubleClicked: {
            if (!d.animating) {
                d.useDotAnimation = false
                infographic.model.nextDataSource()
            }
        }
    }
}
