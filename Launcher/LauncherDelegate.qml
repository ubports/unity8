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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root

    property string iconName

    property real angle: 0
    property bool highlighted: false
    property real offset: 0

    property real maxAngle: 0
    property bool inverted: false

    readonly property int effectiveHeight: Math.cos(angle * Math.PI / 180) * height
    readonly property real foldedHeight: Math.cos(maxAngle * Math.PI / 180) * height

    property int itemsBeforeThis: 0
    property int itemsAfterThis: 0

    property bool dragging:false

    signal clicked()
    signal longtap()
    signal released()

    UbuntuShape {
        id: iconItem
        color: Qt.rgba(0, 0, 1, 0.5)
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.offset  + (height - root.effectiveHeight)/2 * (angle < 0 ? -1 : 1)
        rotation: root.inverted ? 180 : 0
        radius: "medium"

        transform: Rotation {
            axis { x: 1; y: 0; z: 0 }
            origin { x: iconItem.width / 2; y: iconItem.height / 2; z: 0 }
            angle: root.angle
        }

        image: Image {
            source: "../graphics/applicationIcons/" + root.iconName + ".png"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
            onCanceled: root.released()
            preventStealing: false

            onPressAndHold: {
                root.state = "moving"
            }
            onReleased: {
                root.state = "docked"
            }
        }

        BorderImage {
            id: overlayHighlight
            anchors.centerIn: iconItem
            rotation: inverted ? 180 : 0
            source: root.highlighted || mouseArea.pressed ? "graphics/selected.sci" : "graphics/non-selected.sci"
            width: iconItem.width + units.gu(1.5)
            height: width
        }
    }

    states: [
        State {
            name: "docked"
            PropertyChanges {
                target: root
                offset: if (launcherFlickable.contentY > itemsBeforeThis * (foldedHeight + launcherColumn.spacing*2)) {
                            return launcherFlickable.contentY - (index * (foldedHeight + launcherColumn.spacing*2));
                        } else if (y + height - launcherFlickable.contentY > launcherFlickable.height - (itemsAfterThis*(foldedHeight - launcherColumn.spacing))) {
                            return launcherFlickable.height - (y+height) + launcherFlickable.contentY - (itemsAfterThis*(foldedHeight - launcherColumn.spacing));
                        } else {
                            return 0;
                        }
                angle: -Math.min(Math.max(offset * maxAngle / foldedHeight, -maxAngle), maxAngle)

            }
        },

        State {
            name: "moving"
            PropertyChanges {
                target: launcherDelegate;
                offset: 0
                angle: 0
            }
            PropertyChanges {
                target: root
                highlighted: true
                dragging: true
            }
            PropertyChanges {
                target: mouseArea
                preventStealing: true
                drag.target: root
            }
        }

    ]

}
