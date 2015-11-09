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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"
import Dash 0.1

/*!
 \brief A responsive wrapper around VerticalJournal.

 Based on defined column width, delegates are laid out in columns following
 a top-left most position rule.

 Example:
    +-----+ +-----+ +-----+
    |     | |  2  | |     |
    |     | |     | |     |
    |  1  | +-----+ |  3  |
    |     | +-----+ |     |
    |     | |     | +-----+
    +-----+ |  4  | +-----+
    +-----+ |     | |  5  |
    |  6  | +-----+ |     |
    |     |         +-----+
    +-----+
*/
Item {
    id: root

    property real minimumColumnSpacing: units.gu(1)

    property alias columnWidth: verticalJournalView.columnWidth
    property alias rowSpacing: verticalJournalView.rowSpacing
    property alias model: verticalJournalView.model
    property alias delegate: verticalJournalView.delegate
    property alias cacheBuffer: verticalJournalView.cacheBuffer
    property real displayMarginBeginning: 0
    property real displayMarginEnd: 0

    implicitHeight: verticalJournalView.implicitHeight + rowSpacing
    clip: height < implicitHeight

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

        displayMarginBeginning: -Math.max(-root.displayMarginBeginning - anchors.topMargin, 0)
        displayMarginEnd:-Math.max(-root.displayMarginEnd - anchors.topMargin, 0)

        function px2gu(pixels) {
            return Math.floor(pixels / units.gu(1))
        }

        columnSpacing: {
            // parent.width = columns * columnWidth + (columns-1) * spacing + spacing(margins)
            var expectedColumns = Math.max(1, Math.floor(parent.width / (columnWidth + minimumColumnSpacing)));
            Math.floor((parent.width - expectedColumns * columnWidth) / expectedColumns);
        }
    }
}
