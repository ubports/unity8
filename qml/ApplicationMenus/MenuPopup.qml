/*
 * Copyright 2016 Canonical Ltd.
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
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import "../Components"

UbuntuShape {
    id: root
    objectName: "menu"
    backgroundColor: theme.palette.normal.overlay

    property alias unityMenuModel: listView.model

    readonly property real __ajustedMinimumHeight: {
        if (listView.contentHeight > __minimumHeight) {
            return units.gu(30);
        }
        return Math.max(listView.contentHeight, units.gu(2));
    }

    readonly property real __minimumWidth: units.gu(20)
    readonly property real __minimumHeight: units.gu(30)
    readonly property real __maximumWidth: Screen.width * 0.7
    readonly property real __maximumHeight: Screen.height * 0.7

    function show() {
        visible = true;
        focusScope.forceActiveFocus();
    }

    function hide() {
        visible = false;
        d.currentItem = null;
    }

    function select(index) {
        d.select(index)
    }

    function reset() {
        d.currentItem = null;
        dismiss();
    }

    function dismiss() {
        d.dismissAll();
    }

    implicitWidth: container.width
    implicitHeight: MathUtils.clamp(listView.contentHeight, __ajustedMinimumHeight, __maximumHeight)

    MenuNavigator {
        id: d
        objectName: "d"
        itemView: listView

        property Item currentItem: null
        property Item hoveredItem: null
        readonly property int currentIndex: currentItem ? currentItem.__ownIndex : -1

        signal dismissAll()

        onCurrentItemChanged: {
            if (currentItem) {
                currentItem.item.forceActiveFocus();
            } else {
                hoveredItem = null;
            }
        }

        onSelect: {
            currentItem = listView.itemAt(index);
        }
    }

    Item {
        id: focusScope
        anchors.fill: parent
        focus: visible

        Keys.onUpPressed: d.selectPrevious(d.currentIndex)
        Keys.onDownPressed: d.selectNext(d.currentIndex)
        Keys.onRightPressed: {
            // Don't let right keypresses fall through if the current item has a visible popup.
            if (!d.currentItem || !d.currentItem.popup || !d.currentItem.popup.visible) {
                event.accepted = false;
            }
        }

        ColumnLayout {
            id: container
            objectName: "container"

            width: listView.contentWidth
            height: parent.height
            spacing: 0

            // FIXME use ListView.header - tried but was flaky with positionViewAtIndex.
            Item {
                Layout.fillWidth: true;
                Layout.maximumHeight: units.gu(3)
                Layout.minimumHeight: units.gu(3)
                visible: listView.contentHeight > root.height
                enabled: !listView.atYBeginning

                Rectangle {
                    color: enabled ? theme.palette.normal.overlayText :
                        theme.palette.disabled.overlayText
                    height: units.dp(1)
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2)
                    height: units.gu(2)
                    name: "up"
                    color: enabled ? theme.palette.normal.overlayText :
                                     theme.palette.disabled.overlayText
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        var index = listView.indexAt(0, listView.contentY);
                        listView.positionViewAtIndex(index-1, ListView.Beginning);
                    }
                }
            }

            ListView {
                id: listView
                objectName: "listView"
                Layout.fillHeight: true
                Layout.fillWidth: true
                contentWidth: MathUtils.clamp(contentItem.childrenRect.width,
                                              __minimumWidth,
                                              __maximumWidth)

                orientation: Qt.Vertical
                interactive: contentHeight > height
                clip: interactive
                highlightFollowsCurrentItem: false

                highlight: Rectangle {
                    color: "transparent"
                    border.width: units.dp(1)
                    border.color: UbuntuColors.orange
                    z: 1

                    width: listView.width
                    height:  d.currentItem ? d.currentItem.height : 0
                    y:  d.currentItem ? d.currentItem.y : 0
                    visible: d.currentItem
                }

                function itemAt(index) {
                    if (index > count || index < 0) return null;
                    currentIndex = index;
                    return currentItem;
                }

                MouseArea {
                    id: menuMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    z: -1

                    onPositionChanged: updateCurrentItemFromPosition(mouse)

                    function updateCurrentItemFromPosition(point) {
                        var pos = mapToItem(listView.contentItem, point.x, point.y);

                        if (!d.hoveredItem || !d.currentItem ||
                                !d.hoveredItem.contains(Qt.point(pos.x - d.currentItem.x, pos.y - d.currentItem.y))) {
                            d.hoveredItem = listView.itemAt(listView.indexAt(pos.x, pos.y));
                            if (!d.hoveredItem || !d.hoveredItem.enabled)
                                return false;
                            d.currentItem = d.hoveredItem;
                        }
                        return true;
                    }
                }

                ActionContext {
                    id: menuBarContext
                    objectName: "menuContext"
                    active: {
                        if (!root.visible) return false;
                        if (d.currentItem && d.currentItem.popup && d.currentItem.popup.visible) {
                            return false;
                        }
                        return true;
                    }
                }

                delegate: Loader {
                    id: loader
                    objectName: root.objectName + "-item" + __ownIndex

                    property int __ownIndex: index

                    width: root.width
                    enabled: model.isSeparator ? false : model.sensitive

                    sourceComponent: {
                        if (model.isSeparator) {
                            return separatorComponent;
                        }
                        return menuItemComponent;
                    }

                    property Item popup: null

                    Component {
                        id: menuItemComponent
                        MenuItem {
                            id: menuItem
                            menuData: model
                            objectName: loader.objectName + "-actionItem"

                            action.onTriggered: {
                                d.currentItem = loader;

                                if (hasSubmenu) {
                                    if (!popup) {
                                        var model = root.unityMenuModel.submenu(__ownIndex);
                                        popup = submenuComponent.createObject(focusScope, {
                                                                                  objectName: loader.objectName + "-",
                                                                                  unityMenuModel: model,
                                                                                  x: Qt.binding(function() { return root.width }),
                                                                                  y: Qt.binding(function() { return loader.y })
                                                                              });
                                    } else if (popup) {
                                        popup.visible = true;
                                    }
                                    popup.retreat.connect(function() {
                                        popup.destroy();
                                        popup = null;
                                        menuItem.forceActiveFocus();
                                    })
                                } else {
                                    root.unityMenuModel.activate(__ownIndex);
                                }
                            }

                            Connections {
                                target: d
                                onCurrentIndexChanged: {
                                    if (popup && d.currentIndex != __ownIndex) {
                                        popup.visible = false;
                                    }
                                }
                                onDismissAll: {
                                    if (popup) {
                                        popup.destroy();
                                        popup = null;
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: separatorComponent
                        ListItems.ThinDivider {
                            objectName: loader.objectName + "-separator"
                        }
                    }
                }
            } // ListView

            // FIXME use ListView.footer - tried but was flaky with positionViewAtIndex.
            Item {
                Layout.fillWidth: true;
                Layout.maximumHeight: units.gu(3)
                Layout.minimumHeight: units.gu(3)
                visible: listView.contentHeight > root.height
                enabled: !listView.atYEnd

                Rectangle {
                    color: enabled ? theme.palette.normal.overlayText :
                                     theme.palette.disabled.overlayText
                    height: units.dp(1)
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2)
                    height: units.gu(2)
                    name: "down"
                    color: enabled ? theme.palette.normal.overlayText :
                                     theme.palette.disabled.overlayText
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        var index = listView.indexAt(0, listView.contentY);
                        listView.positionViewAtIndex(index+1, ListView.Beginning);
                    }
                }
            }
        } // Column

        Component {
            id: submenuComponent
            Loader {
                id: submenuLoader
                source: "MenuPopup.qml"

                property var unityMenuModel: null
                signal retreat()

                Binding {
                    target: item
                    property: "unityMenuModel"
                    value: submenuLoader.unityMenuModel
                }

                Binding {
                    target: item
                    property: "objectName"
                    value: submenuLoader.objectName + "menu"
                }

                Keys.onLeftPressed: retreat()

                Component.onCompleted: item.select(0);
                onVisibleChanged: if (visible) { item.select(0); }
            }
        }
    }
}
