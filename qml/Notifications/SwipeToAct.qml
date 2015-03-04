/*
 * Copyright (C) 2014 Canonical, Ltd.
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
    readonly property double halfWay: mouseArea.drag.maximumX / 2

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

                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: leftShape
                            color: "#df382c" //UbuntuColors.red
                        }
                        PropertyChanges {
                            target: innerLeftShape
                            color: "#df382c" //UbuntuColors.red
                            visible: false
                        }
                    },
                    State {
                        name: "selected"
                        PropertyChanges {
                            target: leftShape
                            color: "white"
                        }
                        PropertyChanges {
                            target: innerLeftShape
                            color: "#df382c" //UbuntuColors.red
                            visible: true
                        }
                    }
                ]
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

                onOpacityChanged: {
                    if (opacity === 0) {
                        if (rightShape.state === "selected") {
                            rightTriggered()
                        }
                        if (leftShape.state === "selected") {
                            leftTriggered()
                        }
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

                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: rightShape
                            color: "#38b44a" // UbuntuColors.green
                        }
                        PropertyChanges {
                            target: innerRightShape
                            color: "#38b44a" // UbuntuColors.green
                            visible: false
                        }
                    },
                    State {
                        name: "selected"
                        PropertyChanges {
                            target: rightShape
                            color: "white"
                        }
                        PropertyChanges {
                            target: innerRightShape
                            color: "#38b44a" // UbuntuColors.green
                            visible: true
                        }
                    }
                ]
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
            drag.minimumX: 0
            drag.maximumX: row.width - slider.width

            onReleased: {
                if (slider.x !== drag.minimumX || slider.x !== drag.maximumX) {
                    slider.x = halfWay
                }
                if (slider.x === drag.minimumX) {
                    slider.x = drag.minimumX
                    slider.opacity = 0
                    enabled = false
                    leftShape.state = "selected"
                }
                if (slider.x === drag.maximumX) {
                    slider.x = drag.maximumX
                    slider.opacity = 0
                    enabled = false
                    rightShape.state = "selected"
                }
            }
    }
}
