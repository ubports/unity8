/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 1.1
import "../Components"

Item {
    id: root
    property alias expanded: row.expanded
    property alias indicatorsModel: row.indicatorsModel
    property alias unitProgress: row.unitProgress
    property alias enableLateralChanges: row.enableLateralChanges
    property alias overFlowWidth: row.overFlowWidth
    readonly property alias currentItemIndex: row.currentItemIndex
    property real lateralPosition: -1

    function selectItemAt(lateralPosition) {
        if (!expanded) {
            row.resetCurrentItem();
        }
        var mapped = root.mapToItem(row, lateralPosition, 0);
        row.selectItemAt(mapped.x);
    }

    function updateItemFromLateralPosition(position) {
        if (position === -1) return;

        var mapped = root.mapToItem(row, position, 0);
        row.updateItemFromLateralPosition(mapped.x);
    }

    function setCurrentItemIndex(index) {
        if (!expanded) {
            row.resetCurrentItem();
        }
        row.setCurrentItemIndex(index);
    }

    function alignIndicators() {
        alignmentTimer.start();
    }

    function addScrollOffset(scrollAmmout) {
        if (scrollAmmout < 0) { // left scroll
            if (flickable.contentX < 0) return; // already off the left.
            if (flickable.contentX + scrollAmmout < 0) scrollAmmout = -flickable.contentX; // going to be off the left
        } else { // right scroll
            if (flickable.contentX + flickable.width > row.width) return; // already off the right.
            if (flickable.contentX + flickable.width + scrollAmmout > row.width) { // going to be off the right
                scrollAmmout = row.width - (flickable.contentX + flickable.width);
            }
        }
        d.scrollOffset = d.scrollOffset + scrollAmmout;
    }

    QtObject {
        id: d
        property var initialItem
        // the non-expanded distance from row offset to center of initial item
        property real originalDistanceFromRight: -1

        // calculate the distance from row offset to center of initial item
        property real distanceFromRight: {
            if (originalDistanceFromRight == -1) return 0;
            if (!initialItem) return 0;
            return row.width - initialItem.x - initialItem.width /2;
        }

        // offset to the intially selected expanded item
        property real rowOffset: 0
        property real scrollOffset: 0
        property real alignmentAdjustment: 0
        property real combinedOffset: 0

        // when the scroll offset changes, we need to reclaculate the relative lateral position
        onScrollOffsetChanged: root.lateralPositionChanged()

        onInitialItemChanged: {
            originalDistanceFromRight = initialItem ? (row.width - initialItem.x - initialItem.width/2) : -1;
        }

        Behavior on alignmentAdjustment {
            NumberAnimation { duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}
        }
    }

    Rectangle {
        id: grayLine
        height: units.dp(2)
        width: parent.width
        anchors.bottom: parent.bottom

        color: "#4c4c4c"
        opacity: expanded ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: UbuntuAnimation.SnapDuration } }
    }

    Item {
        id: rowContainer
        anchors.fill: parent
        clip: expanded || row.width > rowContainer.width

        Flickable {
            id: flickable
            objectName: "flickable"

            anchors.fill: parent
            contentWidth: row.width
            interactive: root.expanded
            // align right + offset from row selection + scrolling
            contentX: row.width - flickable.width - d.combinedOffset

            rebound: Transition {
                NumberAnimation {
                    properties: "x"
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }

            IndicatorItemRow {
                id: row
                objectName: "indicatorItemRow"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                lateralPosition: {
                    if (root.lateralPosition == -1) return -1;

                    var mapped = root.mapToItem(row, root.lateralPosition, 0);
                    return Math.min(Math.max(mapped.x, 0), row.width);
                }

                onCurrentItemChanged: {
                    if (!currentItem) d.initialItem = undefined;
                    else if (!d.initialItem) d.initialItem = currentItem;
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.expanded
                    onClicked: {
                        row.selectItemAt(mouse.x);
                        alignIndicators();
                    }
                }
            }

        }
    }

    Timer {
        id: alignmentTimer
        interval: UbuntuAnimation.FastDuration // enough for row animation.
        repeat: false
        onTriggered: {
            if (expanded && !flickable.moving && row.width > flickable.width && flickable.contentX < 0) { // off the left.
                d.alignmentAdjustment += flickable.contentX;
            }
        }
    }

    states: [
        State {
            name: "minimized"
            when: !expanded
            PropertyChanges {
                target: d
                rowOffset: 0
                scrollOffset: 0
                alignmentAdjustment: 0
                restoreEntryValues: false
            }
        },
        State {
            name: "expanded"
            when: expanded

            PropertyChanges {
                target: d
                combinedOffset: rowOffset + alignmentAdjustment - scrollOffset
            }

            PropertyChanges {
                target: d
                rowOffset: {
                    if (!initialItem) return 0;
                    if (distanceFromRight - initialItem.width <= 0) return 0;

                    var rowOffset = distanceFromRight - originalDistanceFromRight;
                    return rowOffset;
                }
                restoreEntryValues: false
            }
        }
    ]

    transitions: [
        Transition {
            from: "expanded"
            to: "minimized"
            PropertyAction {
                target: d
                properties: "rowOffset, scrollOffset, alignmentAdjustment"
                value: 0
            }
            PropertyAnimation {
                target: d
                properties: "combinedOffset"
                duration: UbuntuAnimation.SnapDuration
                easing: UbuntuAnimation.StandardEasing
            }
        }
    ]
}
