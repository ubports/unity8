/*
* Copyright (C) 2017 Canonical, Ltd.
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
import Lomiri.Components 1.3
import WindowManager 1.0

Instantiator {
    id: root
    model: Screens

    ScreenWindow {
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

        Loader {
            width: window.width
            height: window.height

            Rectangle {
                color: "white"
                Column {
                    spacing: units.gu(1)

                    Label {
                        text: "Unity encountered an unrecoverable error while loading:"
                        fontSize: "large"
                    }

                    Label {
                        text: errorString
                    }
                }
            }
        }
    }
}
