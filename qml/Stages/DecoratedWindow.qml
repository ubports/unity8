/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Unity.Application 0.1

FocusScope {
    id: root

    width: !counterRotate ? applicationWindow.width : applicationWindow.height
    height: visibleDecorationHeight + (!counterRotate ? applicationWindow.height : applicationWindow.width)

    property alias application: applicationWindow.application
    property alias surface: applicationWindow.surface
    property alias active: decoration.active
    readonly property alias title: applicationWindow.title
    property alias fullscreen: applicationWindow.fullscreen
    property alias maximizeButtonShown: decoration.maximizeButtonShown

    readonly property bool decorationShown: !fullscreen
    property bool highlightShown: false
    property real shadowOpacity: 1

    property real requestedWidth
    property real requestedHeight

    property alias surfaceOrientationAngle: applicationWindow.surfaceOrientationAngle
    readonly property real visibleDecorationHeight: root.decorationShown ? decoration.height : 0
    readonly property bool counterRotate: surfaceOrientationAngle != 0 && surfaceOrientationAngle != 180

    readonly property int minimumWidth: !counterRotate ? applicationWindow.minimumWidth : applicationWindow.minimumHeight
    readonly property int minimumHeight: visibleDecorationHeight + (!counterRotate ? applicationWindow.minimumHeight : applicationWindow.minimumWidth)
    readonly property int maximumWidth: !counterRotate ? applicationWindow.maximumWidth : applicationWindow.maximumHeight
    readonly property int maximumHeight: (root.decorationShown && applicationWindow.maximumHeight > 0 ? decoration.height : 0)
                                         + (!counterRotate ? applicationWindow.maximumHeight : applicationWindow.maximumWidth)
    readonly property int widthIncrement: !counterRotate ? applicationWindow.widthIncrement : applicationWindow.heightIncrement
    readonly property int heightIncrement: !counterRotate ? applicationWindow.heightIncrement : applicationWindow.widthIncrement

    property alias overlayShown: decoration.overlayShown

    signal closeClicked()
    signal maximizeClicked()
    signal maximizeHorizontallyClicked()
    signal maximizeVerticallyClicked()
    signal minimizeClicked()
    signal decorationPressed()

    Rectangle {
        id: selectionHighlight
        anchors.fill: parent
        anchors.margins: -units.gu(1)
        color: "white"
        opacity: highlightShown ? 0.15 : 0
    }

    Rectangle {
        anchors { left: selectionHighlight.left; right: selectionHighlight.right; bottom: selectionHighlight.bottom; }
        height: units.dp(2)
        color: theme.palette.normal.focus
        visible: highlightShown
    }

    BorderImage {
        anchors {
            fill: root
            margins: active ? -units.gu(2) : -units.gu(1.5)
        }
        source: "graphics/dropshadow2gu.sci"
        opacity: root.shadowOpacity * .3
        visible: !fullscreen
    }

    WindowDecoration {
        id: decoration
        target: root.parent
        objectName: "appWindowDecoration"
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(3)
        width: root.width
        title: applicationWindow.title
        visible: root.decorationShown

        onCloseClicked: root.closeClicked();
        onMaximizeClicked: { root.decorationPressed(); root.maximizeClicked(); }
        onMaximizeHorizontallyClicked: { root.decorationPressed(); root.maximizeHorizontallyClicked(); }
        onMaximizeVerticallyClicked: { root.decorationPressed(); root.maximizeVerticallyClicked(); }
        onMinimizeClicked: root.minimizeClicked();
        onPressed: root.decorationPressed();
    }

    ApplicationWindow {
        id: applicationWindow
        objectName: "appWindow"
        anchors.top: parent.top
        anchors.topMargin: decoration.height
        anchors.left: parent.left
        readonly property real requestedHeightMinusDecoration: root.requestedHeight - root.visibleDecorationHeight
        requestedHeight: !counterRotate ? requestedHeightMinusDecoration : root.requestedWidth
        requestedWidth: !counterRotate ? root.requestedWidth : requestedHeightMinusDecoration
        interactive: true
        focus: true

        transform: Rotation {
                readonly property int rotationAngle: applicationWindow.application &&
                                                     applicationWindow.application.rotatesWindowContents
                                                     ? ((360 - applicationWindow.surfaceOrientationAngle) % 360) : 0
                origin.x: {
                    if (rotationAngle == 90) return applicationWindow.height / 2;
                    else if (rotationAngle == 270) return applicationWindow.width / 2;
                    else if (rotationAngle == 180) return applicationWindow.width / 2;
                    else return 0;
                }
                origin.y: {
                    if (rotationAngle == 90) return applicationWindow.height / 2;
                    else if (rotationAngle == 270) return applicationWindow.width / 2;
                    else if (rotationAngle == 180) return applicationWindow.height / 2;
                    else return 0;
                }
                angle: rotationAngle
        }
    }
}
