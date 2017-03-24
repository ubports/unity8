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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import "../Components"
import "../Components/PanelState"
import "."

UbuntuShape {
    id: root
    objectName: "menu"
    backgroundColor: theme.palette.normal.overlay

    signal childActivated()

    // true for submenus that need to show on the other side of their parent
    // if they don't fit when growing right
    property bool substractWidth: false

    property bool selectFirstOnCountChange: true

    property real desiredX
    x: {
        var dummy = visible; // force recalc when shown/hidden
        var parentTopLeft = parent.mapToItem(null, 0, 0);
        var farX = ApplicationMenusLimits.screenWidth;
        if (parentTopLeft.x + width + desiredX <= farX) {
            return desiredX;
        } else {
            if (substractWidth) {
                return -width;
            } else {
                return farX - parentTopLeft.x - width;
            }
        }
    }

    property real desiredY
    y: {
        var dummy = visible; // force recalc when shown/hidden
        var parentTopLeft = parent.mapToItem(null, 0, 0);
        var bottomY = ApplicationMenusLimits.screenHeight;
        if (parentTopLeft.y + height + desiredY <= bottomY) {
            return desiredY;
        } else {
            return bottomY - parentTopLeft.y - height;
        }
    }

    property alias unityMenuModel: repeater.model

    function show() {
        visible = true;
        focusScope.forceActiveFocus();
    }

    function hide() {
        visible = false;
        d.currentItem = null;
    }

    function selectFirstIndex() {
        d.selectNext(-1);
    }

    function reset() {
        d.currentItem = null;
        dismiss();
    }

    function dismiss() {
        d.dismissAll();
    }

    implicitWidth: focusScope.width
    implicitHeight: focusScope.height

    MenuNavigator {
        id: d
        objectName: "d"
        itemView: repeater

        property Item currentItem: null
        property Item hoveredItem: null
        readonly property int currentIndex: currentItem ? currentItem.__ownIndex : -1

        property real __minimumWidth: units.gu(20)
        property real __maximumWidth: ApplicationMenusLimits.screenWidth * 0.7
        property real __minimumHeight: units.gu(2)
        property real __maximumHeight: ApplicationMenusLimits.screenHeight - PanelState.panelHeight

        signal dismissAll()

        onCurrentItemChanged: {
            if (currentItem) {
                currentItem.item.forceActiveFocus();
            } else {
                hoveredItem = null;
            }

            submenuHoverTimer.stop();
        }

        onSelect: {
            currentItem = repeater.itemAt(index);
            if (currentItem) {
                if (currentItem.y < listView.contentY) {
                    listView.contentY = currentItem.y;
                } else if (currentItem.y + currentItem.height > listView.contentY + listView.height) {
                    listView.contentY = currentItem.y + currentItem.height - listView.height;
                }
            }
        }
    }

    MouseArea {
        // Eat events.
        anchors.fill: parent
    }

    Item {
        id: focusScope
        width: container.width
        height: container.height
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

            height: MathUtils.clamp(listView.contentHeight, d.__minimumHeight, d.__maximumHeight)
            width: menuColumn.width
            spacing: 0

            // Header - scroll up
            Item {
                Layout.fillWidth: true
                height: units.gu(3)
                visible: listView.contentHeight > root.height
                enabled: !listView.atYBeginning
                z: 1

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
                    id: previousMA
                    anchors.fill: parent
                    hoverEnabled: enabled
                    onPressed: progress()

                    Timer {
                        running: previousMA.containsMouse && !listView.atYBeginning
                        interval: 1000
                        repeat: true
                        onTriggered: previousMA.progress()
                    }

                    function progress() {
                        var item = menuColumn.childAt(0, listView.contentY);
                        if (item) {
                            var previousItem = item;
                            do {
                                previousItem = repeater.itemAt(previousItem.__ownIndex-1);
                                if (!previousItem) {
                                    listView.contentY = 0;
                                    return;
                                }
                            } while (previousItem.__isSeparator);

                            listView.contentY = previousItem.y
                        }
                    }
                }
            }

            // Menu Items
            Flickable {
                id: listView
                clip: interactive

                Layout.fillHeight: true
                Layout.fillWidth: true
                contentHeight: menuColumn.height
                interactive: height < contentHeight

                Timer {
                    id: submenuHoverTimer
                    interval: 225 // GTK MENU_POPUP_DELAY, Qt SH_Menu_SubMenuPopupDelay in QCommonStyle is 256
                    onTriggered: d.currentItem.item.trigger();
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    z: 1 // on top so we override any other hovers
                    onEntered: updateCurrentItemFromPosition(Qt.point(mouseX, mouseY))
                    onPositionChanged: updateCurrentItemFromPosition(Qt.point(mouse.x, mouse.y))

                    function updateCurrentItemFromPosition(point) {
                        var pos = mapToItem(listView.contentItem, point.x, point.y);

                        if (!d.hoveredItem || !d.currentItem ||
                                !d.hoveredItem.contains(Qt.point(pos.x - d.currentItem.x, pos.y - d.currentItem.y))) {
                            submenuHoverTimer.stop();

                            d.hoveredItem = menuColumn.childAt(pos.x, pos.y)
                            if (!d.hoveredItem || !d.hoveredItem.enabled)
                                return;
                            d.currentItem = d.hoveredItem;

                            if (!d.currentItem.__isSeparator && d.currentItem.item.hasSubmenu && d.currentItem.item.enabled) {
                                submenuHoverTimer.start();
                            }
                        }
                    }

                    onClicked: {
                        var pos = mapToItem(listView.contentItem, mouse.x, mouse.y);
                        var clickedItem = menuColumn.childAt(pos.x, pos.y);
                        if (clickedItem.enabled && !clickedItem.__isSeparator) {
                            clickedItem.item.trigger();
                        }
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

                Component {
                    id: separatorComponent
                    ListItems.ThinDivider {
                        // Parent will be loader
                        objectName: parent.objectName + "-separator"
                        implicitHeight: units.dp(2)
                    }
                }

                Component {
                    id: menuItemComponent
                    MenuItem {
                        // Parent will be loader
                        id: menuItem
                        menuData: parent.__menuData
                        objectName: parent.objectName + "-actionItem"

                        width: MathUtils.clamp(implicitWidth, d.__minimumWidth, d.__maximumWidth)

                        property Item popup: null

                        action.onTriggered: {
                            submenuHoverTimer.stop();

                            d.currentItem = parent;

                            if (hasSubmenu) {
                                if (!popup) {
                                    root.unityMenuModel.aboutToShow(__ownIndex);
                                    var model = root.unityMenuModel.submenu(__ownIndex);
                                    popup = submenuComponent.createObject(focusScope, {
                                                                                objectName: parent.objectName + "-",
                                                                                unityMenuModel: model,
                                                                                substractWidth: true,
                                                                                desiredX: Qt.binding(function() { return root.width }),
                                                                                desiredY: Qt.binding(function() {
                                                                                    var dummy = listView.contentY; // force a recalc on contentY change.
                                                                                    return mapToItem(container, 0, y).y;
                                                                                })
                                                                            });
                                    popup.retreat.connect(function() {
                                        popup.destroy();
                                        popup = null;
                                        menuItem.forceActiveFocus();
                                    });
                                    popup.childActivated.connect(function() {
                                        popup.destroy();
                                        popup = null;
                                        root.childActivated();
                                    });
                                } else if (!popup.visible) {
                                    root.unityMenuModel.aboutToShow(__ownIndex);
                                    popup.visible = true;
                                    popup.item.selectFirstIndex();
                                }
                            } else {
                                root.unityMenuModel.activate(__ownIndex);
                                root.childActivated();
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

                        Component.onDestruction: {
                            if (popup) {
                                popup.destroy();
                                popup = null;
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: menuColumn
                    spacing: 0

                    width: MathUtils.clamp(implicitWidth, d.__minimumWidth, d.__maximumWidth)

                    Repeater {
                        id: repeater

                        onCountChanged: {
                            if (root.selectFirstOnCountChange && !d.currentItem && count > 0) {
                                root.selectFirstIndex();
                            }
                        }

                        Loader {
                            id: loader
                            objectName: root.objectName + "-item" + __ownIndex

                            readonly property var popup: item ? item.popup : null
                            property var __menuData: model
                            property int __ownIndex: index
                            property bool __isSeparator: model.isSeparator

                            enabled: __isSeparator ? false : model.sensitive

                            sourceComponent: {
                                if (model.isSeparator) {
                                    return separatorComponent;
                                }
                                return menuItemComponent;
                            }

                            Layout.fillWidth: true
                        }

                    }
                }

                // Highlight
                Rectangle {
                    color: "transparent"
                    border.width: units.dp(1)
                    border.color: UbuntuColors.orange
                    z: 1

                    width: listView.width
                    height:  d.currentItem ? d.currentItem.height : 0
                    y:  d.currentItem ? d.currentItem.y : 0
                    visible: d.currentItem
                }

            } // Flickable

            // Header - scroll down
            Item {
                Layout.fillWidth: true
                height: units.gu(3)
                visible: listView.contentHeight > root.height
                enabled: !listView.atYEnd
                z: 1

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
                    id: nextMA
                    anchors.fill: parent
                    hoverEnabled: enabled
                    onPressed: progress()

                    Timer {
                        running: nextMA.containsMouse && !listView.atYEnd
                        interval: 1000
                        repeat: true
                        onTriggered: nextMA.progress()
                    }

                    function progress() {
                        var item = menuColumn.childAt(0, listView.contentY + listView.height);
                        if (item) {
                            var nextItem = item;
                            do {
                                nextItem = repeater.itemAt(nextItem.__ownIndex+1);
                                if (!nextItem) {
                                    listView.contentY = listView.contentHeight - listView.height;
                                    return;
                                }
                            } while (nextItem.__isSeparator);

                            listView.contentY = nextItem.y - listView.height
                        }
                    }
                }
            }
        } // Column

        Component {
            id: submenuComponent
            Loader {
                id: submenuLoader
                source: "MenuPopup.qml"

                property real desiredX
                property real desiredY
                property bool substractWidth
                property var unityMenuModel: null
                signal retreat()
                signal childActivated()

                onLoaded: {
                    item.unityMenuModel = Qt.binding(function() { return submenuLoader.unityMenuModel; });
                    item.objectName = Qt.binding(function() { return submenuLoader.objectName + "menu"; });
                    item.desiredX = Qt.binding(function() { return submenuLoader.desiredX; });
                    item.desiredY = Qt.binding(function() { return submenuLoader.desiredY; });
                    item.substractWidth = Qt.binding(function() { return submenuLoader.substractWidth; });
                }

                Keys.onLeftPressed: retreat()

                Connections {
                    target: item
                    onChildActivated: childActivated();
                }
            }
        }
    }
}
