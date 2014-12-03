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

Item {
    id: root
    anchors.fill: parent

    property bool ready: background.source == "" || background.status == Image.Ready || background.status == Image.Error

    signal selected(int uid)
    signal unlocked(int uid)
    signal tease()

    function tryToUnlock() {
        if (loginLoader.item) {
            loginLoader.item.tryToUnlock()
        }
    }

    function reset() {
        if (loginLoader.item) {
            loginLoader.item.reset()
        }
    }

    onTease: showLabelAnimation.start()

    // Bi-directional revealer
    DraggingArea {
        id: dragHandle
        anchors.fill: parent
        enabled: greeter.narrowMode || !greeter.locked
        orientation: Qt.Horizontal
        propagateComposedEvents: true

        Component.onCompleted: {
            // set evaluators to baseline of dragValue == 0
            leftEvaluator.reset();
            rightEvaluator.reset();
        }

        function maybeTease() {
            if (!greeter.locked || greeter.narrowMode) {
                root.tease();
            }
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
            maxDragDistance: root.width
            direction: Direction.Rightwards
        }

        EdgeDragEvaluator {
            id: leftEvaluator
            trackedPosition: dragHandle.dragValue + greeter.dragOffset
            maxDragDistance: root.width
            direction: Direction.Leftwards
        }
    }

    TouchGate {
        targetItem: dragHandle
        anchors.fill: targetItem
        enabled: targetItem.enabled
    }

    Rectangle {
        // In case background fails to load
        id: backgroundBackup
        anchors.fill: parent
        color: "black"
    }

    CrossFadeImage {
        id: background
        objectName: "greeterBackground"
        anchors {
            fill: parent
            topMargin: backgroundTopMargin
        }
        fillMode: Image.PreserveAspectCrop
        // Limit how much memory we'll reserve for this image
        sourceSize.height: height
        sourceSize.width: width
        source: greeter.background
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }

    Loader {
        id: loginLoader
        objectName: "loginLoader"
        anchors {
            left: parent.left
            leftMargin: Math.min(parent.width * 0.16, units.gu(20))
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(29)
        height: parent.height

        // TODO: Once we have a system API for determining which mode we are
        // in, tablet/phone/desktop, that should be used instead of narrowMode.
        source: greeter.narrowMode ? "" : "LoginList.qml"

        onLoaded: {
            item.currentIndex = greeterContentLoader.currentIndex;
        }

        Binding {
            target: loginLoader.item
            property: "model"
            value: greeterContentLoader.model
        }

        Connections {
            target: loginLoader.item

            onSelected: {
                root.selected(uid);
            }

            onUnlocked: {
                root.unlocked(uid);
            }

            onCurrentIndexChanged: {
                if (greeterContentLoader.currentIndex !== loginLoader.item.currentIndex) {
                    greeterContentLoader.currentIndex = loginLoader.item.currentIndex;
                }
            }
        }
    }

    Infographics {
        id: infographics
        objectName: "infographics"
        height: narrowMode ? parent.height : 0.75 * parent.height
        model: greeterContentLoader.infographicModel

        property string selectedUser
        property string infographicUser: AccountsService.statsWelcomeScreen ? selectedUser : ""
        onInfographicUserChanged: greeterContentLoader.infographicModel.username = infographicUser

        Component.onCompleted: {
            selectedUser = greeterContentLoader.model.data(greeterContentLoader.currentIndex, LightDM.UserRoles.NameRole)
            greeterContentLoader.infographicModel.username = infographicUser
            greeterContentLoader.infographicModel.readyForDataChange()
        }

        Connections {
            target: root
            onSelected: infographics.selectedUser = greeterContentLoader.model.data(uid, LightDM.UserRoles.NameRole)
        }

        Connections {
            target: i18n
            onLanguageChanged: greeterContentLoader.infographicModel.readyForDataChange()
        }

        anchors {
            verticalCenter: parent.verticalCenter
            left: narrowMode ? root.left : loginLoader.right
            right: root.right
        }
    }

    Clock {
        id: clock
        visible: narrowMode

        anchors {
            top: parent.top
            topMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
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
}
