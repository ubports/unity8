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
import Unity.Application 0.1
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
     * This is the visible status of the skip button.
     */
    property alias showSkip: skipLabel.visible

    /*
     * Whether this demo is running currently.
     */
    readonly property bool active: available && visible

    /*
     * Whether animations are paused.
     */
    property alias paused: wholeAnimation.paused

    /*
     * Whether animations are running.
     */
    readonly property alias running: wholeAnimation.running

    signal skip()

    function doSkip() {
        d.skipOnHide = true;
        hide();
    }

    function hideNow() {
        overlay.visible = false;
        overlay.available = false;
        if (d.skipOnHide) {
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

    QtObject {
        id: d
        property bool skipOnHide: false
        property int edgeMargin: units.gu(4)
    }

    Rectangle {
        objectName: "backgroundShade"

        anchors.fill: parent
        color: "black"
        opacity: 0.8
        visible: overlay.active

        MouseArea {
            objectName: "backgroundShadeMouseArea"

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
            spacing: units.gu(3)

            anchors {
                margins: d.edgeMargin
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

                Icon {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: units.dp(12)
                    width: units.dp(12)
                    name: "chevron"
                    color: UbuntuColors.orange
                }

                MouseArea {
                    // Make clickable area bigger than just the link because
                    // otherwise, the edge demo will feel hard to dismiss.
                    anchors.fill: parent
                    anchors.margins: -units.gu(5)
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
                    color: Qt.hsla(16.0/360.0, 0.83, 0.47, 0.4) // UbuntuColors.orange, but transparent
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
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
        objectName: "wholeAnimation"
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
                        return d.edgeMargin + units.gu(3)
                    } else {
                        return d.edgeMargin - units.gu(3)
                    }
                }
                to: d.edgeMargin
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
}
