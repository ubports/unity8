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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators
import "../Components"

Item {
    id: indicatorRow

    property QtObject currentItem : null
    readonly property int currentItemIndex: currentItem ? currentItem.ownIndex : -1
    property alias row: row
    property QtObject indicatorsModel: null
    property var visibleIndicators: defined
    property int overFlowWidth: width
    property bool showAll: false
    property real currentItemOffset: 0.0
    property real unitProgress: 0.0

    width: units.gu(40)
    height: units.gu(3)

    function setDefaultItem() {
        // The leftmost indicator
        setCurrentItem(0);
    }

    function setCurrentItem(index) {
        if (currentItemIndex !== index) {
            currentItem = rowRepeater.itemAt(index);
        }
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

        width: children.width
        height: parent.height
        anchors.right: parent.right

        Repeater {
            id: rowRepeater
            objectName: "rowRepeater"
            model: indicatorsModel ? indicatorsModel : undefined

            property int lastCount: 0
            onCountChanged: {
                if (lastCount < count) {
                    showAll = true;
                    allVisible.start();
                }
                lastCount = count;
            }

            Item {
                id: itemWrapper
                height: indicatorRow.height
                width: indicatorItem.width
                visible: indicatorItem.indicatorVisible
                opacity: 1.0 * opacityMultiplier
                y: 0
                state: "standard"

                property int ownIndex: index
                property bool highlighted: indicatorRow.state != "initial" ? ownIndex == indicatorRow.currentItemIndex : false
                property bool dimmed: indicatorRow.state != "initial" ? ownIndex != indicatorRow.currentItemIndex : false

                property bool hidden: !showAll && !highlighted && (indicatorRow.state == "locked" || indicatorRow.state == "commit")
                property bool overflow: row.width - itemWrapper.x > overFlowWidth
                property real opacityMultiplier: highlighted ? 1 : (1 - indicatorRow.unitProgress)

                IndicatorItem {
                   id: indicatorItem
                   height: parent.height

                   dimmed: itemWrapper.dimmed

                   widgetSource: model.widgetSource
                   indicatorProperties : model.indicatorProperties

                   Component.onCompleted: {
                       if (visibleIndicators == undefined) {
                           visibleIndicators = {}
                       }
                       indicatorRow.visibleIndicators[model.identifier] = indicatorVisible;
                       indicatorRow.visibleIndicatorsChanged();
                   }
                   onIndicatorVisibleChanged: {
                       if (visibleIndicators == undefined) {
                           visibleIndicators = {}
                       }
                       indicatorRow.visibleIndicators[model.identifier] = indicatorVisible;
                       indicatorRow.visibleIndicatorsChanged();

                       if (indicatorVisible) {
                           showAll = true;
                           allVisible.start();
                       }
                   }
                }

                states: [
                    State {
                        name: "standard"
                        when: !hidden && !overflow
                    },
                    State {
                        name: "overflow"
                        when: hidden || overflow
                        PropertyChanges { target: itemWrapper; opacity: 0.0 }
                    }
                ]

                transitions: [
                    Transition {
                        UbuntuNumberAnimation {
                            target: itemWrapper
                            property: "opacity"
                            duration: UbuntuAnimation.BriskDuration
                        }
                    }
                ]
            }
        }
    }

    Rectangle {
        id: highlight
        color: Theme.palette.selected.foreground
        objectName: "highlight"
        height: units.dp(2)
        anchors.top: row.bottom
        visible: indicatorRow.currentItem != null
        x: row.x + (indicatorRow.currentItem != null ? indicatorRow.currentItem.x + centerOffset : 0)
        width: indicatorRow.currentItem != null ? indicatorRow.currentItem.width : 0

        property real centerOffset: {
            if (indicatorRow.currentItemOffset > 0.1) {
                return (indicatorRow.currentItemOffset - 0.1) * units.gu(0.4);
            } else if (indicatorRow.currentItemOffset < -0.1) {
                return (indicatorRow.currentItemOffset + 0.1) * units.gu(0.4);
            }
            return 0.0;
        }

        Behavior on width {
            enabled: unitProgress > 0;
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
        }
        Behavior on x {
            enabled: unitProgress > 0;
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
        }
    }
}
