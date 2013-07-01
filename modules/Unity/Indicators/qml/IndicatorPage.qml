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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1 as Components

IndicatorBase {
    id: main

    //const
    property alias emptyText: emptyLabel.text
    property alias highlightFollowsCurrentItem : mainMenu.highlightFollowsCurrentItem
    property bool __active: false

    ListView {
        id: mainMenu

        property int visibleItems: 0

        model: proxyModel
        anchors {
            fill: parent
            bottomMargin: Qt.inputMethod.visible ? (Qt.inputMethod.keyboardRectangle.height - main.anchors.bottomMargin) : 0

            Behavior on bottomMargin {
                NumberAnimation {
                    duration: 175
                    easing.type: Easing.OutQuad
                }
            }
            // TODO - does ever frame.
            onBottomMarginChanged: {
                mainMenu.positionViewAtIndex(mainMenu.currentIndex, ListView.End)
            }
        }

        // Ensure all delegates are cached in order to improve smoothness of scrolling
        cacheBuffer: 10000

        // Only allow flicking if the content doesn't fit on the page
        interactive: contentHeight > height

        currentIndex: -1
        delegate: Item {
            id: item
            property bool ready: false
            property alias empty: factory.empty

            anchors {
                left: parent.left
                right: parent.right
            }
            height: div.height + factory.implicitHeight
            visible: height > 0

            Component.onCompleted: {
                if (!item.empty) {
                    mainMenu.visibleItems += 1;
                }
                ready = true;
            }
            Component.onDestruction: {
                if (!item.empty) {
                    mainMenu.visibleItems -= 1;
                }
                ready = false;
            }

            onEmptyChanged: {
                if (!ready) {
                    return;
                }
                if (empty) {
                    mainMenu.visibleItems -= 1;
                } else {
                    mainMenu.visibleItems += 1;
                }
            }

            ListView.onRemove: {
                if (!highlightFollowsCurrentItem) {
                    mainMenu.currentIndex = -1;
                }
            }

            Column {
                id: contents

                anchors.fill: parent

                DivMenuItem {
                    id: div

                    anchors.left: parent.left
                    anchors.right: parent.right
                    // only visible if is a root or a section header element and the factory is visible
                    height: {
                        // skipe first item
                        if (item.y == 0) {
                            return 0;
                        }
                        if (hasSection || ((depth == 0) && (!factory.empty))) {
                            return implicitHeight;
                        } else {
                            return 0;
                        }
                    }
                }

                MenuItemFactory {
                    id: factory

                    actionGroup: main.actionGroup
                    isCurrentItem: item.ListView.isCurrentItem
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    menu: model

                    Connections {
                        target : factory
                        onActivated: item.ListView.view.currentIndex = index
                        onDeactivated: item.ListView.view.currentIndex = -1
                    }
                }
            }
        }
    }

    Components.Label {
        id: emptyLabel
        visible: (mainMenu.visibleItems === 0)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: units.gu(2)
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        //style
        color: "#e8e1d0"
        fontSize: "medium"

        text: "Empty!"
    }

    function start()
    {
        reset()
        if (!__active) {
            proxyModel.start();
            actionGroup.start();
            __active = true;
        }
    }

    function stop()
    {
        if (__active) {
            __active = false;
            proxyModel.stop();
            actionGroup.stop();
        }
    }

    function reset()
    {
        mainMenu.currentIndex = -1;
        mainMenu.positionViewAtBeginning();
    }

    Component.onCompleted: {
        if ((busType != 0) && (busName != "") && (deviceMenuObjectPath != "")) {
            start();
        }
    }
}
