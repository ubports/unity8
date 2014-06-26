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

        property var rootMenu: null

        onTailChanged: {
            if (!tail) {
                rootMenu = null;
            } else if (rootMenu != tail) {
                if (tail.get(0, "type") === rootMenuType) {
                    rootMenu = menuStack.tail.submenu(0);
                    push(rootMenu, 0);
                } else {
                    rootMenu = null;
                }
            }
        }
    }

    Connections {
        target: menuStack.tail
        onRowsInserted: {
            if (menuStack.rootMenu !== menuStack.tail && menuStack.tail.get(0, "type") === rootMenuType) {
                menuStack.rootMenu = menuStack.tail.submenu(0);
                menuStack.push(menuStack.rootMenu, 0);
            }
        }
        onModelReset: {
            if (menuStack.rootMenu !== menuStack.tail && menuStack.tail.get(0, "type") === rootMenuType) {
                menuStack.rootMenu = menuStack.tail.submenu(0);
                menuStack.push(menuStack.rootMenu, 0);
            }
        }
    }

    ListView {
        id: mainMenu
        objectName: "mainMenu"
        model: menuStack.rootMenu

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

        delegate: Loader {
            id: loader
            objectName: "menuItem" + index
            asynchronous: false
            visible: height > 0

            property int modelIndex: index

            anchors {
                left: parent.left
                right: parent.right
            }

            sourceComponent: factory.load(model)

            onLoaded: {
                if (item.hasOwnProperty("selected")) {
                    item.selected = mainMenu.selectedIndex == index;
                }
                if (item.hasOwnProperty("menuSelected")) {
                    item.menuSelected.connect(function() { mainMenu.selectedIndex = index; });
                }
                if (item.hasOwnProperty("menuDeselected")) {
                    item.menuDeselected.connect(function() { mainMenu.selectedIndex = -1; });
                }
                if (item.hasOwnProperty("menuData")) {
                    item.menuData = Qt.binding(function() { return model; });
                }
                if (item.hasOwnProperty("menuIndex")) {
                    item.menuIndex = Qt.binding(function() { return modelIndex; });
                }
            }

            Binding {
                target: item ? item : null
                property: "objectName"
                value: model.action
            }

            // TODO: Fixes lp#1243146
            // This is a workaround for a Qt bug. https://bugreports.qt-project.org/browse/QTBUG-34351
            Connections {
                target: mainMenu
                onSelectedIndexChanged: {
                    if (loader.item && loader.item.hasOwnProperty("selected")) {
                        loader.item.selected = mainMenu.selectedIndex == index;
                    }
                }
            }
        }
    }

    MenuItemFactory {
        id: factory
        menuModel: mainMenu.model ? mainMenu.model : null
    }

    Components.Label {
        id: emptyLabel
        objectName: "emptyLabel"
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
