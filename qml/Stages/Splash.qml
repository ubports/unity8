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

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Themes 0.1
import "../Components"

StyledItem {
    id: root

    property string title: ""
    property url image: ""
    property bool showHeader: true
    // mimic API of toolkit's MainView component required by MainViewStyle
    property color backgroundColor: theme.palette.normal.background
    property color headerColor: backgroundColor
    property color footerColor: backgroundColor

    // FIXME: fake a Theme object as to expose the Palette corresponding to the backgroundColor (see MainViewStyle.qml)
    property var theme: QtObject {
        property string name: "Ambiance"
        property Palette palette: paletteLoader.item
    }

    Loader {
        id: paletteLoader
        source: "%1Palette.qml".arg(theme.name)
    }

    // FIXME: should instead use to be created API from toolkit
    // style: theme.createStyleComponent("MainViewStyle.qml", root)
    style: Component { MainViewStyle {theme: root.theme} }

    StyledItem {
        id: header
        anchors {
            left: parent.left
            right: parent.right
        }

        visible: root.showHeader

        // mimic API of toolkit's AppHeader component required by PageHeadStyle
        property Item pageStack
        property Item contents
        property string title: root.title
        property var tabsModel
        property var config: QtObject {
            property color foregroundColor: theme.palette.selected.backgroundText
            property var sections
        }

        // FIXME: should instead use to be created API from toolkit:
        // style: theme.createStyleComponent("PageHeadStyle.qml", header)
        style: Component { PageHeadStyle {theme: root.theme} }
    }

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.showHeader ? header.height / 2 : 0
        sourceSize {
            width: 1024
            height: 1024
        }
        source: root.image
    }

    ActivityIndicator {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.showHeader ? header.height / 2 : 0
        running: root.image === ""
    }

    MouseArea {
        anchors.fill: parent
        enabled: parent.visible
        // absorb all mouse events
    }
}
