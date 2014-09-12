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

import Ubuntu.Components.Themes.Ambiance 1.1 as Ambiance

Item {
    id: root

    property color backgroundColor: d.undefinedColor
    property color headerColor: d.undefinedColor
    property color footerColor: d.undefinedColor
    property alias imageSource: overlaidImage.source
    property alias title: header.title
    property alias showHeader: header.visible

    Ambiance.Palette {
        id: ambiancePalette
    }

    QtObject {
        id: d

        // As specified in qtmir, it will set the color value to this for fields left undefined
        // This is also the default value of a color property in QML.
        readonly property color undefinedColor: "#00000000"

        readonly property color defaultBackgroundColor: ambiancePalette.normal.background
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

        // FIXME: fake a Theme object as to expose the Palette corresponding to the backgroundColor (see MainViewStyle.qml)
        property var theme: QtObject {
            property string name
            property Palette palette: Qt.createQmlObject("import QtQuick 2.2;\
                                                          import Ubuntu.Components.Themes.%1 1.1;\
                                                          Palette {}".arg(styledItem.theme.name),
                                                         styledItem, "dynamicPalette");
        }

        // FIXME: should instead use future toolkit API:
        // style: theme.createStyleComponent("MainViewStyle.qml", styledItem)
        style: Component { MainViewStyle {theme: styledItem.theme} }
    }

    StyledItem {
        id: header
        anchors {
            left: parent.left
            right: parent.right
        }

        // mimic API of toolkit's AppHeader component required by PageHeadStyle
        property Item pageStack
        property Item contents
        property string title
        property var tabsModel
        property var config: QtObject {
            property color foregroundColor: styledItem.theme.palette.selected.backgroundText
            property var sections: QtObject {}
        }

        // FIXME: should instead use future toolkit API:
        // style: theme.createStyleComponent("PageHeadStyle.qml", header)
        style: Component { PageHeadStyle {theme: styledItem.theme} }
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

    ActivityIndicator {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: header.visible ? header.height / 2 : 0
        running: overlaidImage.status == Image.Error || overlaidImage.status == Image.Null
    }

    MouseArea {
        anchors.fill: parent
        enabled: parent.visible
        // absorb all mouse events
    }
}
