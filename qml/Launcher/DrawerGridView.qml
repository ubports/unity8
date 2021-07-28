/*
 * Copyright (C) 2016 Canonical, Ltd.
 * Copyright (C) 2020 UBports Foundation.
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
import Lomiri.Components 1.3
import "../Components"

FocusScope {
    id: root

    property int delegateWidth: units.gu(11)
    property int delegateHeight: units.gu(11)
    property alias delegate: gridView.delegate
    property alias model: gridView.model
    property alias interactive: gridView.interactive
    property alias currentIndex: gridView.currentIndex
    property alias draggingVertically: gridView.draggingVertically

    property alias header: gridView.header
    property alias topMargin: gridView.topMargin
    property alias bottomMargin: gridView.bottomMargin

    readonly property int columns: Math.floor(width / delegateWidth)
    readonly property int rows: Math.ceil(gridView.model.count / root.columns)

    property alias refreshing: pullToRefresh.refreshing
    signal refresh();

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.topMargin: units.gu(2)
        focus: true

        readonly property int overflow: width - (root.columns * root.delegateWidth)
        readonly property real spacing: Math.floor(overflow / root.columns)

        cellWidth: root.delegateWidth + spacing
        cellHeight: root.delegateHeight

        PullToRefresh {
            id: pullToRefresh
            parent: gridView
            target: gridView

            readonly property real contentY: gridView.contentY - gridView.originY
            y: -contentY - units.gu(5)

            readonly property color pullLabelColor: "white"
            style: PullToRefreshScopeStyle {
                activationThreshold: Math.min(units.gu(14), gridView.height / 5)
            }

            onRefresh: root.refresh();
        }
    }

    ProgressBar {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: refreshing
        indeterminate: true
    }

    function getFirstAppId() {
        return model.appId(0);
    }
}
