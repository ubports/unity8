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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.SystemSettings.LanguagePlugin 1.0
import Wizard 0.1
import Unity.InputInfo 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "keyboardPage"

    title: i18n.tr("Hardware Keyboard")
    forwardButtonSourceComponent: forwardButton

    skip: keyboardsModel.count == 0
    skipValid: false

    UbuntuLanguagePlugin {
        id: langPlugin
    }

    KeyboardLayoutsModel {
        id: layoutsModel
        language: selectedLanguage
    }

    InputDeviceModel {
        id: keyboardsModel
        deviceFilter: InputInfo.Keyboard
        Component.onCompleted: skipValid = true;
    }

    Component.onCompleted: print("Initial language:", i18n.language)

    readonly property string selectedLanguage: langPlugin.languageCodes[langSelector.selectedIndex].split(".")[0] // chop off the codeset (.UTF-8)

    onSelectedLanguageChanged: {
        print("Selected language:", selectedLanguage)
    }

    ColumnLayout {
        id: column
        spacing: units.gu(2)

        anchors {
            fill: content
            leftMargin: wideMode ? parent.leftMargin : 0
            rightMargin: wideMode ? parent.rightMargin : 0
            topMargin: wideMode ? parent.customMargin : 0
            bottomMargin: units.gu(2)
        }

        ItemSelector {
            id: langSelector
            anchors.left: parent.left
            anchors.right: parent.right
            //text: i18n.tr("Keyboard Language")
            model: langPlugin.languageNames
            selectedIndex: langPlugin.languageCodes.indexOf(i18n.language)
            onSelectedIndexChanged: {
                keyboardListView.currentIndex = -1;
                tester.text = "";
            }
        }

        ListView {
            Layout.fillHeight: true
            id: keyboardListView
            clip: true
            anchors.left: parent.left
            anchors.right: parent.right
            snapMode: ListView.SnapToItem
            model: layoutsModel
            currentIndex: -1
            opacity: langSelector.currentlyExpanded ? 0.5 : 1
            Behavior on opacity {
                UbuntuNumberAnimation {}
            }

            delegate: ListItem {
                id: itemDelegate
                objectName: "kbdDelegate" + index
                height: layout.height + (divider.visible ? divider.height : 0)
                readonly property bool isCurrent: index === ListView.view.currentIndex

                ListItemLayout {
                    id: layout
                    title.text: displayName
                    subtitle.text: layoutId
                    Image {
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        height: units.gu(1.5)
                        source: "data/Tick@30.png"
                        visible: itemDelegate.isCurrent
                    }
                }

                onClicked: {
                    keyboardListView.currentIndex = index;
                }
            }
        }

        TextField {
            id: tester
            anchors.left: parent.left
            anchors.leftMargin: column.anchors.leftMargin == 0 ? units.gu(2) : 0
            anchors.right: parent.right
            anchors.rightMargin: column.anchors.rightMargin == 0 ? units.gu(2) : 0
            placeholderText: i18n.tr("Type here to test your keyboard")
            enabled: keyboardListView.currentIndex != -1
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: keyboardListView.currentIndex != -1 ? i18n.tr("Next") : i18n.tr("Skip")
            onClicked: pageStack.next();
        }
    }
}
