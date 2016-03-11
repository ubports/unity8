/*
 * Copyright (C) 2015 Canonical, Ltd.
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

/*
   An edge barrier for the mouse pointer

   The further you push against it, the stronger the visual hint. Until it's
   overcome, when passed() is emitted.
 */
Item {
    id: root

    // Supported values are: Qt.LeftEdge, Qt.RightEdge
    property int edge: Qt.LeftEdge

    property Item target: parent
    function push(amount) { controller.push(amount); }
    signal passed()

    anchors.top: (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? target.top : undefined
    anchors.bottom: (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? target.bottom : undefined
    anchors.left: edge == Qt.LeftEdge ? target.left : undefined
    anchors.right: edge == Qt.RightEdge ? target.right : undefined

    width: units.gu(0.5)

    property Component material

    Loader {
        id: materialContainer

        sourceComponent: root.material

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: root.edge == Qt.LeftEdge ? root.left : undefined
        anchors.right: root.edge == Qt.RightEdge ? root.right : undefined

        anchors.leftMargin: root.edge == Qt.LeftEdge ? -width * (1 - positionProgress) : 0
        anchors.rightMargin: root.edge == Qt.RightEdge ? -width * (1 - positionProgress) : 0

        property real positionProgress

        visible: positionProgress > 0

        width: units.gu(2)
    }

    EdgeBarrierController {
        id: controller
        objectName: "edgeBarrierController"
        anchors.fill: parent
        onPassed: root.passed();
    }

    state: {
        if (controller.progress === 0.0) {
            return "";
        } else if (controller.progress < 1.0) {
            return "resisting";
        } else { // controller.progress == 1.0
            return "passed";
        }
    }
    states: [
        State {
            name: ""
            PropertyChanges { target: materialContainer; opacity: 0.0 }
            PropertyChanges { target: materialContainer; positionProgress: 0.0 }
        },
        State {
            name: "resisting"
            PropertyChanges { target: materialContainer; opacity: controller.progress }
            PropertyChanges { target: materialContainer; positionProgress: controller.progress }
        },
        State {
            name: "passed"
            PropertyChanges { target: materialContainer; opacity: 0.0 }
            PropertyChanges { target: materialContainer; positionProgress: 1.0 }
        }
    ]
    transitions: [
        Transition {
            from: "passed"; to: ""
        },
        Transition {
            from: "resisting"; to: ""
            UbuntuNumberAnimation { target: materialContainer; properties: "opacity,positionProgress" }
        },
        Transition {
            from: "resisting"; to: "passed"
            UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration; target: materialContainer; property: "opacity" }
        }
    ]
}
