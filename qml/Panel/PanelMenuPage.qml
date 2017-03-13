/*
 * Copyright 2013-2016 Canonical Ltd.
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
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Unity.Indicators 0.1 as Indicators
import "../Components"
import "Indicators"

PageStack {
    id: root

    property var submenuIndex: undefined
    property QtObject menuModel: null
    property Component factory

    Connections {
        id: dynamicChanges
        target: root.menuModel
        property bool ready: false

        // fix async creation with signal from model before it's finished.
        onRowsInserted: {
            if (submenuIndex !== undefined && first <= submenuIndex) {
                reset(true);
            }
        }
        onRowsRemoved: {
            if (submenuIndex !== undefined && first <= submenuIndex) {
                reset(true);
            }
        }
        onModelReset: {
            if (root.submenuIndex !== undefined) {
                reset(true);
            }
        }
    }

    Component.onCompleted: {
        reset(true);
        dynamicChanges.ready = true;
    }

    function reset(clearModel) {
        if (clearModel) {
            clear();
            var model = submenuIndex == undefined ? menuModel : menuModel.submenu(submenuIndex)
            if (model) {
                push(pageComponent, { "menuModel": model });
            }
        } else if (root.currentPage) {
            root.currentPage.reset();
        }
    }

    Component {
        id: pageComponent
        Page {
            id: page

            property alias menuModel: listView.model
            property alias title: backLabel.title
            property bool isSubmenu: false

            function reset() {
                listView.positionViewAtBeginning();
            }

            property QtObject factory: root.factory.createObject(page, { menuModel: page.menuModel } )

            header: PageHeader {
                id: backLabel
                visible: page.isSubmenu
                leadingActionBar.actions: [
                    Action {
                        iconName: "back"
                        text: i18n.tr("Back")
                        onTriggered: {
                            root.pop();
                        }
                    }
                ]
            }

            ListView {
                id: listView
                objectName: "listView"

                anchors {
                    top: page.isSubmenu ? backLabel.bottom : parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: Qt.inputMethod.visible ? (Qt.inputMethod.keyboardRectangle.height - root.anchors.bottomMargin) : 0

                    Behavior on bottomMargin {
                        NumberAnimation {
                            duration: 175
                            easing.type: Easing.OutQuad
                        }
                    }
                    // TODO - does ever frame.
                    onBottomMarginChanged: {
                        listView.positionViewAtIndex(listView.currentIndex, ListView.End)
                    }
                }

                // Don't load all the delegates (only max of 3 pages worth -1/0/+1)
                cacheBuffer: Math.max(height * 3, units.gu(70))

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

                Connections {
                    target: listView.model ? listView.model : null
                    onRowsAboutToBeRemoved: {
                        // track current item deletion.
                        if (listView.selectedIndex >= first && listView.selectedIndex <= last) {
                            listView.selectedIndex = -1;
                        }
                    }
                }

                delegate: Loader {
                    id: loader
                    objectName: "menuItem" + index
                    width: ListView.view.width
                    visible: status == Loader.Ready

                    property int modelIndex: index
                    sourceComponent: page.factory.load(model)

                    onLoaded: {
                        if (item.hasOwnProperty("selected")) {
                            item.selected = listView.selectedIndex == index;
                        }
                        if (item.hasOwnProperty("menuSelected")) {
                            item.menuSelected.connect(function() { listView.selectedIndex = index; });
                        }
                        if (item.hasOwnProperty("menuDeselected")) {
                            item.menuDeselected.connect(function() { listView.selectedIndex = -1; });
                        }
                        if (item.hasOwnProperty("menuData")) {
                            item.menuData = Qt.binding(function() { return model; });
                        }
                        if (item.hasOwnProperty("menuIndex")) {
                            item.menuIndex = Qt.binding(function() { return modelIndex; });
                        }
                        if (item.hasOwnProperty("clicked")) {
                            item.clicked.connect(function() {
                                if (model.hasSubmenu) {
                                    page.menuModel.aboutToShow(modelIndex);
                                    root.push(pageComponent, {
                                             "isSubmenu": true,
                                             "title": model.label.replace(/_|&/, ""),
                                             "menuModel": page.menuModel.submenu(modelIndex)
                                    });
                                }
                            });
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
                        target: listView
                        onSelectedIndexChanged: {
                            if (loader.item && loader.item.hasOwnProperty("selected")) {
                                loader.item.selected = listView.selectedIndex == index;
                            }
                        }
                    }
                }
            }
        }
    }
}
