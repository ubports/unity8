/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
import Dash 0.1

// A VerticalJournal. Based on defined column width,
// delegates are spread in the horizontal space.
Item {
    property int minimumColumnSpacing: units.gu(1)

    property alias columnWidth: verticalJournalView.columnWidth
    property alias rowSpacing: verticalJournalView.rowSpacing
    property alias model: verticalJournalView.model
    property alias delegate: verticalJournalView.delegate
    property alias displayMarginBeginning: verticalJournalView.displayMarginBeginning
    property alias displayMarginEnd: verticalJournalView.displayMarginEnd
    implicitHeight: verticalJournalView.implicitHeight

    VerticalJournal {
        id: verticalJournalView
        objectName: "responsiveVerticalJournalView"
        anchors {
            fill: parent
            leftMargin: columnSpacing / 2
            rightMargin: columnSpacing / 2
            topMargin: rowSpacing / 2
            bottomMargin: rowSpacing / 2
        }
        clip: parent.height != implicitHeight

        function px2gu(pixels) {
            return Math.floor(pixels / units.gu(1))
        }

        function columnsForSpacing(spacing) {
            // parent.width = columns * columnWidth +
            //       (columns-1) * spacing + spacing(margins)
            return Math.max(1, Math.floor(parent.width / (columnWidth + spacing)))
        }

        function spacingForColumns(columns) {
            var spacingGU = px2gu((parent.width - columns * columnWidth) / columns)
            return units.gu(spacingGU)
        }

        readonly property int expectedColumns: columnsForSpacing(minimumColumnSpacing)
        columnSpacing: spacingForColumns(expectedColumns)
    }
}
