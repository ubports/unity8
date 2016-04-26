/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Application 0.1

Column {
    id: root
    property string appId
    property bool checked: false

    function createSurface() {
        if (d.application) {
            d.application.createSurface();
        }
    }

    enabled: appId !== "unity8-dash"

    onCheckedChanged: {
        if (d.bindGuard) { return; }
        d.bindGuard = true;

        if (checked) {
            ApplicationManager.startApplication(root.appId);
        } else {
            ApplicationManager.stopApplication(root.appId);
        }
        d.bindGuard = false;
    }

    RowLayout {

        QtObject {
            id: d
            property bool bindGuard: false
            property var application: null
            Component.onCompleted: {
                application = ApplicationManager.findApplication(root.appId);
            }
        }

        Connections {
            target: ApplicationManager
            onCountChanged: {
                d.application = ApplicationManager.findApplication(root.appId);
            }
        }

        Layout.fillWidth: true
        CheckBox {
            id: checkbox
            checked: false
            activeFocusOnPress: false

            onTriggered: {
                if (d.bindGuard) { return; }
                d.bindGuard = true;

                if (checked) {
                    ApplicationManager.startApplication(root.appId);
                } else {
                    ApplicationManager.stopApplication(root.appId);
                }
                d.bindGuard = false;
            }
            onCheckedChanged: {
                if (d.bindGuard) { return; }
                d.bindGuard = true;

                root.checked = checked;

                d.bindGuard = false;
            }
            Binding {
                target: checkbox
                property: "checked"
                value: d.application != null
            }
        }
        Label {
            id: appIdLabel
            text: root.appId
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            color: {
                if (d.application) {
                    if (d.application.state === ApplicationInfoInterface.Starting) {
                        return "yellow";
                    } else if (d.application.state === ApplicationInfoInterface.Running) {
                        return "green";
                    } else if (d.application.state === ApplicationInfoInterface.Suspended) {
                        return "blue";
                    } else {
                        return "darkred";
                    }
                } else {
                    return "darkred";
                }
            }
            width: height
            height: appIdLabel.height * 0.7
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            width: height
            height: appIdLabel.height * 0.7
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.createSurface()
            enabled: d.application && d.application.state === ApplicationInfoInterface.Running
            visible: enabled
            Label {
                text: "➕"
                color: "white"
                anchors.centerIn: parent
            }
        }
    }
    Repeater {
        model: d.application ? d.application.surfaceList : null
        RowLayout {
            spacing: units.gu(1)
            Label {
                color: "white"
                text: "- " + model.surface.name
            }
            MouseArea {
                width: height
                height: appIdLabel.height * 0.7
                anchors.verticalCenter: parent.verticalCenter
                enabled: model.surface.live
                visible: enabled
                onClicked: model.surface.setLive(false);
                Label {
                    text: "⛒"
                    color: "white"
                    anchors.centerIn: parent
                }
            }
        }
    }
}
