/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Ubuntu.Thumbnailer 0.1 // Register support for image://thumbnailer/ and image://albumart/
import QtQuick.Window 2.2

Window {
    visible: true
    title: i18n.tr("Scopes")

    width: initialWidth > 0 ? initialWidth : units.gu(40)
    height: initialHeight > 0 ? initialHeight : units.gu(68)

    minimumWidth: units.gu(40)
    minimumHeight: units.gu(40)

    MainView {
        anchors.fill: parent

        // Workaround bug #1475643
        headerColor: Qt.rgba(0, 0, 0, 0)

        Dash {
            anchors.fill: parent
        }
    }
}
