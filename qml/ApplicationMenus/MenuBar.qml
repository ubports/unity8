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
import Utils 0.1
import Ubuntu.Components 1.3
import GlobalShortcut 1.0

Item {
    id: root
    objectName: "menuBar"

    property alias unityMenuModel: rowRepeater.model

    readonly property bool valid: rowRepeater.count > 0

    property bool enableKeyFilter: false

    readonly property bool showRequested: d.longAltPressed || d.currentItem != null

    implicitWidth: row.width
    height: parent.height

    function select(index) {
        d.select(index);
    }

    function dismiss() {
        d.dismissAll();
    }

    GlobalShortcut {
        shortcut: Qt.Key_Alt|Qt.AltModifier
        active: enableKeyFilter
        onTriggered: d.startShortcutTimer()
        onReleased: d.stopSHortcutTimer()
    }
    // On an actual keyboard, the AltModifier is not supplied on release.
    GlobalShortcut {
        shortcut: Qt.Key_Alt
        active: enableKeyFilter
        onTriggered: d.startShortcutTimer()
        onReleased: d.stopSHortcutTimer()
    }

    GlobalShortcut {
        shortcut: Qt.AltModifier | Qt.Key_F10
        active: enableKeyFilter && d.currentItem == null
        onTriggered: {
            for (var i = 0; i < rowRepeater.count; i++) {
                var item = rowRepeater.itemAt(i);
                if (item.enabled) {
                    item.show();
                    break;
                }
            }
        }
    }

    InverseMouseArea {
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        anchors.fill: parent
        enabled: d.currentItem != null
        onPressed: d.dismissAll()
    }

    Item {
        id: clippingItem

        height: root.height
        width: root.width
        clip: true

        Row {
            id: row
            spacing: units.gu(2)
            height: parent.height

            ActionContext {
                id: menuBarContext
                objectName: "barContext"
                active: !d.currentItem && enableKeyFilter
            }

            Repeater {
                id: rowRepeater

                Item {
                    id: visualItem
                    objectName: root.objectName + "-item" + __ownIndex

                    readonly property int __ownIndex: index
                    property Item __popup: null;
                    property bool popupVisible: __popup && __popup.visible

                    implicitWidth: column.implicitWidth
                    implicitHeight: row.height
                    enabled: model.sensitive

                    function show() {
                        if (!__popup) {
                            __popup = menuComponent.createObject(root, { objectName: visualItem.objectName + "-menu" });
                            // force the current item to be the newly popped up menu
                        } else {
                            __popup.show();
                        }
                        d.currentItem = visualItem;
                    }
                    function hide() {
                        if (__popup) {
                            __popup.hide();

                            if (d.currentItem === visualItem) {
                                d.currentItem = null;
                            }
                        }
                    }
                    function dismiss() {
                        if (__popup) {
                            __popup.destroy();
                            __popup = null;

                            if (d.currentItem === visualItem) {
                                d.currentItem = null;
                            }
                        }
                    }

                    Connections {
                        target: d
                        onDismissAll: visualItem.dismiss()
                    }

                    Component {
                        id: menuComponent
                        MenuPopup {
                            x: visualItem.x - units.gu(1)
                            anchors.top: parent.bottom
                            unityMenuModel: root.unityMenuModel.submenu(visualItem.__ownIndex)

                            Component.onCompleted: reset();
                        }
                    }

                    RowLayout {
                        id: column
                        spacing: units.gu(1)
                        anchors {
                            centerIn: parent
                        }

                        Icon {
                            Layout.preferredWidth: units.gu(2)
                            Layout.preferredHeight: units.gu(2)
                            Layout.alignment: Qt.AlignVCenter

                            visible: model.icon || false
                            source: model.icon || ""
                        }

                        ActionItem {
                            id: actionItem
                            width: _title.width
                            height: _title.height

                            action: Action {
                                // FIXME - SDK Action:text modifies menu text with html underline for mnemonic
                                text: model.label.replace("_", "&").replace("<u>", "&").replace("</u>", "")

                                onTriggered: {
                                    visualItem.show();
                                }
                            }

                            Label {
                                id: _title
                                text: actionItem.text
                                horizontalAlignment: Text.AlignLeft
                                color: enabled ? "white" : "#5d5d5d"
                            }
                        }
                    }
                } // Item ( delegate )
            } // Repeater
        } // Row

        MouseArea {
            anchors.fill: parent
            hoverEnabled: d.currentItem

            onEntered: {
                if (d.currentItem) {
                    updateCurrentItemFromPosition(Qt.point(mouseX, mouseY))
                }
            }
            onPositionChanged: {
                if (d.currentItem) {
                    updateCurrentItemFromPosition(Qt.point(mouse.x, mouse.y))
                }
            }
            onClicked: updateCurrentItemFromPosition(Qt.point(mouse.x, mouse.y))

            function updateCurrentItemFromPosition(point) {
                var pos = mapToItem(row, point.x, point.y);

                if (!d.hoveredItem || !d.currentItem || !d.hoveredItem.contains(Qt.point(pos.x - d.currentItem.x, pos.y - d.currentItem.y))) {
                    d.hoveredItem = row.childAt(pos.x, pos.y);
                    if (!d.hoveredItem || !d.hoveredItem.enabled)
                        return false;
                    if (d.currentItem != d.hoveredItem) {
                        d.currentItem = d.hoveredItem;
                    }
                }
                return true;
            }
        }

        Rectangle {
            id: underline
            anchors {
                bottom: row.bottom
            }
            x: d.currentItem ? row.x + d.currentItem.x - units.gu(1) : 0
            width: d.currentItem ? d.currentItem.width + units.gu(2) : 0
            height: units.dp(4)
            color: UbuntuColors.orange
            visible: d.currentItem
        }
    }

    MenuNavigator {
        id: d
        objectName: "d"
        itemView: rowRepeater

        property Item currentItem: null
        property Item hoveredItem: null
        property Item prevCurrentItem: null

        readonly property int currentIndex: currentItem ? currentItem.__ownIndex : -1

        property bool altPressed: false
        property bool longAltPressed: false

        signal dismissAll()

        onSelect: {
            var delegate = rowRepeater.itemAt(index);
            if (delegate) {
                d.currentItem = delegate;
            }
        }

        onCurrentItemChanged: {
            if (prevCurrentItem && prevCurrentItem != currentItem) {
                if (currentItem) {
                    prevCurrentItem.hide();
                } else {
                    prevCurrentItem.dismiss();
                }
            }

            if (currentItem) currentItem.show();
            prevCurrentItem = currentItem;
        }

        function startShortcutTimer() {
            d.altPressed = true;
            menuBarShortcutTimer.start();
        }

        function stopSHortcutTimer() {
            menuBarShortcutTimer.stop();
            d.altPressed = false;
            d.longAltPressed = false;
        }
    }

    Timer {
        id: menuBarShortcutTimer
        interval: 200
        repeat: false
        onTriggered: {
            d.longAltPressed = true;
        }
    }

    Keys.onEscapePressed: {
        d.dismissAll();
        event.accepted = true;
    }

    Keys.onLeftPressed: {
        if (d.currentItem) {
            d.selectPrevious(d.currentIndex);
        }
    }

    Keys.onRightPressed: {
        if (d.currentItem) {
            d.selectNext(d.currentIndex);
        }
    }
}
