/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import "../Components"

import Ubuntu.Components.Themes.Ambiance 1.3 as Ambiance

Item {
    id: root

    property color backgroundColor: d.undefinedColor
    property color headerColor: d.undefinedColor
    property color footerColor: d.undefinedColor
    property alias imageSource: overlaidImage.source
    property url icon
    property alias title: header.title
    property alias showHeader: header.visible

    QtObject {
        id: d

        // As specified in qtmir, it will set the color value to this for fields left undefined
        // This is also the default value of a color property in QML.
        readonly property color undefinedColor: "#00000000"

        readonly property color defaultBackgroundColor: header.visible ? theme.palette.normal.background : "black"

        // Splash screen that shows the application icon and splashTitle
        readonly property bool showIcon: overlaidImage.status == Image.Null && !root.showHeader
    }

    StyledItem {
        id: styledItem
        anchors.fill: parent

        // mimic API of toolkit's MainView component required by MainViewStyle
        property color backgroundColor: Qt.colorEqual(root.backgroundColor, d.undefinedColor) ? d.defaultBackgroundColor
                                                                                              : root.backgroundColor
        property color headerColor: Qt.colorEqual(root.headerColor, d.undefinedColor) ? styledItem.backgroundColor
                                                                                      : root.headerColor
        property color footerColor: Qt.colorEqual(root.footerColor, d.undefinedColor) ? styledItem.backgroundColor
                                                                                      : root.footerColor
        style: Theme.createStyleComponent("MainViewStyle.qml", styledItem)
    }

    PageHeader {
        id: header
        anchors { left: parent.left; right: parent.right }
        StyleHints {
            foregroundColor: styledItem.theme.palette.normal.backgroundText
            backgroundColor: "transparent"
            dividerColor: styledItem.theme.palette.normal.base
        }
    }

    Image {
        id: overlaidImage
        anchors.centerIn: parent
        anchors.verticalCenterOffset: header.visible ? header.height / 2 : 0
        sourceSize {
            width: root.width
            height: root.height
        }
        asynchronous: true
        cache: false
    }

    UbuntuShape {
        id: iconShape
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -units.gu(4)
        width: units.gu(8)
        height: units.gu(7.5)

        visible: d.showIcon

        radius: "medium"
        aspect: UbuntuShape.Flat
        sourceFillMode: Image.PreserveAspectCrop
        source: Image {
            id: iconImage
            sourceSize.width: iconShape.width
            sourceSize.height: iconShape.height
            source: d.showIcon ? root.icon : ""
        }
    }

    Label {
        id: titleLabel
        text: root.title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: iconShape.bottom
        anchors.topMargin: units.gu(2)
        fontSize: "large"

        color: styledItem.theme.palette.normal.backgroundText
        visible: d.showIcon
    }

    Timer {
        interval: 2000
        onTriggered: spinner.running = true
        running: true
    }

    ActivityIndicator {
        id: spinner
        anchors.centerIn: parent
        anchors.verticalCenterOffset: header.visible ? header.height / 2 : Math.max(titleLabel.y / 2, units.gu(8))
    }

    MouseArea {
        anchors.fill: parent
        enabled: parent.visible
        // absorb all mouse events
    }

    transitions: Transition {
        UbuntuNumberAnimation {}
    }
}
