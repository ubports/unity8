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
import Ubuntu.Components 0.1
import Ubuntu.Gestures 0.1
import LightDM 0.1 as LightDM
import "../Components"

Showable {
    id: greeter
    enabled: shown
    created: greeterContentLoader.status == Loader.Ready && greeterContentLoader.item.ready

    property real dragHandleLeftMargin: 0

    property url background

    prepareToHide: function () {
        hideTranslation.to = greeter.x > 0 || d.forceRightOnNextHideAnimation ? greeter.width : -greeter.width;
        d.forceRightOnNextHideAnimation = false;
    }

    QtObject {
        id: d
        property bool forceRightOnNextHideAnimation: false
    }

    property bool loadContent: required

    // 1 when fully shown and 0 when fully hidden
    property real showProgress: visible ? MathUtils.clamp((width - Math.abs(x)) / width, 0, 1) : 0

    property alias model: greeterContentLoader.model
    property bool locked: true

    readonly property bool narrowMode: !multiUser && height > width
    readonly property bool multiUser: LightDM.Users.count > 1

    readonly property int currentIndex: greeterContentLoader.currentIndex

    signal selected(int uid)
    signal unlocked(int uid)
    signal tapped()

    function hideRight() {
        d.forceRightOnNextHideAnimation = true;
        hide();
    }

    function tryToUnlock() {
        if (created) {
            greeterContentLoader.item.tryToUnlock()
        }
    }

    function reset() {
        if (created) {
            greeterContentLoader.item.reset()
        }
    }

    // event eater
    // Nothing should leak to items behind the greeter
    MouseArea { anchors.fill: parent }

    Loader {
        id: greeterContentLoader
        objectName: "greeterContentLoader"
        anchors.fill: parent
        property var model: LightDM.Users
        property int currentIndex: 0
        property var infographicModel: LightDM.Infographic
        readonly property int backgroundTopMargin: -greeter.y

        source: loadContent ? "GreeterContent.qml" : ""

        onLoaded: {
            selected(currentIndex);
        }

        Connections {
            target: greeterContentLoader.item

            onSelected: {
                greeter.selected(uid);
                greeterContentLoader.currentIndex = uid;
            }
            onUnlocked: greeter.unlocked(uid);
        }
    }

    DragHandle {
        id: dragHandle
        anchors.fill: parent
        anchors.leftMargin: greeter.dragHandleLeftMargin
        enabled: (greeter.narrowMode || !greeter.locked) && greeter.enabled && greeter.shown
        direction: Direction.Horizontal

        onTapped: {
            greeter.tapped();
            showLabelAnimation.start();
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
                if (greeter.x > 0) {
                    value = Qt.binding(function() { return greeter.width; })
                } else {
                    value = Qt.binding(function() { return -greeter.width; })
                }
            }

            __enabled = enabled;
        }

        property bool __enabled: false

        target: greeter
        when: __enabled
        property: "x"
    }

    hideAnimation: SequentialAnimation {
        id: hideAnimation
        objectName: "hideAnimation"
        StandardAnimation {
            id: hideTranslation
            property: "x"
            target: greeter
        }
        PropertyAction { target: greeter; property: "visible"; value: false }
        PropertyAction { target: positionLock; property: "enabled"; value: true }
    }

    showAnimation: SequentialAnimation {
        id: showAnimation
        objectName: "showAnimation"
        PropertyAction { target: greeter; property: "visible"; value: true }
        PropertyAction { target: positionLock; property: "enabled"; value: false }
        StandardAnimation {
            property: "x"
            target: greeter
            to: 0
            duration: UbuntuAnimation.FastDuration
        }
    }
}
