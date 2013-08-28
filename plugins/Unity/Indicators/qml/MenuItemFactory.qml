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
import QMenuModel 0.1 as QMenuModel

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
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            icon: menu ? menu.icon : ""
            minIcon: menu.ext.minIcon
            maxIcon: menu.ext.maxIcon

            minimumValue: menu.ext.minValue ? menu.ext.minValue : 0.0
            maximumValue: {
                var maximum = menu.ext.maxValue ? menu.ext.maxValue : 1.0
                if (maximum <= minimumValue) {
                        return minimumValue + 1;
                }
                return maximum;
            }
            value: menu ? menu.actionState : 0.0
            enabled: menu ? menu.sensitive : false

            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'min-value': 'double',
                                                          'max-value': 'double',
                                                          'min-icon': 'icon',
                                                          'max-icon': 'icon'});
            }

            // FIXME: The interval should be [0.0 - 1.0]. Unfortunately, when
            // reaching the boundaries (0.0 or 1.0), the value is converted
            // to an integer when automatically wrapped in a variant when
            // passed to QStateAction::updateState(…). The server chokes on
            // those values, complaining that they’re not of the right type…
            onChangeState: {
                if (value == Math.round(value)) {
                    if (value >= maximumValue) {
                        model.changeState(modelIndex, maximumValue - 0.000001);
                    } else if (value <= minimumValue) {
                        model.changeState(modelIndex, minimumValue + 0.000001);
                    } else {
                        model.changeState(modelIndex, value * 1.000001);
                    }
                } else {
                    model.changeState(modelIndex, value);
                }
            }
        }
    }

    Component { id: divMenu; Indicators.DivMenuItem {} }

    Component {
        id: buttonMenu;
        Indicators.ButtonMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            enabled: menu ? menu.sensitive : false

            onActivate: model.activate(modelIndex);
        }
    }
    Component {
        id: sectionMenu;
        Indicators.SectionMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
        }
    }

    Component {
        id: progressMenu;
        Indicators.ProgressMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            icon: menu ? menu.icon : ""
            value : menu ? menu.actionState : 0.0
        }
    }

    Component {
        id: standardMenu;
        Indicators.StandardMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            icon: menu ? menu.icon : ""
            checkable: menu ? (menu.isCheck || menu.isRadio) : false
            checked: checkable ? menu.isToggled : false
            enabled: menu ? menu.sensitive : false

            onActivate: model.activate(modelIndex);
        }
    }

    Component {
        id: switchMenu;
        Indicators.SwitchMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            icon: menu ? menu.icon : ""
            checked: menu ? menu.isToggled : false
            enabled: menu ? menu.sensitive : false

            onActivate: model.activate(modelIndex);
        }
    }

    Component {
        id: wifiSection;
        Indicators.SectionMenuItem {
            property QtObject menu: null

            text: menu && menu.label ? menu.label : ""
            busy: menu ? menu.ext.xCanonicalBusyAction : false

            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'x-canonical-busy-action': 'bool'});
            }
        }
    }

    Component {
        id: accessPoint;
        ICNetwork.AccessPoint {
            property QtObject menu: null
//            property var strenthAction: QMenuModel.UnityMenuAction {
//                model: menuFactory.model ? menuFactory.model : null
//                name: menu ? menu.ext.xCanonicalWifiApStrengthAction : ""
//            }

            text: menu && menu.label ? menu.label : ""
            icon: menu ? menu.icon : ""
            secure: menu ? menu.ext.xCanonicalWifiApIsSecure : false
            adHoc: menu ? menu.ext.xCanonicalWifiApIsAdhoc : false
            checked: menu ? menu.isToggled : false
//            signalStrength: strenthAction.valid ? strenthAction.state : 0
            enabled: menu ? menu.sensitive : false

            Component.onCompleted: {
                model.loadExtendedAttributes(modelIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                          'x-canonical-wifi-ap-is-secure': 'bool',
                                                          'x-canonical-wifi-ap-strength-action': 'string'});
            }
            onActivate: model.activate(modelIndex);
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
