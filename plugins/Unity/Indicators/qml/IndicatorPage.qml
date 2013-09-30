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
import Unity.Indicators 0.1 as Indicators

IndicatorBase {
    id: main

    //const
    property bool contentActive: false
    property string title: rootActionState.title
    property alias emptyText: emptyLabel.text
    property alias highlightFollowsCurrentItem : mainMenu.highlightFollowsCurrentItem

    Indicators.UnityMenuModelStack {
        id: menuStack
        head: contentActive ? main.menuModel : null
    }

    ListView {
        id: mainMenu
        model: menuStack.tail ? menuStack.tail : null

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

        property int selectedIndex: -1
        property bool blockCurrentIndexChange: false
        // for count = 0
        onCountChanged: {
            if (count == 0 && selectedIndex != -1) {
                selectedIndex = -1;
            }
        }
        // for highlight following
        onSelectedIndexChanged: {
            if (currentIndex != selectedIndex) {
                var blocked = blockCurrentIndexChange;
                blockCurrentIndexChange = true;

                currentIndex = selectedIndex;

                blockCurrentIndexChange = blocked;
            }
        }
        // for item addition/removal
        onCurrentIndexChanged: {
            if (!blockCurrentIndexChange) {
                if (selectedIndex != -1 && selectedIndex != currentIndex) {
                    selectedIndex = currentIndex;
                }
            }
        }

        delegate: Item {
            id: menuDelegate

            anchors {
                left: parent.left
                right: parent.right
            }
            height: loader.height
            visible: height > 0

            Loader {
                id: loader
                asynchronous: true

                property int modelIndex: index

                anchors {
                    left: parent.left
                    right: parent.right
                }

                sourceComponent: factory.load(model)

                onLoaded: {
                    if (model.type === rootMenuType) {
                        menuStack.push(mainMenu.model.submenu(index));
                    }

                    if (item.hasOwnProperty("menuSelected")) {
                        item.menuSelected = Qt.binding(function() { return mainMenu.selectedIndex == index; });
                        item.selectMenu.connect(function() { mainMenu.selectedIndex = index; });
                        item.deselectMenu.connect(function() { mainMenu.selectedIndex = -1; });
                    }
                    if (item.hasOwnProperty("menu")) {
                        item.menu = Qt.binding(function() { return model; });
                    }
                }

                Binding {
                    target: item ? item : null
                    property: "objectName"
                    value: model.action
                }
            }
        }
    }

    MenuItemFactory {
        id: factory
        model: mainMenu.model
    }

    Components.Label {
        id: emptyLabel
        visible: mainMenu.count == 0
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
        if (!contentActive) {
            contentActive = true;
        }
    }

    function stop()
    {
        if (contentActive) {
            contentActive = false;
        }
    }

    function reset()
    {
        mainMenu.selectedIndex = -1;
        mainMenu.positionViewAtBeginning();
    }
}
