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

OpenEffect {
    property PreviewListView previewListView: null

    objectName: "openEffect"
    anchors {
        fill: parent
        bottomMargin: -bottomOverflow
    }

    enabled: gap > 0.0

    topGapPx: (1 - gap) * positionPx
    topOpacity: (1 - gap * 1.2)
    bottomGapPx: positionPx + gap * (targetBottomGapPx - positionPx)
    bottomOverflow: units.gu(20)
    live: !expansionAnimation.running

    property int targetBottomGapPx: height - units.gu(8) - bottomOverflow
    property real gap: previewListView.open ? 1.0 : 0.0

    Behavior on gap {
        NumberAnimation {
            id: expansionAnimation
            duration: 200
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!previewListView.open && !running) {
                    previewListView.onScreen = false
                }
            }
        }
    }
    Behavior on positionPx {
        enabled: previewListView.open
        UbuntuNumberAnimation {}
    }
}
