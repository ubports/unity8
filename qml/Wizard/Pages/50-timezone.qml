/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
    readonly property bool showingMap: wideMode && width >= units.gu(110)

    // for testing
    readonly property alias tdModule: timeDatePanel

    function highlightTimezone(offset) {
        highlightImage.source = "data/timezonemap/timezone_" + offset + ".png";
    }

    // geo coords conversion functions (adapted from libtimezonemap)
    function radians(degrees) {
        return degrees * Math.PI / 180;
    }

    function longitudeToX(longitude, map_width) {
        const xdeg_offset = -6;
        const x = (map_width * (180.0 + longitude) / 360.0) + (map_width * xdeg_offset / 180.0);
        return x;
    }

    function latitudeToY(latitude, map_height) {
        const bottom_lat = -59;
        const top_lat = 81;
        const top_per = top_lat / 180.0;

        var y = 1.25 * Math.log(Math.tan(0.25*Math.PI + 0.4 * radians(latitude)));
        const full_range = 4.6068250867599998;
        const top_offset = full_range * top_per;
        const map_range = Math.abs(1.25 * Math.log(Math.tan(0.25*Math.PI + 0.4 * radians(bottom_lat))) - top_offset);
        y = Math.abs(y - top_offset);
        y = y / map_range;
        y = y * map_height;
        return y;
    }

    function resetViews() {
        selectedTimeZone = ""
        tzList.currentIndex = -1
        highlightImage.source = ""
        pinImage.x = 0;
        pinImage.y = 0;
    }

    UbuntuTimeDatePanel {
        id: timeDatePanel
    }

    onContentAnimationRunningChanged: {
        if (!contentAnimationRunning) {
            if (tzList.count == 1) { // preselect the first (and only) TZ
                var tz = tzList.itemAt(0,0);
                if (!!tz) {
                    tz.clicked();
                }
            }

            resetViews();
            searchField.forceActiveFocus();
        }
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
                anchors.leftMargin: !wideMode ? staticMargin : 0
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
                    rightMargin: !wideMode ? staticMargin : 0
                }
                fillMode: Image.PreserveAspectFit
                height: units.gu(1.5)

                source: "data/Tick@30.png"
                visible: tz.currentTz
            }

            onClicked: {
                highlightTimezone(offset);
                ListView.view.currentIndex = index;
                selectedTimeZone = timeZone;
                //print("Clicked at city with coords:", longitude, latitude);
                //print("Clicked on TZ:", timeZone);
                //print("Highlight at (x,y):", longitudeToX(longitude, map.width), latitudeToY(latitude, map.height));
                pinImage.x = Qt.binding(function() { return longitudeToX(longitude, map.width) - pinImage.width; });
                pinImage.y = Qt.binding(function() { return latitudeToY(latitude, map.height) - pinImage.height; });
            }
        }
    }


    ColumnLayout {
        id: leftColumn
        anchors {
            left: content.left
            top: content.top
            bottom: content.bottom
            right: !showingMap ? content.right : undefined
            leftMargin: showingMap ? staticMargin : (wideMode ? tzPage.leftMargin : 0)
            rightMargin: showingMap ? staticMargin : (wideMode ? tzPage.rightMargin : 0)
            topMargin: customMargin
        }

        width: Math.min(parent.width, units.gu(34))

        LocalComponents.WizardTextField {
            id: searchField
            objectName: "tzFilter"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: !showingMap && !wideMode ? staticMargin : undefined
            anchors.rightMargin: !showingMap && !wideMode ? staticMargin : undefined
            placeholderText: i18n.tr("Enter your city")
            inputMethodHints: Qt.ImhNoPredictiveText
            onTextChanged: resetViews();
        }

        ListView {
            Layout.fillHeight: true
            id: tzList
            objectName: "tzList"
            clip: true
            anchors.left: parent.left
            anchors.right: parent.right
            currentIndex: -1
            model: TimeZoneModel {
                id: timeZoneModel
                filter: searchField.text
                country: i18n.language.split('_')[1].split('.')[0]
            }
            delegate: tzComponent
        }

        ActivityIndicator {
            anchors.centerIn: tzList
            running: tzList.count == 0 &&
                     searchField.length > 0 &&
                     timeZoneModel.listUpdating
            visible: running
        }
    }

    Item {
        id: mapContainer
        visible: showingMap && !contentAnimationRunning
        enabled: visible

        anchors {
            left: leftColumn.right
            leftMargin: units.gu(4)
            right: content.right
            rightMargin: staticMargin
            top: content.top
            topMargin: customMargin
            bottom: parent.bottom
            bottomMargin: buttonBarHeight
        }

        Item {
            id: map
            width: Math.min(parent.width, height * 1.95) // keep our aspect ratio
            height: parent.height
            anchors {
                centerIn: parent
            }

            Image {
                id: backgroundImage
                source: "data/timezonemap/map.png"
                sourceSize: Qt.size(map.width, map.height)
                fillMode: Image.PreserveAspectFit
                smooth: false
                visible: mapContainer.visible
                asynchronous: true
                anchors.fill: parent
            }

            Image {
                id: highlightImage
                sourceSize: Qt.size(map.width, map.height)
                fillMode: Image.PreserveAspectFit
                smooth: false
                visible: selectedTimeZone != ""
                asynchronous: true
                anchors.fill: backgroundImage
            }

            Image {
                id: pinImage
                source: "data/timezonemap/pin.png"
                visible: x != 0 && y != 0
                width: units.dp(12)
                height: units.dp(20)
                z: map.z + 1
            }
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
