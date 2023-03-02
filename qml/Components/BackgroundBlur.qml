/*
 * Copyright (C) 2016 Canonical, Ltd.
 * Copyright (C) 2022 UBports Foundation
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

import QtQuick 2.12
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

Item {
    id: root

    property Item sourceItem
    property rect blurRect: Qt.rect(0,0,0,0)
    property bool occluding: false

    ShaderEffectSource {
        id: shaderEffectSource
        sourceItem: root.sourceItem
        hideSource: root.occluding
        sourceRect: root.blurRect
        live: false
    }

    FastBlur {
        id: fastBlur
        anchors.fill: parent
        source: shaderEffectSource
        radius: units.gu(3)
        cached: false
    }

    Timer {
        interval: 48
        repeat: root.visible
        running: repeat
        onTriggered: shaderEffectSource.scheduleUpdate()
    }
 }
