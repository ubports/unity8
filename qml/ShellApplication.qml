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
import QtQuick.Window 2.2
import WindowManager 1.0
import Unity.Application 0.1

Instantiator {
    id: root
    model: Screens

    ShellScreen {
        id: window
        objectName: "screen"+index
        screen: model.screen
        visibility:  applicationArguments.hasFullscreen ? Window.FullScreen : Window.Windowed
        flags: applicationArguments.hasFrameless ? Qt.FramelessWindowHint : 0

        Binding {
            when: applicationArguments.hasGeometry
            target: window
            property: "width"
            value: applicationArguments.windowGeometry.width
        }
        Binding {
            when: applicationArguments.hasGeometry
            target: window
            property: "height"
            value: applicationArguments.windowGeometry.height
        }

        Component.onCompleted: screen.active = primary
        primary: index == 0
    }

    property var windowManagerSurfaceManagerBinding: Binding {
        target: WindowManagerObjects
        property: "surfaceManager"
        value: SurfaceManager
    }
    property var windowManagerApplicationManagerBinding: Binding {
        target: WindowManagerObjects
        property: "applicationManager"
        value: ApplicationManager
    }
}
