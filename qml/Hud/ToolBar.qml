/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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
import HudClient 0.1

Row {
    signal actionTriggered(int action)
    property alias model: repeater.model

    spacing: units.gu(3)
    Repeater {
        id: repeater
        ToolBarIcon {
            source: model.iconPath
            onClicked: actionTriggered(model.action)
            enabled: model.enabled
        }
    }
}
