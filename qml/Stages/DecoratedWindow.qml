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
import "Spread/MathUtils.js" as MathUtils

FocusScope {
    id: root

    // The DecoratedWindow takes requestedWidth/requestedHeight and asks it's surface to be resized to that
    // (minus the window decoration size in case hasDecoration and showDecoration are true)
    // The surface might not be able to resize to the requested values. It will return its actual size
    // in implicitWidth/implicitHeight.
    implicitWidth: !counterRotate ? applicationWindow.implicitWidth : applicationWindow.implicitHeight
    implicitHeight: decorationHeight + (!counterRotate ? applicationWindow.implicitHeight : applicationWindow.implicitWidth)

    property alias application: applicationWindow.application
    property alias surface: applicationWindow.surface
    property alias active: decoration.active
    readonly property alias title: applicationWindow.title
    property alias maximizeButtonShown: decoration.maximizeButtonShown

    // Changing this will actually add/remove a decoration, meaning, requestedHeight will take the decoration into account.
    property bool hasDecoration: true
    // This will temporarily show/hide the decoration without actually changing the surface's dimensions
    property bool showDecoration: true
    property bool animateDecoration: false
    property bool showHighlight: false
    property real shadowOpacity: 0

    property real requestedWidth
    property real requestedHeight
    property real scaleToPreviewProgress: 0
    property int scaleToPreviewSize: units.gu(30)

    property alias surfaceOrientationAngle: applicationWindow.surfaceOrientationAngle
    readonly property real decorationHeight: Math.min(d.visibleDecorationHeight, d.requestedDecorationHeight)
    readonly property bool counterRotate: surfaceOrientationAngle != 0 && surfaceOrientationAngle != 180

    readonly property int minimumWidth: !counterRotate ? applicationWindow.minimumWidth : applicationWindow.minimumHeight
    readonly property int minimumHeight: decorationHeight + (!counterRotate ? applicationWindow.minimumHeight : applicationWindow.minimumWidth)
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

    QtObject {
        id: d
        property int requestedDecorationHeight: root.hasDecoration && root.hasDecoration ? decoration.height : 0
        Behavior on requestedDecorationHeight { enabled: root.animateDecoration; UbuntuNumberAnimation { duration: priv.animationDuration } }

        property int visibleDecorationHeight: root.showDecoration && root.hasDecoration ? decoration.height : 0
        Behavior on visibleDecorationHeight { enabled: root.animateDecoration; UbuntuNumberAnimation { duration: priv.animationDuration } }
    }

    Rectangle {
        id: selectionHighlight
        anchors.fill: parent
        anchors.margins: -units.gu(1)
        color: "white"
        opacity: showHighlight ? 0.15 : 0
    }

    Rectangle {
        anchors { left: selectionHighlight.left; right: selectionHighlight.right; bottom: selectionHighlight.bottom; }
        height: units.dp(2)
        color: theme.palette.normal.focus
        visible: showHighlight
    }

    BorderImage {
        anchors {
            fill: decoratedWindow
            margins: active ? -units.gu(2) : -units.gu(1.5)
        }
        source: "graphics/dropshadow2gu.sci"
        opacity: root.shadowOpacity
    }

    WindowDecoration {
        id: decoration
        target: root.parent
        objectName: "appWindowDecoration"
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(3)
        width: root.width
        title: applicationWindow.title
        opacity: root.hasDecoration && root.showDecoration ? 1 : 0

        // FIXME: priv.animationDuration reaches out of context... neads cleanup before landing
        Behavior on opacity { UbuntuNumberAnimation { duration: priv.animationDuration } }

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
        anchors.topMargin: root.decorationHeight
        anchors.left: parent.left
        width: root.width
        height: root.height - anchors.topMargin
        requestedHeight: !counterRotate ? root.requestedHeight - d.requestedDecorationHeight : root.requestedWidth
        requestedWidth: !counterRotate ? root.requestedWidth : root.requestedHeight - d.requestedDecorationHeight
        property int oldRequestedWidth: requestedWidth
        property int oldRequestedHeight: requestedHeight
        onRequestedWidthChanged: oldRequestedWidth = requestedWidth
        onRequestedHeightChanged: oldRequestedHeight = requestedHeight
        interactive: true
        focus: true

        property real itemScale: 1
        property real minSize: Math.min(root.scaleToPreviewSize, Math.min(applicationWindow.requestedHeight, applicationWindow.requestedWidth))
        states: [
            State {
                name: "preview"; when: root.scaleToPreviewProgress > 0
                PropertyChanges {
                    target: applicationWindow;
                    requestedWidth: applicationWindow.oldRequestedWidth
                    requestedHeight: applicationWindow.oldRequestedHeight
                    implicitWidth: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedWidth, root.scaleToPreviewSize, root.scaleToPreviewProgress)
                    implicitHeight: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedHeight, root.scaleToPreviewSize, root.scaleToPreviewProgress)
                    width: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedWidth, applicationWindow.minSize, root.scaleToPreviewProgress)
                    height: MathUtils.linearAnimation(0, 1, applicationWindow.oldRequestedHeight, applicationWindow.minSize, root.scaleToPreviewProgress)
                    // This is not 100% matching as it animates to an animated height, but close enough for the speed the animation plays
                    itemScale: MathUtils.linearAnimation(0, 1, 1, 1.0 * root.scaleToPreviewSize / Math.min(applicationWindow.height, applicationWindow.width), root.scaleToPreviewProgress)
                }
            }
        ]

        transform: [
            Rotation {
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
            },
            Scale {
                xScale: applicationWindow.itemScale
                yScale: applicationWindow.itemScale
            }

        ]
    }

//    Rectangle { anchors.fill: parent; color: "blue"; opacity: .3 }
}
