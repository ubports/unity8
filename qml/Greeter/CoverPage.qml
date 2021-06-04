/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
 * Copyright (C) 2021 UBports Foundation
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
import Ubuntu.Gestures 0.1
import "../Components"

Showable {
    id: root

    property real dragHandleLeftMargin
    property real launcherOffset
    property alias background: greeterBackground.source
    property alias hasCustomBackground: backgroundShade.visible
    property real panelHeight
    property var infographicModel
    property bool draggable: true

    property alias infographics: infographics

    readonly property real showProgress: MathUtils.clamp((width - Math.abs(x + launcherOffset)) / width, 0, 1)

    signal tease()
    signal clicked()

    function hideRight() {
        d.forceRightOnNextHideAnimation = true;
        hide();
    }

    function showErrorMessage(msg) {
        d.errorMessage = msg;
        showLabelAnimation.start();
        errorMessageAnimation.start();
    }

    QtObject {
        id: d
        property bool forceRightOnNextHideAnimation: false
        property string errorMessage
    }

    prepareToHide: function () {
        hideTranslation.from = root.x + translation.x
        hideTranslation.to = root.x > 0 || d.forceRightOnNextHideAnimation ? root.width : -root.width;
        d.forceRightOnNextHideAnimation = false;
    }

    // We don't directly bind "x" because that's owned by the DragHandle. So
    // instead, we can get a little extra horizontal push by using transforms.
    transform: Translate { id: translation; x: root.draggable ? launcherOffset : 0 }

    // Eat events elsewhere on the coverpage, except mouse clicks which we pass
    // up (they are used in the NarrowView to hide the cover page)
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()

        MultiPointTouchArea {
            anchors.fill: parent
            mouseEnabled: false
        }
    }

    Rectangle {
        // In case background fails to load
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
    }

    Wallpaper {
        id: greeterBackground
        objectName: "greeterBackground"
        anchors {
            fill: parent
        }
    }

    // Darkens wallpaper so that we can read text on it and see infographic
    Rectangle {
        id: backgroundShade
        objectName: "backgroundShade"
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        visible: false
    }

    Infographics {
        id: infographics
        objectName: "infographics"
        model: root.infographicModel
        clip: true // clip large data bubbles

        anchors {
            topMargin: root.panelHeight
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    Label {
        id: swipeHint
        objectName: "swipeHint"
        property real baseOpacity: 0.5
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(5)
        text: "《    " + (d.errorMessage ? d.errorMessage : i18n.tr("Unlock")) + "    》"
        color: "white"
        font.weight: Font.Light

        readonly property var opacityAnimation: showLabelAnimation // for testing

        SequentialAnimation on opacity {
            id: showLabelAnimation
            running: false
            loops: 2

            StandardAnimation {
                from: 0.0
                to: swipeHint.baseOpacity
                duration: UbuntuAnimation.SleepyDuration
            }
            PauseAnimation { duration: UbuntuAnimation.BriskDuration }
            StandardAnimation {
                from: swipeHint.baseOpacity
                to: 0.0
                duration: UbuntuAnimation.SleepyDuration
            }

            onRunningChanged: {
                if (!running)
                    d.errorMessage = "";
            }
        }
    }

    WrongPasswordAnimation {
        id: errorMessageAnimation
        objectName: "errorMessageAnimation"
        target: swipeHint
    }

    DragHandle {
        id: dragHandle
        objectName: "coverPageDragHandle"
        anchors.fill: parent
        anchors.leftMargin: root.dragHandleLeftMargin
        enabled: root.draggable
        direction: Direction.Horizontal

        onPressedChanged: {
            if (pressed) {
                root.tease();
                showLabelAnimation.start();
            }
        }
    }

    // right side shadow
    Image {
        anchors.left: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        fillMode: Image.Tile
        source: "../graphics/dropshadow_right.png"
    }

    // left side shadow
    Image {
        anchors.right: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        fillMode: Image.Tile
        source: "../graphics/dropshadow_left.png"
    }

    Binding {
        id: positionLock

        property bool enabled: false
        onEnabledChanged: {
            if (enabled === __enabled) {
                return;
            }

            if (enabled) {
                if (root.x > 0) {
                    value = Qt.binding(function() { return root.width; })
                } else {
                    value = Qt.binding(function() { return -root.width; })
                }
            }

            __enabled = enabled;
        }

        property bool __enabled: false

        target: root
        when: __enabled
        property: "x"
    }

    hideAnimation: SequentialAnimation {
        id: hideAnimation
        objectName: "hideAnimation"
        property var target // unused, here to silence Showable warning
        StandardAnimation {
            id: hideTranslation
            property: "x"
            target: root
        }
        PropertyAction { target: root; property: "visible"; value: false }
        PropertyAction { target: positionLock; property: "enabled"; value: true }
    }

    showAnimation: SequentialAnimation {
        id: showAnimation
        objectName: "showAnimation"
        property var target // unused, here to silence Showable warning
        PropertyAction { target: root; property: "visible"; value: true }
        PropertyAction { target: positionLock; property: "enabled"; value: false }
        StandardAnimation {
            property: "x"
            target: root
            to: 0
            duration: UbuntuAnimation.FastDuration
        }
    }
}
