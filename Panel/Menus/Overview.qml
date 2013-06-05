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
import "../../Components/ListItems" as ListItems
import "Overview"

IndicatorMenuWindow {
    id: overview

    property QtObject indicatorsModel: null

    signal menuSelected(int modelIndex)

    VisualItemModel {
        id: itemModel

        FlightModeWidget {
            anchors {
                left: parent ? parent.left : undefined
                right: parent ? parent.right : undefined
            }
            height: units.gu(8)

            ListItems.ThinDivider {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: -units.dp(1)
                }
            }
        }

        VolumeWidget {
            anchors {
                left: parent ? parent.left : undefined
                right: parent ? parent.right : undefined
            }
            height: units.gu(10)
        }

        OverviewGrid {
            model: indicatorsModel
            anchors {
                left: parent ? parent.left : undefined
                right: parent ? parent.right : undefined
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: itemModel
        interactive: false
    }
}
