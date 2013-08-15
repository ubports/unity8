/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

MenuItem {
    id: _sliderMenu

    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    property alias value: slider.value

    control: Slider {
        id: slider
        enabled: menuAction.valid
        width: _sliderMenu.text ? units.gu(20) : _sliderMenu.width - units.gu(4)
        anchors.verticalCenter: parent.verticalCenter
        live: false
        // FIXME: The interval should be [0.0 - 1.0]. Unfortunately, when
        // reaching the boundaries (0.0 or 1.0), the value is converted
        // to an integer when automatically wrapped in a variant when
        // passed to QStateAction::updateState(…). The server chokes on
        // those values, complaining that they’re not of the right type…
        minimumValue: menu.extra.canonical_min ? menu.extra.canonical_min * 1.000001 : 0.0000001
        maximumValue: {
            var maximum = menu.extra.canonical_max ? menu.extra.canonical_max * 1.000001 : 0.9999999
            if (maximum <= minimumValue) {
                    return minimumValue + 1;
            }
            return maximum;
        }

        // FIXME - to be deprecated in Ubuntu.Components.
        // Use this to disable the label, since there is not way to do it on the component.
        function formatValue(v) {
            return "";
        }
    }

    MenuActionBinding {
        id: menuAction
        actionGroup: _sliderMenu.actionGroup
        action: menu ? menu.action : ""
        target: slider
        property: "value"
    }
}
