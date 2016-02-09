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

/*! Value Slider Filter Widget. */

FilterWidget {
    id: root

    implicitHeight: childrenRect.height + units.gu(2)

    Connections {
        target: widgetData
        // One would think that this is not needed since
        // we have value: widgetData.value on the slider
        // but it is, otherwise reset doesn't seem to work
        onValueChanged: {
            if (widgetData.value !== slider.value) {
                slider.value = widgetData.value;
            }
        }
    }

    Slider {
        id: slider
        objectName: "slider"

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        minimumValue: widgetData.minValue
        maximumValue: widgetData.maxValue
        value: widgetData.value
        onValueChanged: {
            widgetData.value = value;
        }
        onPressedChanged: {
            if (pressed) forceActiveFocus();
        }

        readonly property Item thumb: __internals.thumb
        readonly property real barMinusThumb: __internals.barMinusThumb
    }

    Repeater {
        objectName: "repeater"
        model: widgetData.values
        delegate: Label {
            anchors {
                top: slider.bottom
                // The slider is too tall, so move a bit up
                topMargin: -units.gu(1)
            }
            text: label
            visible: value <= widgetData.maxValue && value >= widgetData.minValue
            x: {
                var halfThumbDifference = (width - slider.thumb.width) / 2;
                var result = (value - widgetData.minValue) * slider.barMinusThumb / (widgetData.maxValue - widgetData.minValue) - halfThumbDifference;
                result = Math.max(result, 0);
                result = Math.min(result, slider.width - width);
                return units.gu(2) + result;
            }
        }
    }
}
