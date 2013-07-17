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
import "../Components"

Item {
    id: indicatorRow

    property QtObject currentItem : null
    readonly property int currentItemIndex: currentItem ? currentItem.ownIndex : -1
    property alias row: row
    property QtObject indicatorsModel: null

    Behavior on y { StandardAnimation {} }

    width: units.gu(40)
    height: units.gu(3)

    Component.onCompleted: setDefaultItem()

    function setDefaultItem() {
        // The leftmost indicator
        var defaultItemIndex = 0
        setItem(defaultItemIndex)
    }

    function setItem(index) {
        currentItem = rowRepeater.itemAt(index)
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

            IndicatorItem {
               id: indicatorItem

               property int ownIndex: index

               widgetSource: model.widgetSource

               indicatorProperties : model.indicatorProperties
               highlighted: indicatorRow.state == "reveal" || indicatorRow.state == "locked" || indicatorRow.state == "commit" ? ownIndex == indicatorRow.currentItemIndex : false
               dimmed: { //See FIXME in Indicators regarding the "states" change
                   if (indicatorRow.state == "initial" || indicatorRow.state == "") {
                       return false;
                   } else if (indicatorRow.state == "hint") {
                       return true
                   } else {
                       return ownIndex != indicatorRow.currentItemIndex
                   }
               }
               height: indicatorRow.height
               y: {
                   //FIXME: all indicators will be initial for now.
                   if (!highlighted  && (indicatorRow.state == "locked" || indicatorRow.state == "commit")) {
                       return -indicatorRow.height
                   } else {
                       return 0
                   }
               }
               Behavior on y {
                    StandardAnimation {
                        // flow away from current index
                        duration: (rowRepeater.count - Math.abs(indicatorRow.currentItemIndex - index)) * (500/rowRepeater.count)
                    }
                }
            }
        }
    }
}
