/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import "../Components"

FocusScope {
    id: root

    property int delegateWidth: units.gu(10)
    property int delegateHeight: units.gu(10)
    property alias delegate: gridView.delegate
    property alias model: gridView.model
    property alias interactive: gridView.interactive
    property alias currentIndex: gridView.currentIndex

    property alias header: gridView.header
    property alias topMargin: gridView.topMargin
    property alias bottomMargin: gridView.bottomMargin

    readonly property int columns: width / delegateWidth
    readonly property int rows: Math.ceil(gridView.model.count / root.columns)

    GridView {
        id: gridView
        anchors.fill: parent
        leftMargin: spacing
        focus: true

        readonly property int overflow: width - (root.columns * root.delegateWidth)
        readonly property real spacing: overflow / (root.columns)

        cellWidth: root.delegateWidth + spacing
        cellHeight: root.delegateHeight
    }
}
