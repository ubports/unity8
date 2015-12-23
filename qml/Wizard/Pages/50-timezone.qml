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
        highlightImage.source = "file:/usr/share/libtimezonemap/ui/timezone_" + offset + ".png";
    }

    // geo coords conversion functions (adapted from libtimezonemap)
    function radians (degrees) {
      return degrees * Math.PI / 180;
    }

    function longitudeToX(longitude, map_width) {
        var xdeg_offset = -6;
        var x = (map_width * (180.0 + longitude) / 360.0) + (map_width * xdeg_offset / 180.0);
        return x;
    }

    function latitudeToY(latitude, map_height) {
        var bottom_lat = -59;
        var top_lat = 81;

        var top_per = top_lat / 180.0;
        var y = 1.25 * Math.log(Math.tan(0.25*Math.PI + 0.4 * radians(latitude)));
        var full_range = 4.6068250867599998;
        var top_offset = full_range * top_per;
        var map_range = Math.abs(1.25 * Math.log(Math.tan(0.25*Math.PI + 0.4 * radians(bottom_lat))) - top_offset);
        y = Math.abs(y - top_offset);
        y = y / map_range;
        y = y * map_height;
        return y;
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
                print("Clicked at city with coords:", longitude, latitude);
                print("Highlight at (x,y):", longitudeToX(longitude, map.width), latitudeToY(latitude, map.height));
                pinImage.x = longitudeToX(longitude, map.width) - 8;
                pinImage.y = latitudeToY(latitude, map.height) - 16;
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
            onTextChanged: {
                // reset when switching between filter modes (text/country)
                selectedTimeZone = ""
                tzList.currentIndex = -1
                highlightImage.source = ""
            }
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
            }

            width: desktopLook ? searchField.width : undefined
            height: column.height - searchField.height - column.anchors.topMargin - divider.height
            model: tzFilterModel
            delegate: tzComponent
        }

        Item {
            id: mapContainer
            visible: desktopLook
            anchors {
                left: tzList.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            Item {
                id: map
                width: units.dp(800)
                height: units.dp(410)
                anchors {
                    centerIn: parent
                }

                Image {
                    id: backgroundImage
                    source: "file:/usr/share/libtimezonemap/ui/bg.png"
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

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("Clicked map at:", mouseX, mouseY)
                    }
                }

                Image {
                    id: pinImage
                    source: "file:/usr/share/libtimezonemap/ui/pin.png"
                    visible: selectedTimeZone != ""
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
