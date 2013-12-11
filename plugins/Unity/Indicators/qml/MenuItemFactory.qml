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
import Unity.Indicators.Messaging 0.1 as ICMessaging
import QMenuModel 0.1 as QMenuModel
import Ubuntu.Components 0.1

Item {
    id: menuFactory

    property var menuModel: null

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
        "com.canonical.indicator.messages.sourceitem"   : groupedMessage,

        "com.canonical.unity.slider"    : sliderMenu,
        "com.canonical.unity.switch"    : switchMenu,

        "unity.widgets.systemsettings.tablet.wifisection" : wifiSection,
        "unity.widgets.systemsettings.tablet.accesspoint" : accessPoint,
    }

    Component { id: divMenu; Indicators.DivMenuItem {} }

    Component {
        id: sliderMenu;
        Indicators.SliderMenuItem {
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property var menuIndex: undefined
            property var extAttrib: menuData && menuData.ext ? menuData.ext : undefined

            text: menuData && menuData.label ? menuData.label : ""
            icon: menuData && menuData.icon ? menuData.icon : ""
            minIcon: extAttrib && extAttrib.hasOwnProperty("minIcon") ? extAttrib.minIcon : ""
            maxIcon: extAttrib && extAttrib.hasOwnProperty("maxIcon") ? extAttrib.maxIcon : ""

            minimumValue: extAttrib && extAttrib.hasOwnProperty("minValue") ? extAttrib.minValue : 0.0
            maximumValue: {
                var maximum = extAttrib && extAttrib.hasOwnProperty("maxValue") ? extAttrib.maxValue : 1.0
                if (maximum <= minimumValue) {
                        return minimumValue + 1;
                }
                return maximum;
            }
            value: menuData ? menuData.actionState : 0.0
            enabled: menuData ? menuData.sensitive : false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onChangeState: {
                menuModel.changeState(menuIndex, value);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == undefined) return;
                menuModel.loadExtendedAttributes(menuIndex, {'min-value': 'double',
                                                          'max-value': 'double',
                                                          'min-icon': 'icon',
                                                          'max-icon': 'icon'});
            }
        }
    }

    Component {
        id: buttonMenu;
        Indicators.ButtonMenuItem {
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property var menuIndex: undefined

            text: menuData && menuData.label ? menuData.label : ""
            enabled: menuData ? menuData.sensitive : false

            onActivate: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
            }
        }
    }
    Component {
        id: sectionMenu;
        Indicators.SectionMenuItem {
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label ? menuData.label : ""
        }
    }

    Component {
        id: progressMenu;
        Indicators.ProgressMenuItem {
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label ? menuData.label : ""
            icon: menuData ? menuData.icon : ""
            value : menuData ? menuData.actionState : 0.0
            enabled: menuData ? menuData.sensitive : false
        }
    }

    Component {
        id: standardMenu;
        Indicators.StandardMenuItem {
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label ? menuData.label : ""
            icon: menuData && menuData.icon ? menuData.icon : ""
            checkable: menuData ? (menuData.isCheck || menuData.isRadio) : false
            checked: checkable ? menuData.isToggled : false
            enabled: menuData ? menuData.sensitive : false

            onActivate: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
        }
    }

    Component {
        id: switchMenu;
        Indicators.SwitchMenuItem {
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label ? menuData.label : ""
            icon: menuData && menuData.icon ? menuData.icon : ""
            checked: menuData ? menuData.isToggled : false
            enabled: menuData ? menuData.sensitive : false

            onActivate: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }
        }
    }

    Component {
        id: wifiSection;
        Indicators.SectionMenuItem {
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property var menuIndex: undefined
            property var extAttrib: menuData && menuData.ext ? menuData.ext : undefined

            text: menuData && menuData.label ? menuData.label : ""
            busy: extAttrib && extAttrib.hasOwnProperty("xCanonicalBusyAction") ? extAttrib.xCanonicalBusyAction : false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == undefined) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-busy-action': 'bool'})
            }
        }
    }

    Component {
        id: accessPoint;
        ICNetwork.AccessPoint {
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property var menuIndex: undefined
            property var extAttrib: menuData && menuData.ext ? menuData.ext : undefined

            property var strengthAction: QMenuModel.UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: extAttrib && extAttrib.hasOwnProperty("xCanonicalWifiApStrengthAction") ? extAttrib.xCanonicalWifiApStrengthAction : ""
            }

            text: menuData && menuData.label ? menuData.label : ""
            secure: extAttrib && extAttrib.hasOwnProperty("xCanonicalWifiApIsSecure") ? extAttrib.xCanonicalWifiApIsSecure : false
            adHoc: extAttrib && extAttrib.hasOwnProperty("xCanonicalWifiApIsAdhoc") ? extAttrib.xCanonicalWifiApIsAdhoc : false
            checked: menuData ? menuData.isToggled : false
            signalStrength: strengthAction.valid ? strengthAction.state : 0
            enabled: menuData ? menuData.sensitive : false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onActivate: {
                menuModel.activate(menuIndex);
                shell.hideIndicatorMenu(UbuntuAnimation.BriskDuration);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == undefined) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                          'x-canonical-wifi-ap-is-secure': 'bool',
                                                          'x-canonical-wifi-ap-strength-action': 'string'});
            }
        }
    }

    Component {
        id: messageItem
        ICMessaging.MessageMenuItemFactory {
            menuModel: menuFactory.menuModel
        }
    }

    Component {
        id: groupedMessage
        ICMessaging.GroupedMessage {
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property var menuIndex: undefined
            property var extAttrib: menuData && menuData.ext ? menuData.ext : undefined

            title: menuData && menuData.label ? menuData.label : ""
            count: menuData && menuData.actionState.length > 0 ? menuData.actionState[0] : "0"
            appIcon: extAttrib && extAttrib.hasOwnProperty("icon") ? extAttrib.icon : "qrc:/indicators/artwork/messaging/default_app.svg"

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onActivateApp: {
                menuModel.activate(menuIndex, true);
                shell.hideIndicatorMenu(UbuntuAnimation.FastDuration);
            }
            onDismiss: {
                menuModel.activate(menuIndex, false);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == undefined) return;
                menuModel.loadExtendedAttributes(modelIndex, {'icon': 'icon'});
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
