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

    function alignIndicatorsToLeft() {
        alignmentTimer.start()
    }

    function addScrollOffset(scrollAmmout) {
        var proposedScrollOffset = d.scrollOffset + scrollAmmout;
        var proposedCombinedOffset = d.combinedOffset - scrollAmmout;

        if (scrollAmmout < 0 && d.combinedOffset > (row.width - rowContainer.width)) return;

        if (scrollAmmout > 0 && proposedCombinedOffset < 0) {
            // get the combined offset back to 0
            proposedScrollOffset = proposedScrollOffset + proposedCombinedOffset;
        } else if (scrollAmmout < 0 && proposedCombinedOffset > row.width - rowContainer.width) {
            // get the combined offset back to max
            proposedScrollOffset = proposedScrollOffset + (proposedCombinedOffset - (row.width - rowContainer.width));
        }

        d.scrollOffset = proposedScrollOffset;
    }

    QtObject {
        id: d
        property var initialItem
        // the non-expanded distance from row offset to center of initial item
        property real originalDistanceFromRight: -1
        property real originalItemWidth: -1

        // calculate the distance from row offset to center of initial item
        property real distanceFromRight: {
            if (originalDistanceFromRight == -1) return 0;
            if (!initialItem) return 0;
            return row.width - initialItem.x - initialItem.width /2;
        }

        // offset to the intially selected expanded item
        property real rowOffset: 0
        property real alignmentAdjustment: 0
        property real scrollOffset: 0
        property real combinedOffset: rowOffset + alignmentAdjustment - scrollOffset

        onInitialItemChanged: {
            if (initialItem) {
                originalItemWidth = initialItem.width;
                originalDistanceFromRight = row.width - initialItem.x - initialItem.width/2;
            } else {
                originalItemWidth = -1;
                originalDistanceFromRight = -1;
            }
        }

        Behavior on alignmentAdjustment {
            NumberAnimation { duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing}
        }
    }

    onExpandedChanged: {
        if (!expanded) flickable.moved = false;
    }

    Connections {
        target: row
        onCurrentItemChanged: {
            if (!row.currentItem) d.initialItem = undefined;
            else if (!d.initialItem) d.initialItem = row.currentItem;
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

        IndicatorItemRow {
            id: row
            objectName: "indicatorItemRow"
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: -d.combinedOffset
            }

            lateralPosition: {
                if (root.lateralPosition == -1) return -1;
                // just to automatically invoke this calculation when scrolling offset changes
                var dummyvar = d.scrollOffset + row.width;

                var mapped = root.mapToItem(row, root.lateralPosition, 0);
                return Math.min(Math.max(mapped.x, 0), row.width);
            }
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: row.width
            interactive: root.expanded

            property bool moved: false
            onMovingChanged: {
                moved = true;
            }

            rebound: Transition {
                NumberAnimation {
                    properties: "x"
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.expanded
                onClicked: row.selectItemAt(mouse.x);
            }
        }
    }

    Timer {
        id: alignmentTimer
        interval: UbuntuAnimation.SnapDuration // enough for row animation.
        repeat: false
        onTriggered: {
            if (expanded && row.x > 0) {
                d.alignmentAdjustment = -row.x;
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
                alignmentAdjustment: 0
                scrollOffset: 0
                restoreEntryValues: false
            }
        },
        State {
            name: "expanded"
            when: expanded && !flickable.moved

            PropertyChanges {
                target: d
                rowOffset: {
                    if (!initialItem) return 0;
                    if (distanceFromRight - initialItem.width <= 0) return 0;

                    var rowOffset = distanceFromRight - originalDistanceFromRight;
                    if (originalDistanceFromRight + originalItemWidth/2 > rowContainer.width) {
                        rowOffset = rowOffset + originalItemWidth;
                    }
                    return rowOffset;
                }
            }
            // keep flickable inline with row
            PropertyChanges {
                target: flickable
                contentX: (flickable.contentWidth - flickable.width) - d.combinedOffset
                restoreEntryValues: false
            }
        },
        State {
            name: "moved"
            when: expanded && flickable.moved

            StateChangeScript {
                script: {
                    // unbind contentX
                    flickable.contentX = flickable.contentX;
                    d.scrollOffset = 0;
                }
            }
            PropertyChanges {
                target: row
                anchors.rightMargin: - (flickable.contentWidth - flickable.width) + (flickable.contentX) + d.scrollOffset
            }
        }
    ]

    transitions: [
        Transition {
            from: "expanded"
            to: "minimized"
            PropertyAnimation {
                target: d;
                properties: "rowOffset, scrollOffset"
                duration: UbuntuAnimation.SnapDuration
                easing: UbuntuAnimation.StandardEasing
            }
        },
        Transition {
            from: "moved"
            to: "minimized"
            SequentialAnimation {
                PropertyAction { target: d; properties: "rowOffset, alignmentAdjustment, scrollOffset" }
                PropertyAnimation {
                    target: row;
                    properties: "anchors.rightMargin"
                    duration: UbuntuAnimation.SnapDuration
                    easing: UbuntuAnimation.StandardEasing
                }
            }
        }
    ]
}
