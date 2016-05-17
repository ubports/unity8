/*
 * Copyright (C) 2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "keyboardPage"

    title: i18n.tr("Hardware Keyboard")
    forwardButtonSourceComponent: forwardButton

    KeyboardLayoutsModel {
        id: allLayoutsModel
    }

    ListView {
        id: keyboardListView
        clip: true
        snapMode: ListView.SnapToItem

        anchors {
            fill: content
            leftMargin: wideMode ? parent.leftMargin : 0
            rightMargin: wideMode ? parent.rightMargin : 0
            topMargin: wideMode ? parent.customMargin : 0
        }

        model: allLayoutsModel

        delegate: ListItem {
            objectName: "kbdDelegate" + index
            height: layout.height + (divider.visible ? divider.height : 0)

            ListItemLayout {
                id: layout
                title.text: displayName
                subtitle.text: layoutId
                CheckBox { SlotsLayout.position: SlotsLayout.Leading }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: true
            onClicked: pageStack.next();
        }
    }
}
