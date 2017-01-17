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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ActionItem {
    id: root
    implicitHeight: units.gu(5)
    implicitWidth: requiredWidth

    property var menuData: undefined

    readonly property real requiredWidth: {
        var val = 0;
        val += units.gu(1) + flagGutter.width;
        if (iconSource != "") {
            val += units.gu(1) + icon.width
        }
        val += units.gu(1) + title.contentWidth;
        if (hasSubmenu) {
            val += units.gu(1) + chevronIcon.width;
        } else if (shortcut != undefined) {
            val += units.gu(3) + shortcutLabel.contentWidth;
        }
        return val + units.gu(1);
    }

    readonly property bool hasSubmenu: menuData ? menuData.hasSubmenu : false
    readonly property bool _checked : action && action.checkable ? action.checked : false

    enabled: menuData ? menuData.sensitive : false

    action: Action {
        // FIXME - SDK Action:text modifies menu text with html underline for mnemonic
        text: menuData.label.replace("_", "&").replace("<u>", "&").replace("</u>", "")
        checkable: menuData.isCheck || menuData.isRadio
        checked: menuData.isToggled
    }

    width: {
        if (!parent) return implicitWidth;
        if (parent.width > implicitWidth) return parent.width;
        return implicitWidth;
    }

    Keys.onRightPressed: {
        if (hasSubmenu) {
            root.trigger();
        } else {
            event.accepted = false;
        }
    }
    Keys.onReturnPressed: {
        root.trigger();
    }
    Keys.onEnterPressed: {
        root.trigger();
    }

    RowLayout {
        id: row
        spacing: units.gu(1)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        anchors.verticalCenter: parent.verticalCenter

        Item {
            Layout.minimumWidth: units.gu(1.5)
            Layout.minimumHeight: units.gu(1.5)

            Icon {
                id: flagGutter
                width: units.gu(1.5)
                height: units.gu(1.5)
                visible: _checked
                name: "tick"
            }
        }

        Icon {
            id: icon
            width: units.gu(2)
            height: units.gu(2)

            visible: root.iconSource != "" || false
            source: root.iconSource || ""
        }

        RowLayout {
            spacing: units.gu(3)

            Label {
                id: title
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
                clip: true
                Layout.fillWidth: true

                text: root.text ? root.text : ""
            }

            Label {
                id: shortcutLabel
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
                clip: true
                color: enabled ? theme.palette.normal.backgroundSecondaryText :
                                 theme.palette.disabled.backgroundSecondaryText

                visible: menuData.shortcut != undefined && !root.hasSubmenu && QuickUtils.keyboardAttached
                text: menuData.shortcut ? menuData.shortcut : ""
            }
        }

        Icon {
            id: chevronIcon
            width: units.gu(2)
            height: units.gu(2)
            color: enabled ? theme.palette.normal.backgroundSecondaryText :
                             theme.palette.disabled.backgroundSecondaryText

            visible: root.hasSubmenu
            name: "chevron"
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.trigger(action && action.checkable ? !action.checked : undefined);
        }
    }
}
