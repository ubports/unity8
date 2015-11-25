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

    Slider {
        id: slider
        objectName: "slider"

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            left: parent.left
            right: parent.right
        }

        minimumValue: widgetData.minValue
        maximumValue: widgetData.maxValue
        value: widgetData.value
        onValueChanged: {
            widgetData.value = value;
        }

        // TODO SDK
        readonly property Item bar: __styleInstance ? __styleInstance.bar : null
        readonly property Item thumb: __styleInstance ? __styleInstance.thumb :  null
        readonly property real thumbSpacing: __styleInstance ? __styleInstance.thumbSpacing : 0
        readonly property real barMinusThumb: bar && thumb ? bar.width - (thumb.width + 2.0*thumbSpacing) : 0.0
    }

    Repeater {
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
                result = Math.min(result, parent.width - width);
                return result;
            }
        }
    }
}
