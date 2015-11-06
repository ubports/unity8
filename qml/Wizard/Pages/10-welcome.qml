/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.SystemSettings.LanguagePlugin 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "languagePage"

    title: i18n.tr("Hi!")
    forwardButtonSourceComponent: forwardButton

    UbuntuLanguagePlugin {
        id: plugin
    }

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(1)

        Label {
            id: label1
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Welcome to your Ubuntu phone.")
        }

        Label {
            id: label2
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Let’s get started.")
        }

        Item { // spacer
            height: units.gu(2)
            width: units.gu(1) // needed else it will be ignored
        }

        ComboButton {
            id: combo
            objectName: "languageCombo"
            anchors.left: parent.left
            anchors.right: parent.right
            text: listview.currentItem.text
            onClicked: expanded = !expanded
            expandedHeight: column.height - combo.y
            UbuntuListView {
                id: listview
                model: plugin.languageNames
                currentIndex: plugin.currentLanguage
                delegate: Standard {
                    objectName: "languageDelegate" + index
                    text: modelData
                    onClicked: {
                        listview.currentIndex = index
                        combo.expanded = false
                        i18n.language = plugin.languageCodes[index]
                    }
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Continue")
            onClicked: {
                if (plugin.currentLanguage !== listview.currentIndex) {
                    plugin.currentLanguage = listview.currentIndex;
                    System.updateSessionLanguage(plugin.languageCodes[listview.currentIndex]);
                    i18n.language = i18n.language; // re-notify of change after above call (for qlocale change)
                }
                pageStack.next()
            }
        }
    }
}
