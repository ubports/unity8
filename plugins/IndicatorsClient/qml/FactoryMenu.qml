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
import IndicatorsClient 0.1 as IndicatorsClient

Item {
    id: __menuFactory

    property QtObject menu
    property QtObject listView
    property QtObject actionGroup
    property bool isCurrentItem
    readonly property bool empty: (__loader.object !== undefined) ? __loader.object.state === "EMPTY" : true

    signal selectItem(int targetIndex)

    property var _map:  {
        "unity.widgets.systemsettings.tablet.volumecontrol" : "IndicatorsClient.SliderMenu",
        "unity.widgets.systemsettings.tablet.switch"        : "IndicatorsClient.SwitchMenu",
        "unity.widgets.systemsettings.tablet.switch"        : "IndicatorsClient.DashApps",

        "com.canonical.indicator.button"    : "IndicatorsClient.ButtonMenu",
        "com.canonical.indicator.div"       : "IndicatorsClient.DivMenu",
        "com.canonical.indicator.section"   : "IndicatorsClient.MenuSection",
        "com.canonical.indicator.progress"  : "IndicatorsClient.ProgressMenu",
        "com.canonical.indicator.slider"    : "IndicatorsClient.SliderMenu",
        "com.canonical.indicator.switch"    : "IndicatorsClient.SwitchMenu",

        "com.canonical.indicator.messages.messageitem"  : "IndicatorsClient.Messaging.MessageItem",
        "com.canonical.indicator.messages.snapdecision" : "IndicatorsClient.Messaging.SnapDecision",
        "com.canonical.indicator.messages.sourceitem"   : "IndicatorsClient.Messaging.GroupedMessage",

        "unity.widget.systemsettings.tablet.sectiontitle" : "IndicatorsClient.Network.WifiSection",
        "unity.widgets.systemsettings.tablet.wifisection" : "IndicatorsClient.Network.WifiSection",
        "unity.widgets.systemsettings.tablet.accesspoint" : "IndicatorsClient.Network.Accesspoint",
    }

    function get_qml_string(type) {
        return "import QtQuick 2.0; import IndicatorsClient 0.1 as IndicatorsClient; " + type + " {}";
    }

    QtObject {
        id: __loader

        property var object: {
            if (!__menuFactory.menu ||  !__menuFactory.menu.extra) {
                return undefined
            }

            var tmp_object = undefined
            var widgetType = __menuFactory.menu.extra.canonical_type
            if (widgetType) {
                var component_type = _map[widgetType]
                if (component_type != undefined) {
                    tmp_object = Qt.createQmlObject(get_qml_string(component_type), __menuFactory)
                }
            }
            if (tmp_object == undefined) {
                if (widgetType === "com.canonical.indicator.root") {
                    tmp_object = undefined
                // Try discovery the item based on the basic properties
                } else if (menu.hasSection) {
                    tmp_object = Qt.createQmlObject(get_qml_string("IndicatorsClient.SectionMenu"), __menuFactory)
                } else {
                    tmp_object = Qt.createQmlObject(get_qml_string("IndicatorsClient.Menu"), __menuFactory)
                }
            }
            if (tmp_object != undefined) {
                tmp_object.listViewIsCurrentItem = Qt.binding(function() { return isCurrentItem; });
                tmp_object.actionGroup = Qt.binding(function() { return __menuFactory.actionGroup; });
                tmp_object.menu = Qt.binding(function() { return __menuFactory.menu; });
            }
            return tmp_object
        }
    }

    implicitHeight: __loader.object ? __loader.object.implicitHeight : 0
}
