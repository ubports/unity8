/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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

import QtQuick 2.4
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

// for indicator-keyboard
import AccountsService 0.1
import Unity.InputInfo 0.1

Item {
    id: root
    width: row.width
    height: units.gu(3)

    property QtObject indicatorsModel: null
    property real overFlowWidth: width
    property bool expanded: false
    property var currentItem
    readonly property int currentItemIndex: currentItem ? currentItem.ownIndex : -1

    property real unitProgress: 0.0
    property real selectionChangeBuffer: units.gu(2)
    property bool enableLateralChanges: false
    property color hightlightColor: "#ffffff"

    property real lateralPosition: -1
    onLateralPositionChanged: {
        updateItemFromLateralPosition();
    }

    onEnableLateralChangesChanged: {
        updateItemFromLateralPosition();
    }

    function updateItemFromLateralPosition() {
        if (currentItem && !enableLateralChanges) return;
        if (lateralPosition === -1) return;

        if (!currentItem) {
            selectItemAt(lateralPosition);
            return;
        }

        var maximumBufferOffset = selectionChangeBuffer * unitProgress;
        var proposedItem = indicatorAt(lateralPosition, 0);
        if (proposedItem) {
            var bufferExceeded = false;

            if (proposedItem !== currentItem) {
                // Proposed item is not directly adjacent to current?
                if (Math.abs(proposedItem.ownIndex - currentItem.ownIndex) > 1) {
                    bufferExceeded = true;
                } else { // no
                    var currentItemLateralPosition = root.mapToItem(proposedItem, lateralPosition, 0).x;

                    // Is the distance into proposed item greater than max buffer?
                    // Proposed item is before current item
                    if (proposedItem.x < currentItem.x) {
                        bufferExceeded = (proposedItem.width - currentItemLateralPosition) > maximumBufferOffset;
                    } else { // After
                        bufferExceeded = currentItemLateralPosition > maximumBufferOffset;
                    }
                }
                if (bufferExceeded) {
                    selectItemAt(lateralPosition);
                }
            }
        } else {
            selectItemAt(lateralPosition);
        }
    }

    function indicatorAt(x, y) {
        var item = row.childAt(x, y);
        return item && item.hasOwnProperty("ownIndex") ? item : null;
    }

    function resetCurrentItem() {
        d.firstItemSwitch = true;
        d.previousItem = undefined;
        currentItem = undefined;
    }

    function setCurrentItemIndex(index) {
        for (var i = 0; i < row.children.length; i++) {
            var item = row.children[i];
            if (item.hasOwnProperty("ownIndex") && item.ownIndex === index) {
                if (currentItem !== item) currentItem = item;
                break;
            }
        }
    }

    function selectItemAt(lateralPosition) {
        var item = indicatorAt(lateralPosition, 0);
        if (item && item.opacity > 0) {
            currentItem = item;
        } else {
            // Select default item.
            var searchIndex = lateralPosition > width ? repeater.count - 1 : 0;

            for (var i = 0; i < row.children.length; i++) {
                if (row.children[i].hasOwnProperty("ownIndex") && row.children[i].ownIndex === searchIndex) {
                    item = row.children[i];
                    break;
                }
            }
            if (currentItem !== item) currentItem = item;
        }
    }

    QtObject {
        id: d
        property bool firstItemSwitch: true
        property var previousItem
        property bool forceAlignmentAnimationDisabled: false
    }

    InputDeviceModel {
        id: keyboardsModel
        deviceFilter: InputInfo.Keyboard
    }

    onCurrentItemChanged: {
        if (d.previousItem) {
            d.firstItemSwitch = false;
        }
        d.previousItem = currentItem;
    }

    Row {
        id: row
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        // TODO: make this better
        // when the width changes, the highlight will lag behind due to animation, so we need to disable the animation
        // and adjust the highlight X immediately.
        width: implicitWidth
        Behavior on width {
            SequentialAnimation {
                ScriptAction {
                    script: {
                        d.forceAlignmentAnimationDisabled = true;
                        highlight.currentItemX = Qt.binding(function() { return currentItem ? currentItem.x : 0 });
                        d.forceAlignmentAnimationDisabled = false;
                    }
                }
            }
        }

        Repeater {
            id: repeater
            model: indicatorsModel
            visible: false

            onItemRemoved: {
                // current item removed.
                if (currentItem === item) {
                    var i = 0;
                    while (i < row.children.length) {
                        var childItem = row.children[i];
                        if (childItem !== item) {
                            setCurrentItemIndex(i);
                            break;
                        }
                        i++;
                    }
                }
            }


            delegate: IndicatorItem {
                id: indicatorItem
                objectName: identifier+"-panelItem"

                property int ownIndex: index
                property bool overflow: row.width - x > overFlowWidth
                property bool hidden: !expanded && (overflow || !indicatorVisible || hideSessionIndicator || hideKeyboardIndicator)
                // HACK for indicator-session
                readonly property bool hideSessionIndicator: identifier == "indicator-session" && Math.min(Screen.width, Screen.height) <= units.gu(60)
                // HACK for indicator-keyboard
                readonly property bool hideKeyboardIndicator: identifier == "indicator-keyboard" && (AccountsService.keymaps.length < 2 || keyboardsModel.count == 0)

                height: row.height
                expanded: root.expanded
                selected: currentItem === this

                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath

                opacity: hidden ? 0.0 : 1.0
                Behavior on opacity {
                    NumberAnimation { duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing }
                }

                width: ((expanded || indicatorVisible) && !hideSessionIndicator && !hideKeyboardIndicator) ? implicitWidth : 0

                Behavior on width {
                    NumberAnimation { duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing }
                }

                Component.onDestruction: {
                    // current item removed.
                    if (currentItem === this) {
                        var i = 0;
                        while (i < row.children.length) {
                            var childItem = row.children[i];
                            if (childItem !== this) {
                                setCurrentItemIndex(i);
                                break;
                            }
                            i++;
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: highlight
        objectName: "highlight"

        anchors.bottom: row.bottom
        height: units.dp(2)
        color: root.hightlightColor
        visible: currentItem !== undefined
        opacity: 0.0

        width: currentItem ? currentItem.width : 0
        Behavior on width {
            enabled: !d.firstItemSwitch && expanded
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
        }

        // micromovements of the highlight line when user moves the finger across the items while pulling
        // the handle downwards.
        property real highlightCenterOffset: {
            if (!currentItem || lateralPosition == -1 || !enableLateralChanges) return 0;

            var itemMapped = root.mapToItem(currentItem, lateralPosition, 0);

            var distanceFromCenter = itemMapped.x - currentItem.width / 2;
            if (distanceFromCenter > 0) {
                distanceFromCenter = Math.max(0, distanceFromCenter - currentItem.width / 8);
            } else {
                distanceFromCenter = Math.min(0, distanceFromCenter + currentItem.width / 8);
            }

            if (currentItem && currentItem.ownIndex === 0 && distanceFromCenter < 0) {
                return 0;
            } else if (currentItem && currentItem.ownIndex === repeater.count-1 & distanceFromCenter > 0) {
                return 0;
            }
            return (distanceFromCenter / (currentItem.width / 4)) * units.gu(1);
        }
        Behavior on highlightCenterOffset {
            NumberAnimation { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
        }

        property real currentItemX: currentItem ? currentItem.x : 0
        Behavior on currentItemX {
            id: currentItemXBehavior
            enabled: !d.firstItemSwitch && expanded && !d.forceAlignmentAnimationDisabled
            NumberAnimation { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
        }
        x: currentItemX + highlightCenterOffset
    }

    states: [
        State {
            name: "minimised"
            when: !expanded
        },
        State {
            name: "expanded"
            when: expanded
            PropertyChanges { target: highlight; opacity: 0.9 }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "opacity";
                duration: UbuntuAnimation.SnapDuration
                easing: UbuntuAnimation.StandardEasing
            }
        }
    ]
}
