/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: heroMessageHeader

    property alias avatar: avatarImage.source
    property alias icon: iconImage.source
    property alias appIcon: appIconImage.source
    property alias titleText: __titleText
    property alias subtitleText: __subtitleText
    property alias bodyText: __bodyText
    property real bodyBottom: bodyText.y + bodyText.height

    signal appIconClicked()

    height: units.gu(9)

    UbuntuShape {
        id: avatarImageContainer
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
        }
        height: units.gu(6)
        width: units.gu(6)
        image: Image {
            id: avatarImage
            fillMode: Image.PreserveAspectFit
        }
    }

    Image {
        id: iconImage
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            left: avatarImageContainer.right
            leftMargin: units.gu(1)
        }
        height: units.gu(1.5)
        width: units.gu(2)
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignBottom
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: __titleText
        anchors {
            baseline: iconImage.bottom
            left: iconImage.right
            leftMargin: units.gu(1)
            right: __appIcon.left
            rightMargin: units.gu(2)
        }
        elide: Text.ElideRight
        color: "#e8e1d0"
        font.weight: Font.DemiBold
        fontSize: "medium"
    }

    Label {
        id: __subtitleText
        anchors {
            baseline: __titleText.baseline
            baselineOffset: units.gu(2.5)
            left: __titleText.left
            right: __titleText.right
        }
        elide: Text.ElideRight
        color: "#8f8f88"
        fontSize: "small"
    }

    Label {
        id: __bodyText
        anchors {
            baseline: __subtitleText.baseline
            baselineOffset: units.gu(2.5)
            left: __titleText.left
            right: parent.right
            rightMargin: units.gu(2)
        }
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        color: "#e8e1d0"
        fontSize: "small"
    }

    Item {
        id: __appIcon
        width: units.gu(7)
        height: units.gu(7)
        anchors {
            top: parent.top
            right: parent.right
        }
        opacity: 0.0
        enabled: heroMessageHeader.state === "expanded"

        Image {
            id: appIconImage
            height: width
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(2)
                topMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            onClicked: heroMessageHeader.appIconClicked()
        }
    }

    states: State {
        name: "expanded"

        PropertyChanges {
            target: __appIcon
            opacity: 1.0
        }
    }

    transitions: Transition {
        NumberAnimation {
            property: "opacity"
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
