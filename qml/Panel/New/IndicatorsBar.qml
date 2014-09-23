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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property alias expanded: row.expanded
    property alias indicatorsModel: row.indicatorsModel

    function selectItemAt(lateralPosition) {
        if (!expanded)
            d.initialItem = null;
        var mapped = root.mapToItem(row, lateralPosition, 0);
        row.selectItemAt(mapped.x);
    }

    QtObject {
        id: d
        property var initialItem: null
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

        onInitialItemChanged: {
            console.log("INITIAL CHANGED ", initialItem)
            if (initialItem) {
                originalItemWidth = initialItem.width;
                originalDistanceFromRight = row.width - initialItem.x - initialItem.width/2;
            } else {
                originalItemWidth = -1;
                originalDistanceFromRight = -1;
            }
        }
    }

    onExpandedChanged: {
        console.log("EXPANDED CHANGED ", expanded)
    }

    Connections {
        target: row
        onCurrentItemChanged: {
            if (!row.currentItem) d.initialItem = null;
            else if (!d.initialItem) d.initialItem = row.currentItem;
        }
    }

    Flickable {
        id: flickable
        flickableDirection: Qt.Horizontal
        anchors.fill: parent
        contentWidth: row.width
        interactive: expanded
//        clip: true

        rebound: Transition {
            NumberAnimation {
                properties: "x"
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        IndicatorsRow {
            id: row
            enabled: false
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
        }

        Behavior on contentX { enabled: !expanded; NumberAnimation { duration: 1000 } }
    }

    states: [
        State {
            name: "minimized"
            when: !expanded
            PropertyChanges {
                target: d
                rowOffset: 0
            }
            PropertyChanges {
                target: flickable
                contentX: row.width - flickable.width > 0 ? row.width - flickable.width : 0
            }
            PropertyChanges {
                target: row
                anchors.rightMargin: row.width - flickable.width < 0 ? row.width - flickable.width : 0
            }
        },
        State {
            name: "expanded"
            when: expanded

            PropertyChanges {
                target: d
                rowOffset: {
                    if (!initialItem) return 0;
                    if (distanceFromRight - initialItem.width <= 0) return 0;
                    if (originalDistanceFromRight + originalItemWidth/2 > flickable.width)
                        return distanceFromRight - originalDistanceFromRight + initialItem.width/2;

                    var rowOffset = distanceFromRight - originalDistanceFromRight;
                    console.log(originalDistanceFromRight + "    flickable.width: " +flickable.width)
                    return rowOffset;
                }
            }
            PropertyChanges {
                target: flickable
                contentX: {
                    var cX = row.width - flickable.width > 0 ? row.width - flickable.width : 0
                    if (cX !== 0) {
                        cX -= d.rowOffset;
                    }
                    return cX;
                }
            }
            PropertyChanges {
                target: row
                anchors.rightMargin: {
                    var rM = row.width - flickable.width < 0 ? row.width - flickable.width : 0;
                    if (rM !== 0) {
                        rM -= d.rowOffset;
                    }
                    return rM;
                }
            }
        }
    ]
}
