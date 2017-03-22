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
import "Spread"
import WindowManager 1.0
import Unity.Application 0.1

UbuntuShape {
    id: root

    backgroundColor: "#F2111111"
    width: screensRow.childrenRect.width + units.gu(4)

    property var screensProxy: Screens.createProxy();
    property string background

    Row {
        id: screensRow
        anchors {
            top: parent.top; topMargin: units.gu(2)
            left: parent.left; leftMargin: units.gu(2)
        }

        Repeater {
            model: screensProxy

            delegate: Item {
                height: root.height - units.gu(4)
                width: workspaces.width

                UbuntuShape {
                    id: header
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: units.gu(4)
                    backgroundColor: "white"

                    Label {
                        anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                        text: model.screen.name
                        color: UbuntuColors.ash
                    }
                }

                Workspaces {
                    id: workspaces
                    height: parent.height - header.height - units.gu(2)
                    width: {
                        var width = 0;
                        if (screensProxy.count == 1) {
                            width = Math.min(implicitWidth, root.width - units.gu(8));
                        } else {
                            width = Math.min(implicitWidth, model.screen.active ? root.width - units.gu(48) : units.gu(40))
                        }
                        return Math.max(workspaces.minimumWidth, width);
                    }

                    Behavior on width { UbuntuNumberAnimation {} }
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                    screen: model.screen
                    background: root.background

                    workspaceModel: model.screen.workspaces
                }
            }
        }
    }
}
