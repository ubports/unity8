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

Item {
    id: menuWindow

    property bool shown: false
    property int contentHeight: height
    property string headingText: name
    property string name

    enabled: shown
    opacity: shown ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation {duration: shown ? 300 : 150 } }

    // don't pass any events under this screen
    MouseArea {
        anchors.fill: parent
    }
}
