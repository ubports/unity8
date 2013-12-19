/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

Item {
    height: childrenRect.height
    width: childrenRect.width
    property variant tooltip

    property variant sliderData
    property string action
    property alias value: slider.value
    onValueChanged: {
        // TODO We should not need this but without it
        // slider.onValueChanged.connect(valueChanged) in
        // HudParametrizedActionsPage.qml doesn't work
        // Michael thinks it's related to https://bugreports.qt-project.org/browse/QTBUG-29141
    }

    onSliderDataChanged: {
        label.text = sliderData["label"]
        slider.minimumValue = sliderData["min"]
        slider.maximumValue = sliderData["max"]
        if("live" in sliderData)
            slider.live = sliderData["live"]
        // SDK Slider does not support step yet
//         slider.step = sliderData["step"]
        if("value" in sliderData)
            slider.value = sliderData["value"]
        action = sliderData["action"]
    }

    Label {
        id: label
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)
        anchors.leftMargin: units.gu(2)
        color: "white"
    }
    Slider {
        id: slider
        anchors.top: label.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)
        height: units.gu(6)
        live: true
        function realFormatValue(v) { return Math.round(v) + " %" }
        function formatValue(v) { return tooltip.target == slider ? "" : realFormatValue(v) }
        onPressedChanged: tooltip.target = pressed ? slider : undefined
    }
    BorderImage {
        source: "graphics/divider.sci"
        anchors.top: slider.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: units.gu(2)
    }
}
