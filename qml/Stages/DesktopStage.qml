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
import "../Components/PanelState"

Item {
    id: root

    anchors.fill: parent

    property alias background: wallpaper.source

    CrossFadeImage {
        id: wallpaper
        anchors.fill: parent
        sourceSize { height: root.height; width: root.width }
        fillMode: Image.PreserveAspectCrop
    }

    Connections {
        target: ApplicationManager
        onApplicationAdded: {
            // Initial placement to avoid having the window decoration behind the panel
            appRepeater.itemAt(ApplicationManager.count-1).y = units.gu(3)
            ApplicationManager.requestFocusApplication(ApplicationManager.get(ApplicationManager.count-1).appId)
        }

        onFocusRequested: {
            var appIndex = priv.indexOf(appId);
            var appDelegate = appRepeater.itemAt(appIndex);
            if (appDelegate.state === "minimized") {
                appDelegate.state = "normal"
            }
            ApplicationManager.focusApplication(appId);
        }
    }

    QtObject {
        id: priv

        readonly property string focusedAppId: ApplicationManager.focusedApplicationId
        readonly property var focusedAppDelegate: focusedAppId ? appRepeater.itemAt(indexOf(focusedAppId)) : null

        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }
    }

    Connections {
        target: PanelState
        onClose: {
            ApplicationManager.stopApplication(ApplicationManager.focusedApplicationId)
        }
        onMinimize: appRepeater.itemAt(0).state = "minimized"
        onMaximize: appRepeater.itemAt(0).state = "normal"
    }

    Binding {
        target: PanelState
        property: "buttonsVisible"
        value: priv.focusedAppDelegate !== null && priv.focusedAppDelegate.state === "maximized"
    }

    Repeater {
        id: appRepeater
        model: ApplicationManager

        delegate: Item {
            id: appDelegate
            z: ApplicationManager.count - index
            width: units.gu(60)
            height: units.gu(50)

            readonly property int minWidth: units.gu(10)
            readonly property int minHeight: units.gu(10)

            states: [
                State {
                    name: "normal"
                },
                State {
                    name: "maximized"
                    PropertyChanges { target: appDelegate; x: 0; y: 0; width: root.width; height: root.height }
                },
                State {
                    name: "minimized"
                    PropertyChanges { target: appDelegate; x: -appDelegate.width / 2; scale: units.gu(5) / appDelegate.width; opacity: 0 }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation { target: appDelegate; properties: "x,y,opacity,width,height,scale" }
                }
            ]

            WindowMoveResizeArea {
                target: appDelegate
                minWidth: appDelegate.minWidth
                minHeight: appDelegate.minHeight
                resizeHandleWidth: units.gu(0.5)

                onPressed: ApplicationManager.requestFocusApplication(model.appId)
            }

            DecoratedWindow {
                anchors.fill: parent
                application: ApplicationManager.get(index)
                active: ApplicationManager.focusedApplicationId === model.appId

                onClose: ApplicationManager.stopApplication(model.appId)
                onMaximize: appDelegate.state = (appDelegate.state == "maximized" ? "normal" : "maximized")
                onMinimize: appDelegate.state = "minimized"
            }
        }
    }
}
