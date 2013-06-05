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

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../../Components/"

Item {
    id: volumeWidget

    Image {
        id: minVolumeIcon
        objectName: "minVolumeIcon"
        source: "graphics/sound_off_icon.png"
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(4)
        height: units.gu(4)

        MouseArea {
            anchors.fill: parent
            onClicked: volumeControl.volumeDown();
        }
    }

    Slider {
        id: slider
        objectName: "volumeSlider"
        anchors {
            left: minVolumeIcon.right
            right: maxVolumeIcon.left
            margins: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        live: false
        minimumValue: 0
        maximumValue: 100
        value: 50

        onValueChanged: {
            volumeControl.volume = value;
        }

        Binding {
            target: slider
            property: "value"
            value: volumeControl.volume
        }

        function formatValue(v) {
            return ""
        }
    }

    Image {
        id: maxVolumeIcon
        objectName: "maxVolumeIcon"
        source: "graphics/sound_on_icon.png"
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(4)
        height: units.gu(4)

        MouseArea {
            anchors.fill: parent
            onClicked: volumeControl.volumeUp();
        }
    }
}
