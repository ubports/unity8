/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.1
import Ubuntu.Components 0.1

Item {
    id: root

    property QtObject indicatorsModel: null
    property real overFlowWidth: width
    property bool showAll: false
    property bool expanded: false
    property var currentItem: null
    readonly property int currentItemIndex: currentItem ? currentItem.ownIndex : -1

    property real unitProgress: 0.0
    property real selectionChangeBuffer: units.gu(2)
    property bool enableLateralChanges: false

    property real lateralPosition: -1
    onLateralPositionChanged: {
        if (lateralPosition == -1) return;

        if (!currentItem) {
            selectItemAt(lateralPosition);
            return;
        }

        if (!enableLateralChanges) return;

        var maximumBufferOffset = selectionChangeBuffer * unitProgress;
        var proposedItem = indicatorAt(lateralPosition, 0);
        if (proposedItem) {
            var bufferExceeded = false;

            if (proposedItem !== currentItem) {
                if (Math.abs(currentItem.ownIndex - currentItem.ownIndex) > 1) {
                    bufferExceeded = true;
                } else {
                    var currentItemLateralPosition = root.mapToItem(proposedItem, lateralPosition, 0).x;

                    // is the distance into proposed item greater than max buffer?
                    // proposed item is before current item
                    if (proposedItem.x < currentItem.x) {
                        bufferExceeded = (proposedItem.width - currentItemLateralPosition) > maximumBufferOffset;
                    } else { // after
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

    width: row.width
    height: units.gu(3)

    function indicatorAt(x, y) {
        var item = row.childAt(x, y);
        return item && item.hasOwnProperty("ownIndex") ? item : null
    }

    function resetCurrentItem() {
        currentItem = null;
        d.previousItem = null;
        d.firstItemSwitch = true;
    }

    function setCurrentItemIndex(index) {
        for (var i = 0; i < row.children.length; i++) {
            var item = row.children[i];
            if (item.hasOwnProperty("ownIndex") && item.ownIndex === index) {
                currentItem = item;
                break;
            }
        }
    }

    function selectItemAt(lateralPosition) {
        var item = indicatorAt(lateralPosition, 0);
        if (item && item.opacity > 0) {
            currentItem = item;
        } else {
            var searchIndex = lateralPosition > width ? repeater.count-1 : 0;

            for (var i = 0; i < row.children.length; i++) {
                if (row.children[i].hasOwnProperty("ownIndex") &&
                    row.children[i].ownIndex === searchIndex) {
                    item = row.children[i];
                    break;
                }
            }
            currentItem = item;
        }
    }

    QtObject {
        id: d
        property bool firstItemSwitch: true
        property var previousItem: null
    }

    onCurrentItemChanged: {
        if (d.previousItem) {
            d.firstItemSwitch = false;
        }
        d.previousItem = currentItem;
    }

    Timer {
        id: allVisible
        interval: 1000

        onTriggered: {
            showAll = false;
        }
    }

    Row {
        id: row
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Repeater {
            id: repeater
            model: indicatorsModel
            visible: false

            delegate: IndicatorItem {
                id: item
                objectName: identifier+"-panelItem"

                property int ownIndex: index
                property bool overflow: row.width - x > overFlowWidth
                property bool hidden: !item.expanded && overflow

                height: row.height
                expanded: root.expanded
                selected: currentItem === this

                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath

                opacity: hidden ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.SnapDuration } }
            }
        }
    }

    Rectangle {
        id: highlight
        objectName: "highlight"

        anchors.bottom: row.bottom
        height: units.dp(2)
        color: "#ededed"
        visible: root.currentItem !== null
        opacity: 0.0

        width: currentItem ? currentItem.width : 0
        Behavior on width {
            enabled: !d.firstItemSwitch && expanded
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
        }

        // micromovements of the highlight line when user moves the finger across the items while pulling
        // the handle downwards.
        property real highlightCenterOffset: {
            if (!currentItem || lateralPosition == -1) return 0;
            if (!enableLateralChanges) return 0;

            var itemMapped = root.mapToItem(currentItem, lateralPosition, 0);

            var distanceFromCenter = itemMapped.x - currentItem.width/2;
            if (distanceFromCenter > 0) {
                distanceFromCenter = Math.max(0, distanceFromCenter-currentItem.width/8);
            } else {
                distanceFromCenter = Math.min(0, distanceFromCenter+currentItem.width/8);
            }

            if (currentItem && currentItem.ownIndex === 0 && distanceFromCenter < 0) {
                return 0;
            } else if (currentItem && currentItem.ownIndex === repeater.count-1 & distanceFromCenter > 0) {
                return 0;
            }

            var shiftPercentageOffset = (distanceFromCenter / (currentItem.width/4));
            return shiftPercentageOffset * units.gu(1);
        }
        Behavior on highlightCenterOffset {
            SmoothedAnimation { duration:UbuntuAnimation.FastDuration; velocity: 50; easing: UbuntuAnimation.StandardEasing }
        }

        property real currentItemX: currentItem ? currentItem.x : 0 // having Behavior
        Behavior on currentItemX {
            id: currentItemXBehavior
            enabled: !d.firstItemSwitch && expanded
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
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
                duration: UbuntuAnimation.SnapDuration;
                easing: UbuntuAnimation.StandardEasing
            }
        }
    ]
}
