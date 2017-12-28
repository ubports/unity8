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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Application 0.1
import "../Components"
import "../Components/PanelState"
import "../ApplicationMenus"

MouseArea {
    id: root

    property alias closeButtonVisible: buttons.closeButtonShown
    property alias title: titleLabel.text
    property alias maximizeButtonShown: buttons.maximizeButtonShown
    property alias minimizeButtonVisible: buttons.minimizeButtonVisible
    property bool active: false
    property alias overlayShown: buttons.overlayShown
    property var menu: undefined
    property bool enableMenus: true
    property bool windowMoving: false
    property alias windowControlButtonsVisible: buttons.visible

    readonly property real buttonsWidth: buttons.width + row.spacing

    acceptedButtons: Qt.AllButtons // prevent leaking unhandled mouse events
    hoverEnabled: true

    signal closeClicked()
    signal minimizeClicked()
    signal maximizeClicked()
    signal maximizeHorizontallyClicked()
    signal maximizeVerticallyClicked()

    signal pressedChangedEx(bool pressed, var pressedButtons, real mouseX, real mouseY)

    onDoubleClicked: {
        if (mouse.button == Qt.LeftButton) {
            root.maximizeClicked();
        }
    }

    // do not let unhandled wheel event pass thru the decoration
    onWheel: wheel.accepted = true;

    QtObject {
        id: priv
        property var menuBar: menuBarLoader.item

        property bool shouldShowMenus: root.enableMenus &&
                                       menuBar &&
                                       menuBar.valid &&
                                       (menuBar.showRequested || root.containsMouse)
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: units.gu(.5)
        color: theme.palette.normal.background
    }

    Rectangle {
        anchors {
            bottom: background.bottom
            left: parent.left
            right: parent.right
        }
        height: background.radius
        color: theme.palette.normal.background
    }

    RowLayout {
        id: row
        anchors {
            fill: parent
            leftMargin: overlayShown ? units.gu(5) : units.gu(1)
            rightMargin: units.gu(1)
        }
        Behavior on anchors.leftMargin {
            UbuntuNumberAnimation {}
        }

        spacing: units.gu(3)

        WindowControlButtons {
            id: buttons
            anchors {
                top: parent.top
                bottom: parent.bottom
                topMargin: units.gu(0.5)
                bottomMargin: units.gu(0.5)
            }
            active: root.active
            onCloseClicked: root.closeClicked();
            onMinimizeClicked: root.minimizeClicked();
            onMaximizeClicked: root.maximizeClicked();
            onMaximizeHorizontallyClicked: root.maximizeHorizontallyClicked();
            onMaximizeVerticallyClicked: root.maximizeVerticallyClicked();
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true

            Label {
                id: titleLabel
                objectName: "windowDecorationTitle"
                color: root.active ? "white" : UbuntuColors.slate
                height: parent.height
                width: parent.width
                verticalAlignment: Text.AlignVCenter
                fontSize: "medium"
                font.weight: root.active ? Font.Light : Font.Medium
                elide: Text.ElideRight
                opacity: overlayShown || menuBarLoader.visible ? 0 : 1
                visible: opacity != 0
                Behavior on opacity { UbuntuNumberAnimation {} }
            }

            Loader {
                id: menuBarLoader
                objectName: "menuBarLoader"
                anchors.bottom: parent.bottom
                height: parent.height
                width: parent.width
                active: root.menu !== undefined

                sourceComponent: MenuBar {
                    id: menuBar
                    height: menuBarLoader.height
                    enableKeyFilter: valid && root.active && root.enableMenus
                    unityMenuModel: root.menu
                    windowMoving: root.windowMoving

                    onPressed: root.onPressed(mouse)
                    onPressedChangedEx: root.pressedChangedEx(pressed, pressedButtons, mouseX, mouseY)
                    onPositionChanged: root.onPositionChanged(mouse)
                    onReleased: root.onReleased(mouse)
                    onDoubleClicked: root.onDoubleClicked(mouse)
                }

                opacity: (!overlayShown && priv.shouldShowMenus) || (active && priv.menuBar.valid && root.windowMoving) ? 1 : 0
                visible: opacity == 1
                Behavior on opacity { UbuntuNumberAnimation {} }
            }
        }
    }
}
