/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import "../Components"

Item {
    id: root

    property real progress: 0
    property var scope: null
    property real scopeScale: 1
    property QtObject scopeStyle: QtObject {
        property string headerLogo: ""
        property color foreground: "white"
    }

    signal done()
    signal favoriteSelected(int index)
    signal allSelected(var scope)

    DashBackground {
        anchors.fill: parent
        Rectangle {
            color: "black"
            anchors.fill: parent
            opacity: 0.6
        }
    }

    Item {
        id: scopesOverviewContent
        x: previewListView.open ? -width : 0
        Behavior on x { UbuntuNumberAnimation { } }
        width: parent.width
        height: parent.height

        Item {
            id: topBar
            width: parent.width
            height: childrenRect.height

            y: {
                if (root.progress < 0.5) {
                    return -height;
                } else {
                    return -height + (root.progress - 0.5) * height * 2;
                }
            }

            PageHeader {
                id: pageHeader
                width: parent.width
                clip: true
                title: i18n.tr("Manage Dash")
                scopeStyle: root.scopeStyle
                showSignatureLine: false
                searchEntryEnabled: true
    //             searchInProgress: scope ? scope.searchInProgress : false
            }

            Item {
                id: tabBarHolder

                property int currentTab: 0

                anchors {
                    left: parent.left
                    right: parent.right
                    top: pageHeader.bottom
                    margins: units.gu(2)
                }
                height: units.gu(4)

                AbstractButton {
                    id: tab1
                    height: parent.height
                    width: parent.width / 2
                    Rectangle {
                        anchors.fill: parent
                        color: tabBarHolder.currentTab == 0 ? "white" : "transparent"
                        radius: units.dp(10)
                    }
                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Favourites")
                        color: tabBarHolder.currentTab == 0 ? "black" : "white"
                    }
                    onClicked: tabBarHolder.currentTab = 0
                }
                AbstractButton {
                    id: tab2
                    x: width
                    height: parent.height
                    width: parent.width / 2
                    Rectangle {
                        anchors.fill: parent
                        color: tabBarHolder.currentTab == 1 ? "white" : "transparent"
                        radius: units.dp(10)
                    }
                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("All")
                        color: tabBarHolder.currentTab == 1 ? "black" : "white"
                    }
                    onClicked: tabBarHolder.currentTab = 1
                }
                Rectangle {
                    id: centerPiece
                    width: units.dp(10)
                    height: parent.height
                    color: "white"
                    x: tabBarHolder.currentTab == 1 ? tab2.x : tab2.x - width
                }
                Rectangle {
                    id: border
                    anchors.fill: parent
                    radius: units.dp(10)
                    color: "transparent"
                    border.color: centerPiece.color
                    border.width: units.dp(1)
                }
            }
        }

        Repeater {
            id: middleItems
            model: scope ? scope.categories : null
            delegate: Loader {
                id: loader

                height: {
                    if (index == 0) {
                        return parent.height;
                    } else {
                        return parent.height - topBar.height - units.gu(2)
                    }
                }
                width: {
                    if (index == 0) {
                        return parent.width / scopeScale
                    } else {
                        return parent.width
                    }
                }
                x: {
                    if (index == 0) {
                        return (root.width - width) / 2;
                    } else {
                        return 0;
                    }
                }
                anchors {
                    bottom: parent.bottom
                }

                scale: index == 0 ? scopeScale : 1

                opacity: tabBarHolder.currentTab == index ? 1 : 0
                Behavior on opacity { UbuntuNumberAnimation { } }
                enabled: opacity == 1

                clip: index == 1

                CardTool {
                    id: cardTool
                    objectName: "cardTool"
                    count: results.count
                    template: model.renderer
                    components: model.components
                    viewWidth: parent.width
                }

                source: {
                    if (index == 0) return "ScopesOverviewFavourites.qml";
                    else if (index == 1) return "ScopesOverviewAll.qml";
                    else {
                        console.log("WARNING: ScopesOverview scope is not supposed to have more than 2 categories");
                        return "";
                    }
                }

                onLoaded: {
                    item.model = Qt.binding(function() { return results })
                    item.cardTool = cardTool;
                    if (index == 0) {
                        item.scopeWidth = root.width;
                        item.scopeHeight = root.height;
                    } else if (index == 1) {
                        item.extraHeight = bottomBar.height;
                    }
                }

                Connections {
                        target: loader.item
                        onClicked: {
                            if (tabBarHolder.currentTab == 0) {
                                root.favoriteSelected(index)
                            } else {
                                // This will result in an openScope
                                // that we handle in Dash.qml
                                scope.activate(result)
                            }
                        }
                        onPressAndHold: {
                            previewListView.model = target.model;
                            previewListView.currentIndex = -1
                            previewListView.currentIndex = index;
                            previewListView.open = true
                        }
                }
            }
        }

        Rectangle {
            id: bottomBar
            color: "black"
            height: units.gu(6)
            width: parent.width
            opacity: 0.4
            y: {
                if (root.progress < 0.5) {
                    return parent.height;
                } else {
                    return parent.height - (root.progress - 0.5) * height * 2;
                }
            }

            AbstractButton {
                width: Math.max(label.width + units.gu(2), units.gu(10))
                height: units.gu(4)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    anchors.fill: parent
                    border.color: "white"
                    border.width: units.dp(1)
                    radius: units.dp(10)
                    color: parent.pressed ? "gray" : "transparent"
                }
                Label {
                    id: label
                    anchors.centerIn: parent
                    text: i18n.tr("Done")
                    color: parent.pressed ? "black" : "white"
                }
                onClicked: {
                    root.done();
                    tabBarHolder.currentTab = 0;
                }
            }
        }
    }

    PreviewListView {
        id: previewListView
        objectName: "scopesOverviewPreviewListView"
        scope: root.scope
        scopeStyle: root.scopeStyle
        visible: x != width
        width: parent.width
        height: parent.height
        anchors.left: scopesOverviewContent.right
    }
}