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

Item {
    id: root

    property int minimumHorizontalSpacing: units.gu(0.5)
    // property int minimumNumberOfColumns: 2 // FIXME: not implemented
    property int maximumNumberOfColumns: 6
    readonly property int columns: flow.columns
    property alias verticalSpacing: flow.verticalSpacing
    property alias horizontalSpacing: flow.horizontalSpacing
    property int referenceDelegateWidth
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    readonly property int cellWidth: referenceDelegateWidth + horizontalSpacing
    readonly property int cellHeight: referenceDelegateWidth + verticalSpacing
    property alias move: flow.move

    height: flow.height + flow.anchors.topMargin

    Flow {
        id: flow
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: margin/2
            rightMargin: margin/2
            topMargin: verticalSpacing
        }

        function pixelToGU(value) {
            return Math.floor(value / units.gu(1));
        }

        function spacingForColumns(columns) {
            // spacing between columns as an integer number of GU, the remainder goes in the margins
            var spacingGU = pixelToGU(allocatableVerticalSpace / columns);
            return units.gu(spacingGU);
        }

        function columnsForSpacing(space) {
            // minimum margin is half of the spacing
            return Math.floor((parent.width - space/2) / (referenceDelegateWidth + space));
        }

        property real allocatableVerticalSpace: parent.width - columns * referenceDelegateWidth
        property int columns: Math.min(columnsForSpacing(minimumHorizontalSpacing), maximumNumberOfColumns)
        property real horizontalSpacing: spacingForColumns(columns)
        property real verticalSpacing: horizontalSpacing
        property int margin: allocatableVerticalSpace - columns * horizontalSpacing

        Repeater {
            id: repeater
        }
    }
}
