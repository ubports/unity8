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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import UInput 0.1
import Cursor 1.0
import "Components"

Image {
    id: root

    WallpaperResolver {
        width: root.width
        id: wallpaperResolver
    }

    source: wallpaperResolver.background

    UInput {
        id: uinput
        Component.onCompleted: createMouse();
        Component.onDestruction: removeMouse();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        spacing: units.gu(2)

        Label {
            id: text
            Layout.fillWidth: true
            text: i18n.tr("Your device is now connected to an external display.")
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSize: "x-large"
            wrapMode: Text.Wrap
        }

        UbuntuShape {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backgroundColor: "black"
            opacity: 0.4

            Image {
                anchors.centerIn: parent
                height: units.gu(2)
                width: units.gu(2)
                source: "image://cursor/default/left_ptr"
            }

            MultiPointTouchArea {
                anchors.fill: parent

                property int clickThreshold: units.gu(1.5)
                property bool isClick: false

                onPressed: {
                    if (point1.pressed && !point2.pressed && clickTimer.running) {
                        clickTimer.stop();
                        uinput.pressMouse(UInput.ButtonLeft)
                    }
                    isClick = true;
                }

                onUpdated: {
                    switch (touchPoints.length) {
                    case 1:
                        moveMouse(touchPoints);
                        return;
                    case 2:
                        scroll(touchPoints);
                        return;
                    }
                }

                onReleased: {
                    var tp = touchPoints[0]
                    if (isClick) {
                        clickTimer.scheduleClick(point1.pressed ? UInput.ButtonRight : UInput.ButtonLeft)
                    }
                    isClick = false;
                }

                Timer {
                    id: clickTimer
                    repeat: false
                    interval: 100
                    property int button: UInput.ButtonLeft
                    onTriggered: {
                        uinput.pressMouse(button);
                        uinput.releaseMouse(button);
                    }
                    function scheduleClick(button) {
                        clickTimer.button = button;
                        clickTimer.start();
                    }
                }

                function moveMouse(touchPoints) {
                    var tp = touchPoints[0];
                    if (isClick &&
                            (Math.abs(tp.x - tp.startX) > clickThreshold ||
                             Math.abs(tp.y - tp.startY) > clickThreshold)) {
                        isClick = false;
                    }

                    uinput.moveMouse(tp.x - tp.previousX, tp.y - tp.previousY);
                }

                function scroll(touchPoints) {
                    var dh = 0;
                    var dv = 0;
                    var tp = touchPoints[0];
                    if (isClick &&
                            (Math.abs(tp.x - tp.startX) > clickThreshold ||
                             Math.abs(tp.y - tp.startY) > clickThreshold)) {
                        isClick = false;
                    }
                    dh += tp.x - tp.previousX;
                    dv += tp.y - tp.previousY;

                    tp = touchPoints[1];
                    if (isClick &&
                            (Math.abs(tp.x - tp.startX) > clickThreshold ||
                             Math.abs(tp.y - tp.startY) > clickThreshold)) {
                        isClick = false;
                    }
                    dh += tp.x - tp.previousX;
                    dv += tp.y - tp.previousY;

                    uinput.scrollMouse(dh, dv);
                }

                touchPoints: [
                    TouchPoint {
                        id: point1
                    },
                    TouchPoint {
                        id: point2
                    }
                ]
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: units.gu(2)
            Button {
                Layout.fillWidth: true
                onPressedChanged: {
                    if (pressed) {
                        uinput.pressMouse(UInput.ButtonLeft)
                    } else {
                        uinput.releaseMouse(UInput.ButtonLeft)
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                onPressedChanged: {
                    if (pressed) {
                        uinput.pressMouse(UInput.ButtonRight)
                    } else {
                        uinput.releaseMouse(UInput.ButtonRight)
                    }
                }
            }
        }
    }
}
