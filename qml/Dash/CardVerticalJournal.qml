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

DashRenderer {
    id: genericVerticalJournal

    property alias minimumColumnSpacing: cardVerticalJournal.minimumColumnSpacing
    property alias maximumNumberOfColumns: cardVerticalJournal.maximumNumberOfColumns
    property alias columnWidth: cardVerticalJournal.columnWidth
    property alias rowSpacing: cardVerticalJournal.rowSpacing

    anchors.fill: parent

    ResponsiveVerticalJournal {
        id: cardVerticalJournal
        anchors.fill: parent
        maximumNumberOfColumns: 2
        minimumColumnSpacing: units.gu(1)
        rowSpacing: units.gu(1)
        model: genericVerticalJournal.model

        columnWidth: {
            if (genericVerticalJournal.template !== undefined) {
                switch (genericVerticalJournal.template['card-size']) {
                    case "small": return units.gu(12);
                    case "large": return units.gu(38);
                }
            }
            return units.gu(18.5);
        }

        delegate: Card {
            id: card
            objectName: "delegate" + index
            cardData: model
            template: genericVerticalJournal.template
            components: genericVerticalJournal.components

            //onClicked: cardVerticalJournal.clicked(index, tile.y)
            //onPressAndHold: cardVerticalJournal.pressAndHold(index, tile.y)
        }
    }
}
