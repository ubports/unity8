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
import Ubuntu.Components 1.3
import "../Components"

ListView {
    id: root
    anchors.fill: parent
    topMargin: units.gu(1)
    bottomMargin: units.gu(1)
    spacing: units.gu(1)
    clip: true
    focus: true

    onActiveFocusChanged: {
        currentIndex = -1;
        currentIndex = 0;
    }

    function getFirstAppId() {
        return model.appId(0);
    }
}
