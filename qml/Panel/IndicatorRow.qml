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
import "../Components/Flickables" as Flickables

Item {
    id: indicatorRow

    readonly property alias currentItem : itemView.currentItem
    readonly property alias currentItemIndex: itemView.currentIndex
    readonly property alias row: itemView
    property QtObject indicatorsModel: null
    property int overFlowWidth: width
    property bool showAll: false
    property real currentItemOffset: 0.0
    property real unitProgress: 0.0

    width: units.gu(40)
    height: units.gu(3)

    function setDefaultItem() {
        // The leftmost indicator
        setCurrentItemIndex(0);
    }

    function setCurrentItemIndex(index) {
        itemView.currentIndex = index;
    }

    function setCurrentItem(item) {
        if (item && item.hasOwnProperty("ownIndex")) {
            itemView.currentIndex = item.ownIndex;
        } else {
            itemView.currentIndex = -1;
        }
    }

    Timer {
        id: allVisible
        interval: 1000

        onTriggered: {
            showAll = false;
        }
    }

    Flickables.ListView {
        id: itemView
        objectName: "indicatorRowItems"
        interactive: false
        model: indicatorsModel ? indicatorsModel : null

        width: childrenRect.width
        height: indicatorRow.height
        anchors.right: parent.right
        orientation: ListView.Horizontal

        property int lastCount: 0
        onCountChanged: {
            if (lastCount < count) {
                showAll = true;
                allVisible.start();
            }
            lastCount = count;
        }

        delegate: Item {
            id: itemWrapper
            objectName: "item" + index
            height: indicatorRow.height
            width: indicatorItem.width
            opacity: 1 - indicatorRow.unitProgress
            y: 0
            state: "standard"

            property int ownIndex: index
            property bool highlighted: indicatorRow.unitProgress > 0 ? ListView.isCurrentItem : false
            property bool dimmed: indicatorRow.unitProgress > 0 ? !ListView.isCurrentItem : false

            property bool hidden: !showAll && !highlighted && (indicatorRow.state == "locked" || indicatorRow.state == "commit")
            property bool overflow: row.width - itemWrapper.x > overFlowWidth

            IndicatorItem {
                id: indicatorItem
                identifier: model.identifier
                height: parent.height

                dimmed: itemWrapper.dimmed

                widgetSource: model.widgetSource
                indicatorProperties : model.indicatorProperties
            }

            states: [
                State {
                    name: "standard"
                    when: !hidden && !overflow && !highlighted
                },
                State {
                    name: "highlighted"
                    when: highlighted
                    PropertyChanges { target: itemWrapper; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: hidden || overflow
                    PropertyChanges { target: itemWrapper; opacity: 0.0 }
                }
            ]

            Behavior on opacity { UbuntuNumberAnimation { duration: UbuntuAnimation.BriskDuration } }
        }
    }


    Rectangle {
        id: highlight
        color: Theme.palette.selected.foreground
        objectName: "highlight"
        height: units.dp(2)
        anchors.top: row.bottom
        visible: indicatorRow.currentItem != null

        property real intendedX: row.x + (indicatorRow.currentItem != null ? (indicatorRow.currentItem.x - row.originX) + centerOffset : 0)
        x: intendedX >= row.x ? (intendedX + width <= row.x + row.width ? intendedX : row.x + row.width - width) : row.x // listview boundaries
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
