/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1

/*
  NB: If you change positions or sizes here make sure
      tst_PressedOutsideNotifier.cpp is updated accordingly
 */

Rectangle {
    width: units.gu(60)
    height: units.gu(60)
    color: "white"

    Rectangle {
        id: blueRect
        objectName: "blueRect"
        color: "blue"
        x: units.gu(20)
        y: units.gu(20)
        width: units.gu(20)
        height: units.gu(20)

        Timer {
            id: resetColorTimer
            interval: 300
            repeat: false
            onTriggered: {
                blueRect.color = "blue";
            }
        }

        function blinkRed() {
            blueRect.color = "red";
            resetColorTimer.start();
        }

        PressedOutsideNotifier {
            objectName: "pressedOutsideNotifier"
            anchors.fill: parent
            onPressedOutside: {
                blueRect.blinkRed();
            }
        }
    }
}
