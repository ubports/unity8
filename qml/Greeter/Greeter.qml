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

    x: launcherOffsetProxy + dragOffset

    property url background
    property bool loadContent: required

    // How far to offset the top greeter layer during a launcher left-drag
    property real launcherOffset

    // 1 when fully shown and 0 when fully hidden
    property real showProgress: MathUtils.clamp((width - Math.abs(x)) / width, 0, 1)

    showAnimation: StandardAnimation { property: "dragOffset"; to: 0; duration: UbuntuAnimation.FastDuration }
    hideAnimation: __leftHideAnimation

    property alias dragHandleWidth: dragHandle.width
    property alias model: greeterContentLoader.model
    property bool locked: true

    readonly property bool narrowMode: !multiUser && height > width
    readonly property bool multiUser: LightDM.Users.count > 1

    readonly property int currentIndex: greeterContentLoader.currentIndex

    property var __leftHideAnimation: StandardAnimation { property: "dragOffset"; to: -width }
    property var __rightHideAnimation: StandardAnimation { property: "dragOffset"; to: width }

    property real dragOffset

    // We define a proxy and "is valid" property for launcherOffset because of
    // a quirk in Qml.  We only want this animation to fire if we are reset
    // back to zero (on a release of the drag).  But by defining a Behavior,
    // we delay the property from reaching zero until it's too late.  So we set
    // a proxy bound to launcherOffset, which lets us see the target value of
    // zero as we also slowly adjust the value down to zero.  But Qml will send
    // change notifications in declaration order.  So unless we define the
    // proxy first, we need a little "is valid" property defined above the
    // proxy, so we know when to enable the proxy behavior.  Phew!
    readonly property bool launcherOffsetValid: launcherOffset > 0
    property real launcherOffsetProxy: launcherOffset
    Behavior on launcherOffsetProxy {
        enabled: !launcherOffsetValid
        StandardAnimation {}
    }

    signal selected(int uid)
    signal unlocked(int uid)
    signal tease()
    signal sessionStarted()

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

    function login() {
        enabled = false;
        if (LightDM.Greeter.startSessionSync()) {
            sessionStarted();
        }
        enabled = true;
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
            if (greeter.dragOffset > 0 && rightEvaluator.shouldAutoComplete()) {
                greeter.hideRight()
            } else if (greeter.dragOffset < 0 && leftEvaluator.shouldAutoComplete()) {
                greeter.hide();
            } else {
                greeter.show(); // undo drag
            }
        }

        onDragValueChanged: {
            // dragValue is kept as a "step" value since we do this adjusting on the fly
            greeter.dragOffset += dragValue;
        }

        EdgeDragEvaluator {
            id: rightEvaluator
            trackedPosition: dragHandle.dragValue + greeter.dragOffset
            maxDragDistance: parent.width
            direction: Direction.Rightwards
        }

        EdgeDragEvaluator {
            id: leftEvaluator
            trackedPosition: dragHandle.dragValue + greeter.dragOffset
            maxDragDistance: parent.width
            direction: Direction.Leftwards
        }
    }
    TouchGate {
        targetItem: dragHandle
        anchors.fill: targetItem
        enabled: targetItem.enabled
    }

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
