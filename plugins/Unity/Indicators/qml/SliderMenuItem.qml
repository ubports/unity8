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

    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    property double value: 0.0

    property alias minIcon: leftImage.source
    property alias maxIcon: rightImage.source

    property QtObject d: QtObject {
        property bool enableValueConnection: true
    }

    signal changeState(real value)

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
        width: menuItem.text ? units.gu(20) : menuItem.width - (2 * menuItem.__contentsMargins)
        height: slider.height

        Image {
            id: leftImage
            visible: status === Image.Ready
            anchors.left: row.left
            anchors.verticalCenter: row.verticalCenter
            height: units.gu(4)
            width: height
        }

        Components.Slider {
            id: slider
            anchors {
                left: leftImage.visible ? leftImage.right : row.left
                right: rightImage.visible ? rightImage.left : row.right
                leftMargin: leftImage.visible ? units.gu(0.5) : 0
                rightMargin: rightImage.visible ? units.gu(0.5) : 0
            }
            live: true

            Component.onCompleted: {
                value = menuItem.value
            }

            minimumValue: 0.0
            maximumValue: 0.1

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
            visible: status === Image.Ready
            anchors.right: row.right
            anchors.verticalCenter: row.verticalCenter
            height: units.gu(4)
            width: height
        }
    }
}
