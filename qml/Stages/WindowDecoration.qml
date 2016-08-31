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
import "../Components"

MouseArea {
    id: root
    clip: true

    property Item target // appDelegate
    property alias title: titleLabel.text
    property alias maximizeButtonShown: buttons.maximizeButtonShown
    property bool active: false
    property alias overlayShown: buttons.overlayShown

    readonly property real buttonsWidth: buttons.width + row.spacing

    acceptedButtons: Qt.AllButtons // prevent leaking unhandled mouse events
    hoverEnabled: true

    signal closeClicked()
    signal minimizeClicked()
    signal maximizeClicked()
    signal maximizeHorizontallyClicked()
    signal maximizeVerticallyClicked()

    onDoubleClicked: {
        if (target.canBeMaximized && mouse.button == Qt.LeftButton) {
            root.maximizeClicked();
        }
    }

    // do not let unhandled wheel event pass thru the decoration
    onWheel: wheel.accepted = true;

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: -radius
        radius: units.gu(.5)
        color: theme.palette.normal.background
    }

    Row {
        id: row
        anchors {
            fill: parent
            leftMargin: overlayShown ? units.gu(5) : units.gu(1)
            rightMargin: units.gu(1)
            topMargin: units.gu(0.5)
            bottomMargin: units.gu(0.5)
        }
        Behavior on anchors.leftMargin {
            UbuntuNumberAnimation {}
        }

        spacing: units.gu(3)

        WindowControlButtons {
            id: buttons
            height: parent.height
            active: root.active
            onCloseClicked: root.closeClicked();
            onMinimizeClicked: root.minimizeClicked();
            onMaximizeClicked: root.maximizeClicked();
            onMaximizeHorizontallyClicked: if (root.target.canBeMaximizedHorizontally) root.maximizeHorizontallyClicked();
            onMaximizeVerticallyClicked: if (root.target.canBeMaximizedVertically) root.maximizeVerticallyClicked();
            closeButtonShown: root.target.application.appId !== "unity8-dash"
        }

        Label {
            id: titleLabel
            objectName: "windowDecorationTitle"
            color: root.active ? "white" : UbuntuColors.slate
            height: parent.height
            width: parent.width - buttons.width - parent.anchors.rightMargin - parent.anchors.leftMargin
            verticalAlignment: Text.AlignVCenter
            fontSize: "medium"
            font.weight: root.active ? Font.Light : Font.Medium
            elide: Text.ElideRight
            opacity: overlayShown ? 0 : 1
            visible: opacity != 0
            Behavior on opacity {
                UbuntuNumberAnimation {}
            }
        }
    }
}
