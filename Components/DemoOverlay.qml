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
import QtGraphicalEffects 1.0
import GSettings 1.0
import Ubuntu.Application 0.1
import Ubuntu.Components 0.1

Item {
    id: overlay

    /*
     * Valid values are "left", "right", "top", or "bottom".
     */
    property string edge: "top"

    /*
     * This is the header displayed, like "Right edge".
     */
    property string title

    /*
     * This is the block of text displayed below the header.
     */
    property string text

    property color __orange: Qt.hsla(16.0/360.0, 0.83, 0.47, 1.0)
    property color __orange_transparent: Qt.hsla(16.0/360.0, 0.83, 0.47, 0.4)
    property int __edge_margin: units.gu(4)
    property int __text_margin: units.gu(3)

    function __isDemoSkipped() {
        // Check global spot, then check gsettings
    }

    function __setDemoSkipped() {
        // We are running in one of two modes:
        // 1) As a greeter as the lightdm user
        // 2) As a shell as session user
    }

    Rectangle {
        id: backgroundShade
        anchors.fill: parent
        color: "black"
        opacity: 0.8
    }

    Item {
        id: hintGroup
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        Column {
            id: labelGroup
            layer.enabled: true // otherwise the underlining on "Skip intro" jumps
            spacing: overlay.__text_margin

            anchors {
                margins: overlay.__edge_margin
                left: parent.left
                top: overlay.edge == "bottom" ? undefined : parent.top
                bottom: overlay.edge == "bottom" ? parent.bottom : undefined
            }

            Label {
                id: titleLabel
                text: overlay.title
                color: "#B7B3AC"
                fontSize: "x-large"
                width: units.gu(25)
                wrapMode: Text.WordWrap
            }

            Label {
                id: textLabel
                text: overlay.text
                color: "#B7B3AC"
                width: units.gu(25)
                wrapMode: Text.WordWrap
            }

            Label {
                id: skipLabel
                text: i18n.tr("Skip intro")
                color: overlay.__orange
                fontSize: "small"
                font.underline: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked!");
                        __setDemoSkipped();
                        overlay.visible = false;
                    }
                }
            }
        }

        LinearGradient {
            id: edgeHint
            property int size: 1
            cached: false
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: overlay.__orange_transparent
                }
                GradientStop {
                    position: 1.0
                    color: "#00000000"
                }
            }
            anchors.fill: parent
            start: {
                if (overlay.edge == "right") {
                    return Qt.point(width, 0);
                } else if (overlay.edge == "left") {
                    return Qt.point(0, 0);
                } else if (overlay.edge == "top") {
                    return Qt.point(0, 0);
                } else {
                    return Qt.point(0, height);
                }
            }
            end: {
                if (overlay.edge == "right") {
                    return Qt.point(width - size, 0);
                } else if (overlay.edge == "left") {
                    return Qt.point(size, 0);
                } else if (overlay.edge == "top") {
                    return Qt.point(0, size);
                } else {
                    return Qt.point(0, height - size);
                }
            }
        }
    }

    SequentialAnimation {
        id: hintAnimation
        loops: Animation.Infinite
        running: true
        property string prop: (overlay.edge == "left" || overlay.edge == "right") ? "x" : "y"
        property double endVal: units.dp(5) * ((overlay.edge == "left" || overlay.edge == "top") ? 1 : -1)
        property double maxGlow: units.dp(20)
        property int duration: 1000

        ParallelAnimation {
            StandardAnimation { target: hintGroup; property: hintAnimation.prop; from: 0; to: hintAnimation.endVal; duration: hintAnimation.duration }
            StandardAnimation { target: edgeHint; property: "size"; from: 1; to: hintAnimation.maxGlow; duration: hintAnimation.duration }
        }

        // Undo the above
        ParallelAnimation {
            StandardAnimation { target: hintGroup; property: hintAnimation.prop; from: hintAnimation.endVal; to: 0; duration: hintAnimation.duration }
            StandardAnimation { target: edgeHint; property: "size"; from: hintAnimation.maxGlow; to: 1; duration: hintAnimation.duration }
        }
    }
}
