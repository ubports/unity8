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
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import Wizard 0.1
import Ubuntu.SystemSettings.TimeDate 1.0
import Utils 0.1 as Utils
import QtQuick.Window 2.2
import ".." as LocalComponents

LocalComponents.Page {
    id: tzPage
    objectName: "tzPage"

    title: i18n.tr("Time Zone")
    forwardButtonSourceComponent: forwardButton

    property string selectedTimeZone: ""

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
                highlightTimezone(offset);
                ListView.view.currentIndex = index;
                selectedTimeZone = timeZone;
                //print("Clicked at city with coords:", longitude, latitude);
                //print("Clicked on TZ:", timeZone);
                //print("Highlight at (x,y):", longitudeToX(longitude, map.width), latitudeToY(latitude, map.height));
                pinImage.x = Qt.binding(function() { return longitudeToX(longitude, map.width) - pinImage.width / 2; });
                pinImage.y = Qt.binding(function() { return latitudeToY(latitude, map.height) - pinImage.height; });
            }
        }
    }

    Item {
        id: column
        anchors {
            fill: content
            topMargin: units.gu(4)
            leftMargin: desktopLook ? staticMargin : 0
            rightMargin: desktopLook ? staticMargin : 0
        }

        LocalComponents.WizardTextField {
            id: searchField
            objectName: "tzFilter"
            anchors.left: parent.left
            anchors.right: !desktopLook ? parent.right : undefined
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            anchors.rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
            placeholderText: i18n.tr("Enter your city")
            inputMethodHints: Qt.ImhNoPredictiveText
            onTextChanged: resetViews();
        }

        Rectangle {
            id: divider
            anchors.left: parent.left
            anchors.right: !desktopLook ? parent.right : undefined
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
                right: !desktopLook ? parent.right : undefined
                top: divider.bottom
                bottom: parent.bottom
            }

            model: tzFilterModel
            delegate: tzComponent
        }

        Item {
            id: mapContainer
            visible: content.width > maximumContentWidth + map.width
            anchors {
                left: tzList.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: units.gu(2)
            }

            Item {
                id: map
                //width: units.dp(800)
                //height: units.dp(410)
                width: column.width - tzList.width
                height: width / 1.95
                anchors {
                    centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var x = mouse.x + map.width/60; // longitude is offset by 6 degrees
                        var y = mouse.y;
                        if (y <= 2*map.height/3) {
                            y = y * 0.80; // latitude is offset by ~20%, except the 1/3 southern hemisphere
                        }

                        var tzAndOffset = tzModel.timezoneAndOffsetAtMapPoint(x, y, Qt.size(map.width, map.height));
                        var tzId = tzAndOffset[0];
                        var offset = tzAndOffset[1];
                        print("Timezone", tzId, ", offset", offset);
                        if (tzId) {
                            resetViews();
                            tzFilterModel.country = "";
                            selectedTimeZone = tzId;
                            highlightTimezone(offset);
                        }
                    }
                }

                Image {
                    id: backgroundImage
                    source: "data/timezonemap/map.png"
                    sourceSize: Qt.size(map.width, map.height)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: false
                }

                Image {
                    id: highlightImage
                    sourceSize: Qt.size(map.width, map.height)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: false
                }

                Blend {
                    anchors.fill: map
                    cached: true
                    source: backgroundImage
                    foregroundSource: highlightImage
                }

                Image {
                    id: pinImage
                    source: "data/timezonemap/pin.png"
                    visible: x != 0 && y != 0
                    width: units.dp(8)
                    height: units.dp(16)
                    z: map.z + 1
                }
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
