/*
 * Copyright (C) 2015 Canonical, Ltd.
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

TutorialPage {
    id: root

    property var stage
    property string usageScenario

    // When on phone or tablet, fade out as the drag progresses
    opacityOverride: usageScenario === "desktop" ? 1 : 1 - stage.dragProgress * 2

    // Else on desktop, fade out when the spread is shown
    Connections {
        target: usageScenario === "desktop" ? stage : null
        ignoreUnknownSignals: true
        onSpreadShownChanged: if (stage.spreadShown && root.shown) root.hide()
    }

    mouseArea {
        anchors.rightMargin: stage.dragAreaWidth
    }

    background {
        sourceSize.height: 1916
        sourceSize.width: 1080
        source: Qt.resolvedUrl("graphics/background1.png")
    }

    arrow {
        anchors.right: root.right
        anchors.rightMargin: units.gu(2)
        anchors.verticalCenter: root.verticalCenter
        rotation: usageScenario === "desktop" ? 180 : 0
    }

    label {
        text: root.usageScenario === "desktop" ?
                    i18n.tr("Push your mouse against the right edge to view your open apps") :
                    i18n.tr("Short or long swipe from the right edge to view your open apps")
        anchors.right: arrow.left
        anchors.rightMargin: units.gu(2) - (label.width - label.contentWidth)
        anchors.verticalCenter: arrow.verticalCenter
        width: Math.min(units.gu(40), arrow.x - units.gu(4))
    }
}
