/*
 * Copyright (C) 2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.2
import Wizard 0.1
import Ubuntu.SystemSettings.TimeDate 1.0
import ".." as LocalComponents

LocalComponents.Page {
    id: tzPage
    objectName: "tzPage"

    title: i18n.tr("Time Zone")
    forwardButtonSourceComponent: forwardButton

    property alias selectedTimeZone: tzModel.selectedZoneId

    TimeZoneModel {
        id: tzModel
    }

    TimeZoneFilterModel {
        id: tzFilterModel
        sourceModel: tzModel
        filter: searchField.text
        country: root.countryCode
    }

    Component.onCompleted: {
        print("Current i18n", i18n.language)
        theme.palette.normal.backgroundText = "#525252" // "fix" the placeholder text in the search field
    }

    Component {
        id: tzComponent
        ListItem {
            id: tz
            objectName: "tz"
            readonly property bool currentTz: !!id ? selectedTimeZone === id : false

            Column {
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    id: cityLabel
                    text: !!city ? city : ""
                    font.weight: tz.currentTz ? Font.Normal : Font.Light
                    fontSize: "medium"
                    color: "#525252"
                }
                Label {
                    id: timeLabel
                    text: !!time ? time + " " + abbreviation : ""
                    font.weight: tz.currentTz ? Font.Normal : Font.Light
                    fontSize: "small"
                    color: "#525252"
                }
            }
            Image {
                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                }
                fillMode: Image.PreserveAspectFit
                height: cityLabel.paintedHeight

                source: "image://theme/tick"
                visible: tz.currentTz
            }

            onClicked: {
                selectedTimeZone = id
                print("Selected tz: " + selectedTimeZone)
                print("Clicked country", countryCode)
            }
        }
    }

    Column {
        id: column
        anchors.fill: content
        anchors.topMargin: units.gu(4)

        TextField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Enter your city or country")
            color: UbuntuColors.lightGrey
            onTextChanged: {
                if (text == "") { // reset when switching between filter modes (text/country)
                    selectedTimeZone = ""
                }
            }
        }

        ListView {
            id: tzList;

            boundsBehavior: Flickable.StopAtBounds;
            clip: true;
            currentIndex: -1
            snapMode: ListView.SnapToItem

            anchors {
                left: parent.left;
                right: parent.right;
            }

            height: column.height - searchField.height - column.spacing - topMargin
            model: tzFilterModel
            delegate: tzComponent
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: selectedTimeZone != ""
            onClicked: {
                UbuntuTimeDatePanel.timeZone = selectedTimeZone;
                pageStack.next();
            }
        }
    }
}
