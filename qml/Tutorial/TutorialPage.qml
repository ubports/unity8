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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "../Components"

Showable {
    id: root

    // This is the header displayed, like "Right edge"
    property alias title: titleLabel.text

    // This is the block of text displayed below the header
    property alias text: textLabel.text

    // This is the text for the skip button
    property string skipText: i18n.tr("Skip tutorial")

    // Whether animations are paused
    property bool paused

    // Which page number this page represents, 1-indexed
    property int pageNumber

    // How many pages there are total
    property int pageTotal

    // Whether whole page (background + foreground) or just the foreground fades in
    property bool backgroundFadesIn: false

    // Whether whole page (background + foreground) or just the foreground fades out
    property bool backgroundFadesOut: false

    // An integrated glowing Bar class, for convenience
    property alias bar: bar

    // The foreground Item, add children to it that you want to fade in
    property alias foreground: foregroundExtra

    // The MouseArea that eats events (so you can adjust size as you will)
    property alias mouseArea: mouseArea

    // X/Y offsets for text
    property real textXOffset: 0
    property real textYOffset: 0

    signal finished()

    ////

    shown: false
    Component.onCompleted: show()

    property alias _foregroundOpacity: foreground.opacity

    showAnimation: StandardAnimation {
        property: root.backgroundFadesIn ? "opacity" : "_foregroundOpacity"
        from: 0
        to: 1
        duration: root.backgroundFadesIn ? UbuntuAnimation.SleepyDuration : UbuntuAnimation.BriskDuration
    }

    hideAnimation: StandardAnimation {
        property: root.backgroundFadesOut ? "opacity" : "_foregroundOpacity"
        to: 0
        duration: UbuntuAnimation.BriskDuration
        onRunningChanged: {
            if (!running) {
                root.finished();
            }
        }
    }

    QtObject {
        id: d

        property real sideMargin: units.gu(6)
        property real verticalOffset: -units.gu(3)
        property real buttonMargin: units.gu(2)
        property real paginationOffset: units.gu(12)

        property real fadeInOffset: {
            if (showAnimation.running) {
                var opacity = root[root.showAnimation.property]
                return (1 - opacity) * units.gu(3);
            } else {
                return 0;
            }
        }

        property real xLabelOffset: {
            if (bar.direction === "right") {
                return bar.offset - fadeInOffset + root.textXOffset;
            } else if (bar.direction === "left") {
                return -bar.offset + fadeInOffset + root.textXOffset;
            } else {
                return root.textXOffset;
            }
        }
        property real yLabelOffset: {
            if (bar.direction === "down") {
                return bar.offset - fadeInOffset + root.textYOffset;
            } else if (bar.direction === "up") {
                return -bar.offset + fadeInOffset + root.textYOffset;
            } else {
                return root.textYOffset;
            }
        }
    }

    MouseArea { // eat any errant presses
        id: mouseArea
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.8
    }

    Item {
        id: foreground
        anchors.fill: parent

        Label {
            id: titleLabel
            anchors {
                bottom: textLabel.top
                bottomMargin: units.gu(2)
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: d.xLabelOffset - root.textXOffset / 2
            }
            width: parent.width - d.sideMargin * 2 - root.textXOffset
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: units.gu(4)
            text: root.title
        }

        Label {
            id: textLabel
            anchors {
                top: parent.verticalCenter
                topMargin: d.verticalOffset + d.yLabelOffset
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: d.xLabelOffset - root.textXOffset / 2
            }
            width: parent.width - d.sideMargin * 2 - root.textXOffset
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            fontSize: "large"
            text: root.text
        }

        Row {
            visible: root.pageNumber > 0
            spacing: units.gu(0.5)
            anchors {
                bottom: parent.bottom
                bottomMargin: d.paginationOffset
                horizontalCenter: parent.horizontalCenter
            }
            Repeater {
                model: root.pageTotal
                Image {
                    height: units.gu(1)
                    width: height
                    source: (index === root.pageNumber - 1) ?
                            "../Dash/graphics/pagination_dot_on.png" :
                            "../Dash/graphics/pagination_dot_off.png"
                }
            }
        }

        MouseArea {
            visible: root.pageNumber > 0
            enabled: visible
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            implicitHeight: skipLabel.height + d.buttonMargin * 2
            implicitWidth: skipLabel.width + d.buttonMargin * 2

            Label {
                id: skipLabel
                objectName: "skipLabel"
                anchors.centerIn: parent
                // Translators: This is the arrow for "Skip tutorial" buttons
                text: i18n.tr("%1  〉").arg(root.skipText)
            }

            onClicked: root.hide()
        }

        Bar {
            id: bar
            animating: !root.paused
            anchors {
                top: direction === "up" ? undefined : parent.top
                bottom: direction === "down" ? undefined : parent.bottom
                left: direction === "left" ? undefined : parent.left
                right: direction === "right" ? undefined : parent.right
            }
        }

        // A place for subclasses to add extra widgets
        Item {
            id: foregroundExtra
            anchors.fill: parent
        }
    }
}
