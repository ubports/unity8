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
import Utils 0.1 as Utils
import ".." as LocalComponents

LocalComponents.Page {
    id: tzPage
    objectName: "tzPage"

    title: i18n.tr("Time Zone")
    forwardButtonSourceComponent: forwardButton

    property string selectedTimeZone: ""

    UbuntuTimeDatePanel {
        id: timeDatePanel
        filter: searchField.text
    }

    Component.onCompleted: {
        if (tzList.count == 1) { // preselect the first (and only) TZ
            var tz = tzList.itemAt(0,0);
            if (!!tz) {
                tz.clicked();
            }
        }

        theme.palette.normal.backgroundText = textColor
    }

    Component {
        id: tzComponent
        ListItem {
            id: tz
            objectName: "tz"
            highlightColor: backgroundColor
            divider.colorFrom: dividerColor
            divider.colorTo: backgroundColor
            readonly property bool currentTz: ListView.view.currentIndex === index

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: leftMargin
                anchors.right: image.left
                anchors.rightMargin: rightMargin
                Label {
                    id: cityLabel
                    text: displayName
                    font.weight: tz.currentTz ? Font.Normal : Font.Light
                    fontSize: "medium"
                    color: textColor
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                    width: parent.width
                }
                Label {
                    id: timeLabel
                    text: Utils.TimezoneFormatter.currentTimeInTimezoneWithAbbrev(timeZone)
                    font.weight: tz.currentTz ? Font.Normal : Font.Light
                    fontSize: "small"
                    color: textColor
                }
            }
            Image {
                id: image
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: rightMargin
                }
                fillMode: Image.PreserveAspectFit
                height: units.gu(1.5)

                source: "data/Tick@30.png"
                visible: tz.currentTz
            }

            onClicked: {
                print("Clicked index", index)
                ListView.view.currentIndex = index
                selectedTimeZone = timeZone
                print("Clicked country", country)
            }
        }
    }

    Item {
        id: column
        anchors {
            fill: content
            topMargin: customMargin
        }

        LocalComponents.WizardTextField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: leftMargin
            anchors.rightMargin: rightMargin
            placeholderText: i18n.tr("Enter your city")
            inputMethodHints: Qt.ImhNoPredictiveText
            onTextChanged: {
                // reset when switching between filter modes (text/country)
                print("Filter:", text)
                selectedTimeZone = ""
                tzList.currentIndex = -1
            }
        }

        Rectangle {
            id: divider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchField.bottom
            anchors.topMargin: units.gu(3)
            height: units.dp(1)
            color: dividerColor
            visible: tzList.count > 0
        }

        ListView {
            id: tzList;

            boundsBehavior: Flickable.StopAtBounds
            clip: true
            currentIndex: -1
            snapMode: ListView.SnapToItem

            anchors {
                left: parent.left
                right: parent.right
                top: divider.bottom
            }

            height: column.height - searchField.height - customMargin - topMargin - divider.height
            model: timeDatePanel.timeZoneModel
            delegate: tzComponent
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: selectedTimeZone != ""
            onClicked: {
                timeDatePanel.timeZone = selectedTimeZone;
                pageStack.next();
            }
        }
    }
}
