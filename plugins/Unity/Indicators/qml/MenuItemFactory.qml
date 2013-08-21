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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Unity.Indicators 0.1 as Indicators
import Unity.Indicators.Network 0.1 as ICNetwork

Item {
    id: menuFactory

    property var model: null

    property var _map:  {
        "unity.widgets.systemsettings.tablet.volumecontrol" : sliderMenu,
        "unity.widgets.systemsettings.tablet.switch"        : switchMenu,

        "com.canonical.indicator.button"    : buttonMenu,
        "com.canonical.indicator.div"       : divMenu,
        "com.canonical.indicator.section"   : sectionMenu,
        "com.canonical.indicator.progress"  : progressMenu,
        "com.canonical.indicator.slider"    : sliderMenu,
        "com.canonical.indicator.switch"    : switchMenu,

        "com.canonical.unity.slider"    : sliderMenu,
        "com.canonical.unity.switch"    : switchMenu,

        "unity.widgets.systemsettings.tablet.wifisection" : wifiSection,
        "unity.widgets.systemsettings.tablet.accesspoint" : accessPoint,
    }

    Component {
        id: sliderMenu;
        Indicators.SliderMenuItem {
            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'min-value': 'double',
                                                          'max-value': 'double',
                                                          'min-icon': 'icon',
                                                          'max-icon': 'icon'});
            }
        }
    }
    Component { id: buttonMenu; Indicators.ButtonMenuItem {} }
    Component { id: divMenu; Indicators.DivMenuItem {} }
    Component { id: sectionMenu; Indicators.SectionMenuItem {} }
    Component { id: progressMenu; Indicators.ProgressMenuItem {} }
    Component { id: standardMenu; Indicators.StandardMenuItem {} }
    Component { id: switchMenu; Indicators.SwitchMenuItem {} }
    Component {
        id: wifiSection;
        ICNetwork.WifiSection {
            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'x-canonical-busy-action': 'bool'});
            }
        }
    }
    Component {
        id: accessPoint;
        ICNetwork.AccessPoint {
            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                          'x-canonical-wifi-ap-is-secure': 'bool'});
            }
        }
    }

    function load(modelData) {
        if (modelData.type !== undefined) {
            var component = _map[modelData.type];
            if (component !== undefined) {
                return component;
            }
        } else {
            if (modelData.isSeparator) {
                return divMenu;
            }
        }
        return standardMenu;
    }
}
