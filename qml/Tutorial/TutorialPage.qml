/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import "../Components"

Showable {
    id: root

    // This is the header displayed, like "Right edge"
    property alias title: titleLabel.text

    // This is the block of text displayed below the header
    property alias text: textLabel.text

    // Whether animations are paused
    property bool paused

    // Whether to give the text the full width that the title has
    property bool fullTextWidth

    // Whether whole page (background + foreground) or just the foreground fades in
    property bool backgroundFadesIn: false

    // Whether whole page (background + foreground) or just the foreground fades out
    property bool backgroundFadesOut: false

    // The foreground Item, add children to it that you want to fade in
    property alias foreground: foregroundExtra

    // The text label bottom, so you can position elements relative to it
    readonly property real textBottom: Math.max(textLabel.y + textLabel.height, errorTextLabel.y + errorTextLabel.height)

    // The MouseArea that eats events (so you can adjust size as you will)
    property alias mouseArea: mouseArea

    // X/Y offsets for text
    property real textXOffset: 0
    property real textYOffset: 0

    // Foreground text opacity
    property real textOpacity: 1

    signal finished()

    function showError() {
        errorTimer.start();
    }

    ////

    visible: false
    shown: false

    property real _foregroundHideOpacity

    showAnimation: StandardAnimation {
        property: root.backgroundFadesIn ? "opacity" : "_foregroundHideOpacity"
        from: 0
        to: 1
        duration: root.backgroundFadesIn ? UbuntuAnimation.SleepyDuration : UbuntuAnimation.BriskDuration
        onStarted: root.visible = true
    }

    hideAnimation: StandardAnimation {
        property: root.backgroundFadesOut ? "opacity" : "_foregroundHideOpacity"
        to: 0
        duration: UbuntuAnimation.BriskDuration
        onStopped: {
            root.visible = false;
            root.finished();
        }
    }

    QtObject {
        id: d

        readonly property real sideMargin: units.gu(5.5)
        readonly property real verticalOffset: -units.gu(9)
        readonly property real textXOffset: Math.max(0, root.textXOffset - sideMargin + units.gu(2))

        property real fadeInOffset: {
            if (showAnimation.running) {
                var opacity = root[root.showAnimation.property]
                return (1 - opacity) * units.gu(3);
            } else {
                return 0;
            }
        }
    }

    Timer {
        id: errorTimer
        interval: 3500
    }

    MouseArea { // eat any errant presses
        id: mouseArea
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.82
    }

    Item {
        id: foreground
        anchors.fill: parent
        opacity: root._foregroundHideOpacity

        Item {
            anchors.fill: parent
            opacity: root.textOpacity

            Label {
                id: titleLabel
                anchors {
                    top: parent.verticalCenter
                    topMargin: d.verticalOffset + root.textYOffset
                    left: parent.left
                    leftMargin: d.sideMargin + d.textXOffset
                }
                width: parent.width - d.sideMargin * 2
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                font.weight: Font.Light
                font.pixelSize: units.gu(3.5)
            }

            Label {
                id: textLabel
                anchors {
                    top: titleLabel.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: d.sideMargin + d.textXOffset
                }
                width: (parent.width - d.sideMargin * 2) * (fullTextWidth ? 1 : 0.66)
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                font.weight: Font.Light
                font.pixelSize: units.gu(2.5)
            }

            // We use two separate labels like this rather than just changing
            // the text of the above labels because we want to know where to place
            // sliders (via root.textBottom) without having that place change
            // as the text changes length.
            Label {
                id: errorTitleLabel
                objectName: "errorTitleLabel"
                anchors {
                    top: titleLabel.top
                    left: titleLabel.left
                }
                width: titleLabel.width
                horizontalAlignment: titleLabel.horizontalAlignment
                wrapMode: titleLabel.wrapMode
                font.weight: titleLabel.font.weight
                font.pixelSize: titleLabel.font.pixelSize
                opacity: 0
                text: i18n.tr("You almost got it!")
            }

            Label {
                id: errorTextLabel
                objectName: "errorTextLabel"
                anchors {
                    top: errorTitleLabel.bottom
                    topMargin: textLabel.anchors.topMargin
                    left: textLabel.left
                }
                width: textLabel.width
                horizontalAlignment: textLabel.horizontalAlignment
                wrapMode: textLabel.wrapMode
                font.weight: textLabel.font.weight
                font.pixelSize: textLabel.font.pixelSize
                opacity: 0
                text: i18n.tr("Try again.")
            }
        }

        // A place for subclasses to add extra widgets
        Item {
            id: foregroundExtra
            anchors.fill: parent
        }
    }

    states: State {
        name: "errorState"
        when: errorTimer.running
        PropertyChanges { target: titleLabel; opacity: 0 }
        PropertyChanges { target: textLabel; opacity: 0 }
        PropertyChanges { target: errorTitleLabel; opacity: 1 }
        PropertyChanges { target: errorTextLabel; opacity: 1 }
    }

    transitions: Transition {
        to: "errorState"
        reversible: true
        SequentialAnimation {
            ParallelAnimation {
                StandardAnimation {
                    target: titleLabel
                    property: "opacity"
                    duration: UbuntuAnimation.BriskDuration
                }
                StandardAnimation {
                    target: textLabel
                    property: "opacity"
                    duration: UbuntuAnimation.BriskDuration
                }
            }
            ParallelAnimation {
                StandardAnimation {
                    target: errorTitleLabel
                    property: "opacity"
                    duration: UbuntuAnimation.BriskDuration
                }
                StandardAnimation {
                    target: errorTextLabel
                    property: "opacity"
                    duration: UbuntuAnimation.BriskDuration
                }
            }
        }
    }
}
