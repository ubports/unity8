/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.3
import Ubuntu.Components 1.1
import Unity.Application 0.1

Item {
    id: root

    property alias application: applicationWindow.application
    property alias active: decoration.active

    signal requestFocus();
    signal close();
    signal maximize();
    signal minimize();

    BorderImage {
        anchors {
            fill: root
            margins: -units.gu(2)
        }
        source: "graphics/dropshadow2gu.sci"
        opacity: .3
        Behavior on opacity { UbuntuNumberAnimation {} }
    }

    WindowDecoration {
        id: decoration
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: units.gu(3)
        title: model.name
        onClose: root.close();
        onMaximize: root.maximize();
        onMinimize: root.minimize();
    }

    ApplicationWindow {
        id: applicationWindow
        anchors.fill: parent
        anchors.topMargin: units.gu(3)
        interactive: index == 0
    }
}
