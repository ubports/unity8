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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1 as Components
import Unity.Indicators 0.1 as Indicators

FramedMenuItem {
    id: menuItem
    objectName: menuAction.name
    enabled: menuAction.active

    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    readonly property double value: menu ? menuAction.state : 0.0

    property QtObject d: QtObject {
        property bool enableValueConnection: true
    }

    onValueChanged: {
        // TODO: look into adding a component to manage bi-directional bindings.
        var oldEnable = d.enableValueConnection
        d.enableValueConnection = false;

        // Can't rely on binding. Slider value is assigned by user slide.
        slider.value = value;

        d.enableValueConnection = oldEnable;
    }

    control: Item {
        id: row
        width: sliderMenu.text ? units.gu(20) : menuItem.width - (2 * menuItem.__contentsMargins)
        height: slider.height

        Image {
            id: leftImage
            visible: source != ""
            anchors.left: row.left
            anchors.verticalCenter: row.verticalCenter
            height: units.gu(4)
            width: height
            source: menu.ext.minIcon
        }

        Components.Slider {
            id: slider
            anchors {
                left: leftImage.visible ? leftImage.right : row.left
                right: rightImage.visible ? rightImage.left : row.right
                leftMargin: leftImage.visible ? units.gu(0.5) : 0
                rightMargin: rightImage.visible ? units.gu(0.5) : 0
            }
            live: false

            Component.onCompleted: {
                value = menuItem.value
            }

            // FIXME: The interval should be [0.0 - 1.0]. Unfortunately, when
            // reaching the boundaries (0.0 or 1.0), the value is converted
            // to an integer when automatically wrapped in a variant when
            // passed to QStateAction::updateState(…). The server chokes on
            // those values, complaining that they’re not of the right type…
            minimumValue: menu.ext.minValue ? menu.ext.minValue * 1.000001 : 0.0000001
            maximumValue: {
                var maximum = menu.ext.maxValue ? menu.ext.maxValue * 1.000001 : 0.9999999
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

            Connections {
                target: d.enableValueConnection ? slider : null
                onValueChanged: {
                    menuItem.changeState(slider.value);
                }
            }
        }

        Image {
            id: rightImage
            anchors.right: row.right
            anchors.verticalCenter: row.verticalCenter
            height: units.gu(4)
            width: height
            source: menu.ext.maxIcon
        }
    }

    Indicators.MenuAction {
        id: menuAction
        menu: menuItem.menu
    }
}
