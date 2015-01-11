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

import QtQuick 2.3
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1
import Ubuntu.Gestures 0.1
import "../Components"

Showable {
    id: root

    property real dragHandleLeftMargin
    property real launcherOffset
    property alias background: greeterBackground.source
    property real backgroundTopMargin
    property bool ready: greeterBackground.source == "" || greeterBackground.status == Image.Ready || greeterBackground.status == Image.Error
    property int currentIndex
    property bool draggable: true

    property alias infographics: infographics

    readonly property real showProgress: MathUtils.clamp((width - Math.abs(x)) / width, 0, 1)

    signal tease()

    function hideRight() {
        if (shown) {
            hideAnimation = d.rightHideAnimation;
            hide();
        }
    }

    property real dragOffset
    x: launcherOffset + dragOffset

    function startTease() {
        tease();
        showLabelAnimation.start();
    }

    DragHandle {
        id: dragHandle
        anchors.fill: parent
        anchors.leftMargin: root.dragHandleLeftMargin
        enabled: root.draggable
        direction: Direction.Horizontal

        onTapped: root.startTease()

        onDraggingChanged: {
            if (dragging) {
                root.startTease();
            }
        }
    }

    Rectangle {
        // In case background fails to load
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
    }

    CrossFadeImage {
        id: greeterBackground
        objectName: "greeterBackground"
        anchors {
            fill: parent
            topMargin: root.backgroundTopMargin
        }
        fillMode: Image.PreserveAspectCrop
        // Limit how much memory we'll reserve for this image
        sourceSize.height: height
        sourceSize.width: width
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }

    Infographics {
        id: infographics
        objectName: "infographics"
        height: parent.height
        model: LightDM.Infographic

        property string selectedUser: LightDM.Users.data(root.currentIndex, LightDM.UserRoles.NameRole)

        Component.onCompleted: {
            LightDM.Infographic.readyForDataChange();
        }

        Binding {
            target: LightDM.Infographic
            property: "username"
            value: AccountsService.statsWelcomeScreen ? infographics.selectedUser : ""
        }

        Connections {
            target: i18n
            onLanguageChanged: LightDM.Infographic.readyForDataChange()
        }

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
    }

    Label {
        id: swipeHint
        property real baseOpacity: 0.5
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(5)
        text: "《    " + i18n.tr("Unlock") + "    》"
        color: "white"
        font.weight: Font.Light

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
                if (root.dragOffset > 0) {
                    value = Qt.binding(function() { return greeter.width; })
                } else {
                    value = Qt.binding(function() { return -greeter.width; })
                }
            }

            __enabled = enabled;
        }

        property bool __enabled: false

        target: root
        when: __enabled
        property: "dragOffset"
    }

    hideAnimation: SequentialAnimation {
        id: hideAnimation
        objectName: "hideAnimation"
        StandardAnimation {
            id: hideTranslation
            property: "dragOffset"
            target: root
        }
        PropertyAction { target: root; property: "visible"; value: false }
        PropertyAction { target: positionLock; property: "enabled"; value: true }
    }

    showAnimation: SequentialAnimation {
        id: showAnimation
        objectName: "showAnimation"
        PropertyAction { target: root; property: "visible"; value: true }
        PropertyAction { target: positionLock; property: "enabled"; value: false }
        StandardAnimation {
            property: "dragOffset"
            target: root
            to: 0
            duration: UbuntuAnimation.FastDuration
        }
    }
}
