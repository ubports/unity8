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

import Powerd 0.1
import QtQuick 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Application 0.1
import Ubuntu.Components 0.1

Showable {
    id: overlay

    /*
     * Valid values are "left", "right", "top", "bottom", or "none".
     */
    property string edge: "top"

    /*
     * This is the header displayed, like "Right edge".
     */
    property alias title: titleLabel.text

    /*
     * This is the block of text displayed below the header.
     */
    property alias text: textLabel.text

    /*
     * This is the text for the skip button.
     */
    property alias skipText: skipLabel.text

    /*
     * Whether this demo is running currently.
     */
    readonly property bool active: available && visible

    property color __orange_transparent: Qt.hsla(16.0/360.0, 0.83, 0.47, 0.4)
    property int __edge_margin: units.gu(4)
    property int __text_margin: units.gu(3)
    property bool __skip_on_hide: false
    property int __anim_running: wholeAnimation.running // for testing

    signal skip()

    function doSkip() {
        __skip_on_hide = true;
        hide();
    }

    function hideNow() {
        overlay.visible = false;
        overlay.available = false;
        if (overlay.__skip_on_hide) {
            overlay.skip();
        }
    }

    showAnimation: StandardAnimation {
        property: "opacity"
        to: 1
        onRunningChanged: if (running) overlay.visible = true
    }
    hideAnimation: StandardAnimation {
        property: "opacity"
        to: 0
        duration: UbuntuAnimation.BriskDuration
        onRunningChanged: if (!running) overlay.hideNow()
    }

    Rectangle {
        id: backgroundShade
        anchors.fill: parent
        color: "black"
        opacity: 0.8
        visible: overlay.active

        MouseArea {
            anchors.fill: parent
            enabled: overlay.edge == "none" && overlay.opacity == 1.0
            onClicked: overlay.doSkip()
        }
    }

    Item {
        id: hintGroup
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        visible: overlay.active

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
                fontSize: "x-large"
                width: units.gu(25)
                wrapMode: Text.WordWrap
            }

            Label {
                id: textLabel
                width: units.gu(25)
                wrapMode: Text.WordWrap
            }

            Label {
                id: skipLabel
                objectName: "skipLabel"
                text: i18n.tr("Skip intro")
                color: UbuntuColors.orange
                fontSize: "small"
                font.underline: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: overlay.doSkip()
                }
            }
        }

        LinearGradient {
            id: edgeHint
            property int size: 1
            cached: false
            visible: overlay.edge != "none"
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
        id: wholeAnimation
        running: overlay.active

        ParallelAnimation {
            id: fadeInAnimation

            StandardAnimation {
                target: labelGroup
                property: {
                    if (overlay.edge == "right" || overlay.edge == "left") {
                        return "anchors.leftMargin";
                    } else if (overlay.edge == "bottom") {
                        return "anchors.bottomMargin";
                    } else {
                        return "anchors.topMargin";
                    }
                }
                from: {
                    if (overlay.edge == "right") {
                        return overlay.__edge_margin + units.gu(3)
                    } else {
                        return overlay.__edge_margin - units.gu(3)
                    }
                }
                to: overlay.__edge_margin
                duration: overlay.edge == "none" ? 0 : UbuntuAnimation.SleepyDuration
            }
            StandardAnimation {
                target: overlay
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: UbuntuAnimation.SleepyDuration
            }
        }

        SequentialAnimation {
            id: hintAnimation
            loops: Animation.Infinite
            property string prop: (overlay.edge == "left" || overlay.edge == "right") ? "x" : "y"
            property double endVal: units.dp(5) * ((overlay.edge == "left" || overlay.edge == "top") ? 1 : -1)
            property double maxGlow: units.dp(20)
            property int duration: overlay.edge == "none" ? 0 : UbuntuAnimation.SleepyDuration

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

    // Watch display, so we can turn off animation if it does.  No reason to
    // chew CPU when user isn't watching.
    Connections {
        id: powerConnection
        target: Powerd

        onDisplayPowerStateChange: {
            if (status == Powerd.Off && wholeAnimation.running) {
                wholeAnimation.paused = true;
                //hintAnimation.paused = true;
            } else if (status == Powerd.On) {
                wholeAnimation.paused = false;
                //hintAnimation.paused = false;
            }
        }
    }
}
