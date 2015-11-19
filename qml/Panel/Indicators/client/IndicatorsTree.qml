/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dededkind@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity.Indicators 0.1 as Indicators
import ".."

IndicatorBase {
    id: root

    Indicators.ModelPrinter {
        id: printer
        model: root.menuModel
    }

    Flickable {
        anchors.fill: parent
        contentHeight: all_data.height
        clip:true
        Text {
            id: all_data
            color: "white"
            text: printer.text
        }
    }
}
