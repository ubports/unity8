/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import "." as LocalComponents

TutorialPage {
    id: root

    property var panel

    opacityOverride: 1 - panel.indicators.unitProgress

    QtObject {
        id: d
        readonly property bool landscape: root.width > units.gu(50)
        readonly property real columnWidth: landscape ? panel.indicators.width : root.width
    }

    mouseArea {
        anchors.topMargin: panel.indicators.minimizedPanelHeight
    }

    background {
        sourceSize.height: 1916
        sourceSize.width: 1080
        source: Qt.resolvedUrl("graphics/background2.png")
    }

    arrow {
        anchors.top: root.top
        anchors.topMargin: units.gu(4)
        anchors.horizontalCenter: root.right
        anchors.horizontalCenterOffset: - d.columnWidth / 2
        rotation: -90
    }

    label {
        text: i18n.tr("Swipe from the top edge to access notifications and quick settings")
        anchors.top: arrow.bottom
        anchors.topMargin: units.gu(3)
        anchors.horizontalCenter: arrow.horizontalCenter
        anchors.horizontalCenterOffset: (label.width - label.contentWidth) / 2
        width: d.columnWidth - units.gu(8)
    }
}
