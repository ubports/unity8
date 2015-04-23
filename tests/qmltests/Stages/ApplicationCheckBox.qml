/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Unity.Application 0.1

RowLayout {
    id: root
    property string appId
    property alias checked: checkbox.checked

    enabled: appId !== "unity8-dash"

    Layout.fillWidth: true
    CheckBox {
        id: checkbox
        checked: false
        activeFocusOnPress: false
        property bool noop: false
        onCheckedChanged: {
            if (noop) {
                return;
            }
            if (checked) {
                var application = ApplicationManager.startApplication(root.appId);
                appConnections.target = application;
            } else {
                appConnections.target = null;
                ApplicationManager.stopApplication(root.appId);
            }
        }
    }
    Label {
        text: root.appId
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
    }

    Connections {
        id: appConnections
        onStateChanged: {
            if (target.state == ApplicationInfoInterface.Stopped) {
                checkbox.noop = true;
                checkbox.checked = false;
                checkbox.noop = false;
            }
        }
    }
}
