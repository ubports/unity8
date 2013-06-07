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
import IndicatorsClient 0.1 as IC
import IndicatorsClient.Messaging 0.1 as ICMessaging
import IndicatorsClient.Network 0.1 as ICNetwork

Item {
    id: __menuFactory

    property QtObject menu
    property QtObject listView
    property QtObject actionGroup
    property bool isCurrentItem
    readonly property bool empty: (__loader.item !== undefined && __loader.status == Loader.Ready) ? __loader.item.state === "EMPTY" : true

    implicitHeight: (__loader.status === Loader.Ready) ? __loader.item.implicitHeight : 0

    signal selectItem(int targetIndex)

    property var _map:  {
        "unity.widgets.systemsettings.tablet.volumecontrol" : sliderMenu,
        "unity.widgets.systemsettings.tablet.switch"        : switchMenu,

        "com.canonical.indicator.button"    : buttonMenu,
        "com.canonical.indicator.div"       : divMenu,
        "com.canonical.indicator.section"   : sectionMenu,
        "com.canonical.indicator.progress"  : progressMenu,
        "com.canonical.indicator.slider"    : sliderMenu,
        "com.canonical.indicator.switch"    : switchMenu,

        "com.canonical.indicator.messages.messageitem"  : messageItem,
        "com.canonical.indicator.messages.snapdecision" : snapDecision,
        "com.canonical.indicator.messages.sourceitem"   : groupedMessage,

        "unity.widget.systemsettings.tablet.sectiontitle" : wifiSection,
        "unity.widgets.systemsettings.tablet.wifisection" : wifiSection,
        "unity.widgets.systemsettings.tablet.accesspoint" : accessPoint,
    }

    Component { id: sliderMenu; IC.SliderMenu {} }
    Component { id: switchMenu; IC.SwitchMenu {} }
    Component { id: buttonMenu; IC.ButtonMenu {} }
    Component { id: divMenu; IC.DivMenu {} }
    Component { id: sectionMenu; IC.SectionMenu {} }
    Component { id: progressMenu; IC.ProgressMenu {} }
    Component { id: messageItem; ICMessaging.MessageItem {} }
    Component { id: snapDecision; ICMessaging.SnapDecision {} }
    Component { id: groupedMessage; ICMessaging.GroupedMessage {} }
    Component { id: wifiSection; ICNetwork.WifiSection {} }
    Component { id: accessPoint; ICNetwork.AccessPoint {} }
    Component { id: indicatorMenu; IC.Menu {} }

    Loader {
        id: __loader
        anchors.fill: parent
        asynchronous: true
        sourceComponent: {
            if (!__menuFactory.menu ||  !__menuFactory.menu.extra) {
                return undefined
            }

            var widgetType = __menuFactory.menu.extra.canonical_type
            if (widgetType) {
                return _map[widgetType]
            }
            else {
                if (widgetType === "com.canonical.indicator.root") {
                   return undefined
                // Try discovery the item based on the basic properties
                } else if (menu.hasSection) {
                    return sectionMenu
                }
                else {
                    return indicatorMenu
                }
            }
            return undefined
        }

        onStatusChanged: {
            if (status == Loader.Ready) {
                item.listViewIsCurrentItem = Qt.binding(function() { return isCurrentItem; });
                item.actionGroup = Qt.binding(function() { return __menuFactory.actionGroup; });
                item.menu = Qt.binding(function() { return __menuFactory.menu; });
            }
        }
    }
}
