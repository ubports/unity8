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
import Unity.Indicators 0.1 as Indicators

Item {
    id: indicatorRow

    property QtObject indicatorsModel: null
    property real overFlowWidth: width
    property bool showAll: false
    property bool expanded: false
    property real currentItemOffset: 0.0
    property real unitProgress: 0.0
    property var currentItem: null

    width: row.width
    height: units.gu(3)

    function indicatorAt(x, y) {
        return row.childAt(x, y);
    }

    function resetCurrentItem() {
        currentItem = null
    }

    function selectItemAt(lateralPosition) {
        var item = indicatorAt(lateralPosition, 0);
        if (item.opacity > 0) {
            currentItem = item;
        } else {
            currentItem = null;
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
                property bool overflow: row.width - x > overFlowWidth
                property bool hidden: !item.expanded && overflow

                height: parent.height
                expanded: indicatorRow.expanded
                selected: currentItem === this

                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath

                opacity: hidden ? 0.0 : 1.0
                Behavior on opacity {NumberAnimation{duration: UbuntuAnimation.SnapDuration}}
            }
        }
    }

    Rectangle {
        id: grayLine
        height: units.dp(2)
        width: parent.width
        anchors.bottom: row.bottom
        color: Theme.palette.selected.backgroundText
        opacity: 0.0
        Behavior on opacity {NumberAnimation{duration: UbuntuAnimation.SnapDuration}}
    }

    Rectangle {
        id: highlight

        // micromovements of the highlight line when user moves the finger across the items while pulling
        // the handle downwards.
        property real highlightCenterOffset: 0

        anchors.bottom: row.bottom
        height: units.dp(2)
        width: currentItem ? currentItem.width : 0
        color: Theme.palette.normal.foregroundText

        opacity: 0.0

        property real currentItemX: currentItem ? currentItem.x : 0 // having Behavior
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
            PropertyChanges { target: grayLine; opacity: 1.0 }
            PropertyChanges { target: highlight; opacity: 1.0 }
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
