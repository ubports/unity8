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

import QtQuick 2.4
import Ubuntu.Components 1.3
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

    // for testing
    readonly property alias tdModule: timeDatePanel

    UbuntuTimeDatePanel {
        id: timeDatePanel
    }

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
        if (tzList.count == 1) { // preselect the first (and only) TZ
            var tz = tzList.itemAt(0,0);
            if (!!tz) {
                tz.clicked();
            }
        }

        theme.palette.normal.backgroundText = "#cdcdcd";
        searchField.forceActiveFocus();
    }

    Component {
        id: tzComponent
        ListItem {
            id: tz
            objectName: "tz" + index
            highlightColor: backgroundColor
            divider.colorFrom: dividerColor
            divider.colorTo: backgroundColor
            readonly property bool currentTz: ListView.view.currentIndex === index

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                anchors.right: image.left
                anchors.rightMargin: units.gu(2)

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
                    rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
                }
                fillMode: Image.PreserveAspectFit
                height: units.gu(1.5)

                source: "data/Tick@30.png"
                visible: tz.currentTz
            }

            onClicked: {
                ListView.view.currentIndex = index;
                selectedTimeZone = timeZone;
            }
        }
    }

    Item {
        id: column
        anchors {
            fill: content
            topMargin: customMargin
            leftMargin: parent.width > maximumContentWidth ? parent.leftMargin : 0
            rightMargin: parent.width > maximumContentWidth ? parent.rightMargin : 0
        }

        LocalComponents.WizardTextField {
            id: searchField
            objectName: "tzFilter"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            anchors.rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
            placeholderText: i18n.tr("Enter your city")
            inputMethodHints: Qt.ImhNoPredictiveText
            onTextChanged: {
                // reset when switching between filter modes (text/country)
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
            id: tzList
            objectName: "tzList"
            clip: true
            currentIndex: -1
            snapMode: ListView.SnapToItem

            anchors {
                left: parent.left
                right: parent.right
                top: divider.bottom
            }

            height: column.height - searchField.height - customMargin - topMargin - divider.height
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
                timeDatePanel.timeZone = selectedTimeZone;
                pageStack.next();
            }
        }
    }
}
