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
import Lomiri.Components 1.3
import WindowManager 1.0
import Cursor 1.1
import "Components"

ScreenWindow {
    id: screenWindow

    color: "black"
    title: "Lomiri Shell"
    property bool primary: false

    DeviceConfiguration {
        id: deviceConfiguration
    }

    Loader {
        id: loader
        width: screenWindow.width
        height: screenWindow.height

        sourceComponent: {
            if (Screens.count > 1 && primary && deviceConfiguration.category !== "desktop") {
                return disabledScreenComponent;
            }
            return shellComponent;
        }
    }

    Component {
        id: shellComponent
        OrientedShell {
            implicitWidth: screenWindow.width
            implicitHeight: screenWindow.height

            deviceConfiguration {
                overrideName: Screens.count > 1 ? "desktop" : false
            }
        }
    }

    Component {
        id: disabledScreenComponent
        DisabledScreenNotice {
            oskEnabled: Screens.count > 1
        }
    }
}
