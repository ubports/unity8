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

    Row {
        id: row

        width: children.width
        height: parent.height
        anchors.right: parent.right

        Repeater {
            id: rowRepeater
            objectName: "rowRepeater"
            model: indicatorsModel ? indicatorsModel : undefined

            Item {
                id: itemWrapper
                height: indicatorRow.height
                width: indicatorItem.width
                visible: indicatorItem.indicatorVisible
                y: 0
                state: "standard"

                property int ownIndex: index
                property alias highlighted: indicatorItem.highlighted
                property alias dimmed: indicatorItem.dimmed

                IndicatorItem {
                   id: indicatorItem
                   height: parent.height

                   highlighted: indicatorRow.state != "initial" ? itemWrapper.ownIndex == indicatorRow.currentItemIndex : false
                   dimmed: indicatorRow.state != "initial" ? itemWrapper.ownIndex != indicatorRow.currentItemIndex : false

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
                   }
                }

                opacity: {
                    if (!indicatorItem.highlighted && (indicatorRow.state == "locked" || indicatorRow.state == "commit")) {
                        return 0.0;
                    } else {
                        return 1.0;
                    }
                }
                Behavior on opacity {
                     StandardAnimation {
                         // flow away from current index
                         duration: (rowRepeater.count - Math.abs(indicatorRow.currentItemIndex - index)) * (500/rowRepeater.count)
                     }
                 }
                states: [
                    State {
                        name: "standard"
                        when: row.width - itemWrapper.x <= overFlowWidth
                        PropertyChanges { target: itemWrapper; y: 0 }
                    },
                    State {
                        name: "overflow"
                        when: row.width - itemWrapper.x > overFlowWidth
                        PropertyChanges { target: itemWrapper; y: -indicatorRow.height }
                    }
                ]
                transitions: [
                    Transition {
                        from: "standard"; to: "overflow"
                        StandardAnimation {
                            target: itemWrapper
                            property: "y"
                        }
                    },
                    Transition {
                        from: "overflow"; to: "standard"
                        StandardAnimation {
                            target: itemWrapper
                            property: "y"
                        }
                    }
                ]
            }
        }
    }
}
