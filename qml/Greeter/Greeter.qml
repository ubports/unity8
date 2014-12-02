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

    property url background
    property bool loadContent: required

    // 1 when fully shown and 0 when fully hidden
    property real showProgress: MathUtils.clamp((width - Math.abs(x)) / width, 0, 1)

    showAnimation: StandardAnimation { property: "x"; to: 0; duration: UbuntuAnimation.FastDuration }
    hideAnimation: __leftHideAnimation

    property alias dragHandleWidth: dragHandle.width
    property alias model: greeterContentLoader.model
    property bool locked: true

    readonly property bool narrowMode: !multiUser && height > width
    readonly property bool multiUser: LightDM.Users.count > 1

    readonly property int currentIndex: greeterContentLoader.currentIndex

    property var __leftHideAnimation: StandardAnimation { property: "x"; to: -width }
    property var __rightHideAnimation: StandardAnimation { property: "x"; to: width }

    signal selected(int uid)
    signal unlocked(int uid)
    signal tease()

    function hideRight() {
        if (shown) {
            hideAnimation = __rightHideAnimation
            hide()
        }
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

    onRequiredChanged: {
        // Reset hide animation to default once we're finished with it
        if (required) {
            // Reset hide animation so that a hide() call is reliably left
            hideAnimation = __leftHideAnimation
        }
    }

    // Bi-directional revealer
    DraggingArea {
        id: dragHandle
        anchors.fill: parent
        enabled: (greeter.narrowMode || !greeter.locked) && greeter.enabled && greeter.shown
        orientation: Qt.Horizontal
        propagateComposedEvents: true

        Component.onCompleted: {
            // set evaluators to baseline of dragValue == 0
            leftEvaluator.reset()
            rightEvaluator.reset()
        }

        function maybeTease() {
            if (!greeter.locked || greeter.narrowMode)
                greeter.tease();
        }

        onClicked: maybeTease()
        onDragStart: maybeTease()
        onPressAndHold: {} // eat event, but no need to tease, as drag will cover it

        onDragEnd: {
            if (greeter.x > 0 && rightEvaluator.shouldAutoComplete()) {
                greeter.hideRight()
            } else if (greeter.x < 0 && leftEvaluator.shouldAutoComplete()) {
                greeter.hide();
            } else {
                greeter.show(); // undo drag
            }
        }

        onDragValueChanged: {
            // dragValue is kept as a "step" value since we do this x adjusting on the fly
            greeter.x += dragValue
        }

        EdgeDragEvaluator {
            id: rightEvaluator
            trackedPosition: dragHandle.dragValue + greeter.x
            maxDragDistance: parent.width
            direction: Direction.Rightwards
        }

        EdgeDragEvaluator {
            id: leftEvaluator
            trackedPosition: dragHandle.dragValue + greeter.x
            maxDragDistance: parent.width
            direction: Direction.Leftwards
        }
    }
    TouchGate {
        targetItem: dragHandle
        anchors.fill: targetItem
        enabled: targetItem.enabled
    }

    Rectangle {
        // While greeterContent is loading, and in case it's background fails to load
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
    }

    Loader {
        id: greeterContentLoader
        objectName: "greeterContentLoader"
        anchors.fill: parent
        property var model: LightDM.Users
        property int currentIndex: 0
        property var infographicModel: LightDM.Infographic
        readonly property int backgroundTopMargin: -greeter.y
        property bool everLoaded: false

        // We only want to be async after the first one, because during boot,
        // if we load async, the panel will appear a bit before the greeter
        // does.  We'd rather everything appear at once.  But other times,
        // we don't want to block handling power button presses on loading the
        // greeter.
        asynchronous: everLoaded

        source: loadContent ? "GreeterContent.qml" : ""

        onLoaded: {
            greeterContentLoader.item.selected(currentIndex);
            everLoaded = true;
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

    onTease: showLabelAnimation.start()

    Label {
        id: swipeHint
        visible: greeter.shown
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
        visible: parent.required
        fillMode: Image.Tile
        source: "../graphics/dropshadow_right.png"
    }

    // left side shadow
    Image {
        anchors.right: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: parent.required
        fillMode: Image.Tile
        source: "../graphics/dropshadow_left.png"
    }
}
