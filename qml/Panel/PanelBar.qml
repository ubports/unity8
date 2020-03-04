/*
 * Copyright (C) 2014 Canonical, Ltd.
 * Copyright (C) 2020 UBports Foundation
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
import Ubuntu.Components 1.3
import "../Components"

Item {
    id: root
    property alias expanded: row.expanded
    property alias interactive: flickable.interactive
    property alias model: row.model
    property alias unitProgress: row.unitProgress
    property alias enableLateralChanges: row.enableLateralChanges
    property alias overFlowWidth: row.overFlowWidth
    readonly property alias currentItemIndex: row.currentItemIndex
    property real lateralPosition: -1
    property int alignment: Qt.AlignRight
    readonly property int rowContentX: row.contentX

    property alias hideRow: row.hideRow
    property alias rowItemDelegate: row.delegate

    implicitWidth: flickable.contentWidth

    function selectItemAt(lateralPosition) {
        if (!expanded) {
            row.resetCurrentItem();
        }
        var mapped = root.mapToItem(row, lateralPosition, 0);
        row.selectItemAt(mapped.x);
    }

    function selectPreviousItem() {
        if (!expanded) {
            row.resetCurrentItem();
        }
        row.selectPreviousItem();
        d.alignIndicators();
    }

    function selectNextItem() {
        if (!expanded) {
            row.resetCurrentItem();
        }
        row.selectNextItem();
        d.alignIndicators();
    }

    function setCurrentItemIndex(index) {
        if (!expanded) {
            row.resetCurrentItem();
        }
        row.setCurrentItemIndex(index);
        d.alignIndicators();
    }

    function addScrollOffset(scrollAmmout) {
        if (root.alignment == Qt.AlignLeft) {
            scrollAmmout = -scrollAmmout;
        }

        if (scrollAmmout < 0) { // left scroll
            if (flickable.contentX + flickable.width > row.width) return; // already off the left.

            if (flickable.contentX + flickable.width - scrollAmmout > row.width) { // going to be off the left
                scrollAmmout = (flickable.contentX + flickable.width) - row.width;
            }
        } else { // right scroll
            if (flickable.contentX < 0) return; // already off the right.
            if (flickable.contentX - scrollAmmout < 0) { // going to be off the right
                scrollAmmout = flickable.contentX;
            }
        }
        d.scrollOffset = d.scrollOffset + scrollAmmout;
    }

    QtObject {
        id: d
        property var initialItem
        // the non-expanded distance from alignment edge to center of initial item
        property real originalDistanceFromEdge: -1

        // calculate the distance from row alignment edge edge to center of initial item
        property real distanceFromEdge: {
            if (originalDistanceFromEdge == -1) return 0;
            if (!initialItem) return 0;

            if (root.alignment == Qt.AlignLeft) {
                return initialItem.x - initialItem.width / 2;
            } else {
                return row.width - initialItem.x - initialItem.width / 2;
            }
        }

        // offset to the intially selected expanded item
        property real rowOffset: 0
        property real scrollOffset: 0
        property real alignmentAdjustment: 0
        property real combinedOffset: 0

        // when the scroll offset changes, we need to reclaculate the relative lateral position
        onScrollOffsetChanged: root.lateralPositionChanged()

        onInitialItemChanged: {
            if (root.alignment == Qt.AlignLeft) {
                originalDistanceFromEdge = initialItem ? (initialItem.x - initialItem.width/2) : -1;
            } else {
                originalDistanceFromEdge = initialItem ? (row.width - initialItem.x - initialItem.width/2) : -1;
            }
        }

        Behavior on alignmentAdjustment {
            NumberAnimation { duration: UbuntuAnimation.BriskDuration; easing: UbuntuAnimation.StandardEasing}
        }

        function alignIndicators() {
            flickable.resetContentXComponents();

            if (expanded && !flickable.moving) {

                if (root.alignment == Qt.AlignLeft) {
                    // current item overlap on left
                    if (row.currentItem && flickable.contentX > (row.currentItem.x - row.contentX)) {
                        d.alignmentAdjustment -= (flickable.contentX - (row.currentItem.x - row.contentX));

                    // current item overlap on right
                    } else if (row.currentItem && flickable.contentX + flickable.width < (row.currentItem.x - row.contentX) + row.currentItem.width) {
                        d.alignmentAdjustment += ((row.currentItem.x - row.contentX) + row.currentItem.width) - (flickable.contentX + flickable.width);
                    }
                } else {
                    // gap between left and row?
                    if (flickable.contentX + flickable.width > row.width) {
                        // row width is less than flickable
                        if (row.width < flickable.width) {
                            d.alignmentAdjustment -= flickable.contentX;
                        } else {
                            d.alignmentAdjustment -= ((flickable.contentX + flickable.width) - row.width);
                        }

                        // gap between right and row?
                    } else if (flickable.contentX < 0) {
                        d.alignmentAdjustment -= flickable.contentX;

                    // current item overlap on left
                    } else if (row.currentItem && (flickable.contentX + flickable.width) < (row.width - (row.currentItem.x - row.contentX))) {
                        d.alignmentAdjustment += ((row.width - (row.currentItem.x - row.contentX)) - (flickable.contentX + flickable.width));

                    // current item overlap on right
                    } else if (row.currentItem && flickable.contentX > (row.width - (row.currentItem.x - row.contentX) - row.currentItem.width)) {
                        d.alignmentAdjustment -= flickable.contentX - (row.width - (row.currentItem.x - row.contentX) - row.currentItem.width);
                    }
                }
            }
        }
    }

    Rectangle {
        id: grayLine
        height: units.dp(2)
        width: parent.width
        anchors.bottom: parent.bottom

        color: "#888888"
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

            // we rotate it because we want the Flickable to align its content item
            // on the right instead of on the left
            rotation: root.alignment != Qt.AlignRight ? 0 : 180

            anchors.fill: parent
            contentWidth: row.width
            contentX: d.combinedOffset
            interactive: false

            // contentX can change by user interaction as well as user offset changes
            // This function re-aligns the offsets so that the offsets match the contentX
            function resetContentXComponents() {
                d.scrollOffset += d.combinedOffset - flickable.contentX;
            }

            rebound: Transition {
                NumberAnimation {
                    properties: "x"
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }

            PanelItemRow {
                id: row
                objectName: "panelItemRow"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                // Compensate for the Flickable rotation (ie, counter-rotate)
                rotation: root.alignment != Qt.AlignRight ? 0 : 180

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
                        d.alignIndicators();
                    }
                }
            }

        }
    }

    Timer {
        id: alignmentTimer
        interval: UbuntuAnimation.FastDuration // enough for row animation.
        repeat: false

        onTriggered: d.alignIndicators();
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
                combinedOffset: 0
                restoreEntryValues: false
            }
        },
        State {
            name: "expanded"
            when: expanded && !interactive

            PropertyChanges {
                target: d
                combinedOffset: rowOffset + alignmentAdjustment - scrollOffset
            }
            PropertyChanges {
                target: d
                rowOffset: {
                    if (!initialItem) return 0;
                    if (distanceFromEdge - initialItem.width <= 0) return 0;

                    var rowOffset = distanceFromEdge - originalDistanceFromEdge;
                    return rowOffset;
                }
                restoreEntryValues: false
            }
        },
        State {
            name: "interactive"
            when: expanded && interactive

            StateChangeScript {
                script: {
                    // don't use row offset anymore.
                    d.scrollOffset -= d.rowOffset;
                    d.rowOffset = 0;
                    d.initialItem = undefined;
                    alignmentTimer.start();
                }
            }
            PropertyChanges {
                target: d
                combinedOffset: rowOffset + alignmentAdjustment - scrollOffset
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
