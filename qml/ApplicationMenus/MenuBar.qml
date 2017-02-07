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

    // set from outside
    property alias unityMenuModel: rowRepeater.model
    property bool enableKeyFilter: false
    property real overflowWidth: width

    // read from outside
    readonly property bool valid: rowRepeater.count > 0
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
        hoverEnabled: enabled && d.currentItem && d.currentItem.__popup != null
        onPressed: d.dismissAll()
    }

    Row {
        id: row
        spacing: units.gu(2)
        height: parent.height

        ActionContext {
            id: menuBarContext
            objectName: "barContext"
            active: !d.currentItem && enableKeyFilter
        }

        Connections {
            target: root.unityMenuModel
            onModelReset: d.firstInvisibleIndex = undefined
        }

        Repeater {
            id: rowRepeater

            onItemAdded: d.recalcFirstInvisibleIndexAdded(index, item)
            onCountChanged: d.recalcFirstInvisibleIndex()

            Item {
                id: visualItem
                objectName: root.objectName + "-item" + __ownIndex

                readonly property int __ownIndex: index
                property Item __popup: null;
                readonly property bool popupVisible: __popup && __popup.visible
                readonly property bool shouldDisplay: x + width + ((__ownIndex < rowRepeater.count-1) ? units.gu(2) : 0) <
                                                root.overflowWidth - ((__ownIndex < rowRepeater.count-1) ? overflowButton.width : 0)

                implicitWidth: column.implicitWidth
                implicitHeight: row.height
                enabled: model.sensitive && shouldDisplay
                opacity: shouldDisplay ? 1 : 0

                function show() {
                    if (!__popup) {
                        __popup = menuComponent.createObject(root, { objectName: visualItem.objectName + "-menu" });
                        __popup.childActivated.connect(dismiss);
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

                onVisibleChanged: {
                    if (!visible && __popup) dismiss();
                }

                onShouldDisplayChanged: {
                    if ((!shouldDisplay && d.firstInvisibleIndex == undefined) || __ownIndex <= d.firstInvisibleIndex) {
                        d.recalcFirstInvisibleIndex();
                    }
                }

                Connections {
                    target: d
                    onDismissAll: visualItem.dismiss()
                }

                Component {
                    id: menuComponent
                    MenuPopup {
                        desiredX: visualItem.x - units.gu(1)
                        desiredY: parent.height
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
                            enabled: visualItem.enabled
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
                            color: enabled ? theme.palette.normal.backgroundText : theme.palette.disabled.backgroundText
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
        onClicked: {
            var prevItem = d.currentItem;
            updateCurrentItemFromPosition(Qt.point(mouse.x, mouse.y))
            if (prevItem && d.currentItem == prevItem) {
                prevItem.hide();
            }
        }

        function updateCurrentItemFromPosition(point) {
            var pos = mapToItem(row, point.x, point.y);

            if (!d.hoveredItem || !d.currentItem || !d.hoveredItem.contains(Qt.point(pos.x - d.currentItem.x, pos.y - d.currentItem.y))) {
                d.hoveredItem = row.childAt(pos.x, pos.y);
                if (!d.hoveredItem || !d.hoveredItem.enabled)
                    return;
                if (d.currentItem != d.hoveredItem) {
                    d.currentItem = d.hoveredItem;
                }
            }
        }
    }

    MouseArea {
        id: overflowButton
        objectName: "overflow"

        hoverEnabled: d.currentItem
        onEntered: d.currentItem = this
        onPositionChanged: d.currentItem = this
        onClicked: d.currentItem = this

        property Item __popup: null;
        readonly property bool popupVisible: __popup && __popup.visible
        readonly property Item firstInvisibleItem: d.firstInvisibleIndex !== undefined ? rowRepeater.itemAt(d.firstInvisibleIndex) : null

        visible: d.firstInvisibleIndex != undefined
        x: firstInvisibleItem ? firstInvisibleItem.x : 0

        height: parent.height
        width: units.gu(4)

        onVisibleChanged: {
            if (!visible && __popup) dismiss();
        }

        Icon {
            id: icon
            width: units.gu(2)
            height: units.gu(2)
            anchors.centerIn: parent
            color: theme.palette.normal.backgroundText
            name: "toolkit_chevron-down_2gu"
        }

        function show() {
            if (!__popup) {
                __popup = overflowComponent.createObject(root, { objectName: overflowButton.objectName + "-menu" });
                __popup.childActivated.connect(dismiss);
                // force the current item to be the newly popped up menu
            } else {
                __popup.show();
            }
            d.currentItem = overflowButton;
        }
        function hide() {
            if (__popup) {
                __popup.hide();

                if (d.currentItem === overflowButton) {
                    d.currentItem = null;
                }
            }
        }
        function dismiss() {
            if (__popup) {
                __popup.destroy();
                __popup = null;

                if (d.currentItem === overflowButton) {
                    d.currentItem = null;
                }
            }
        }

        Connections {
            target: d
            onDismissAll: overflowButton.dismiss()
        }

        Component {
            id: overflowComponent
            MenuPopup {
                id: overflowPopup
                desiredX: overflowButton.x - units.gu(1)
                desiredY: parent.height
                unityMenuModel: overflowModel

                ExpressionFilterModel {
                    id: overflowModel
                    sourceModel: root.unityMenuModel
                    matchExpression: function(index) {
                        if (d.firstInvisibleIndex === undefined) return false;
                        return index >= d.firstInvisibleIndex;
                    }

                    function submenu(index) {
                        return sourceModel.submenu(mapRowToSource(index));
                    }
                    function activate(index) {
                        return sourceModel.activate(mapRowToSource(index));
                    }
                }

                Connections {
                    target: d
                    onFirstInvisibleIndexChanged: overflowModel.invalidate()
                }
            }
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

    MenuNavigator {
        id: d
        objectName: "d"
        itemView: rowRepeater
        hasOverflow: overflowButton.visible

        property Item currentItem: null
        property Item hoveredItem: null
        property Item prevCurrentItem: null
        property bool altPressed: false
        property bool longAltPressed: false
        property var firstInvisibleIndex: undefined

        readonly property int currentIndex: currentItem && currentItem.hasOwnProperty("__ownIndex") ? currentItem.__ownIndex : -1

        signal dismissAll()

        function recalcFirstInvisibleIndexAdded(index, item) {
            if (firstInvisibleIndex === undefined) {
                if (!item.shouldDisplay) {
                    firstInvisibleIndex = index;
                }
            } else if (index <= firstInvisibleIndex) {
                if (!item.shouldDisplay) {
                    firstInvisibleIndex = index;
                } else {
                    firstInvisibleIndex++;
                }
            }
        }

        function recalcFirstInvisibleIndex() {
            for (var i = 0; i < rowRepeater.count; i++) {
                if (!rowRepeater.itemAt(i).shouldDisplay) {
                    firstInvisibleIndex = i;
                    return;
                }
            }
            firstInvisibleIndex = undefined;
        }

        onSelect: {
            var delegate = rowRepeater.itemAt(index);
            if (delegate) {
                d.currentItem = delegate;
            }
        }

        onOverflow: {
            d.currentItem = overflowButton;
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
