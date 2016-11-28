/*
 * Copyright 2016 Canonical Ltd.
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
 */

import QtQuick 2.4
import Ubuntu.Settings.Menus 0.1 as Menus
import Ubuntu.Settings.Components 0.1
import QMenuModel 0.1
import Utils 0.1 as Utils
import Ubuntu.Components 1.3

Object {
    id: menuFactory

    property string context
    property var rootModel: null
    property var menuModel: null

    Component {
        id: applicationMenu;

        ListItem {
            property QtObject menuData: null
            property int menuIndex: -1

            height: layout.height
            enabled: menuData && menuData.sensitive || false
            divider.visible: false

            onClicked: {
                menuModel.activate(menuIndex);
            }

            Action {
                id: action
                text: menuData.label.replace("_", "&")
            }

            ListItemLayout {
                id: layout
                title.text: action.text

                Icon {
                    source: menuData && menuData.icon || ""
                    SlotsLayout.position: SlotsLayout.Leading
                    height: units.gu(3)
                }

                Label {
                    text: menuData.shortcut
                    visible: menuData.shortcut && QuickUtils.keyboardAttached
                    SlotsLayout.position: SlotsLayout.Trailing
                    color: enabled ? theme.palette.normal.backgroundSecondaryText :
                                     theme.palette.disabled.backgroundSecondaryText
                }
            }
        }
    }

    Component {
        id: submenu

        ListItem {
            property QtObject menuData: null
            property int menuIndex: -1

            height: layout.height
            enabled: menuData && menuData.sensitive || false
            divider.visible: false

            onClicked: {
                menuModel.activate(menuIndex);
            }

            Action {
                id: action
                text: menuData.label.replace("_", "&")
            }

            ListItemLayout {
                id: layout
                title.text: action.text

                Icon {
                    source: menuData && menuData.icon || ""
                    SlotsLayout.position: SlotsLayout.Leading
                    height: units.gu(3)
                }

                Icon {
                    name: "toolkit_chevron-ltr_1gu"
                    SlotsLayout.position: SlotsLayout.Trailing
                    width: units.gu(2)
                    color: enabled ? theme.palette.normal.backgroundSecondaryText :
                                     theme.palette.disabled.backgroundSecondaryText
                }
            }
        }
    }

    Component {
        id: applicationMenuSeparator;

        Menus.SeparatorMenu {
            objectName: "separatorMenu"
        }
    }

    function load(modelData) {
        if (modelData.isSeparator) {
            return applicationMenuSeparator;
        }
        if (modelData.isRadio) {
        }
        if (modelData.isCheck) {

        }
        if (modelData.hasSubmenu) {
            return submenu;
        }
        return applicationMenu;
    }
}
