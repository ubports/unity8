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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    id: tzPage
    objectName: "tzPage"

    title: i18n.tr("Time Zone")
    forwardButtonSourceComponent: forwardButton

    readonly property alias selectedTimeZone: tzModel.selectedZoneId

    TimeZoneModel {
        id: tzModel
    }

    TimeZoneFilterModel {
        id: tzFilterModel
        sourceModel: tzModel
        filter: searchField.text
    }

    Component.onCompleted: {
        theme.palette.normal.backgroundText = UbuntuColors.lightGrey // "fix" the placeholder text in the search field
    }

    Component {
        id: tzComponent
        ListItem {
            id: tz
            objectName: "tz"
            property QtObject tzData: null
            readonly property bool currentTz: !!tzData ? selectedTimeZone === tzData.id : false

            Label {
                id: cityLabel
                text: !!tzData ? tzData.city : ""
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: units.gu(3)
                font.weight: tz.currentTz ? Font.Normal : Font.Light
                fontSize: "medium"
                color: "black"
            }
            Label {
                id: timeLabel
                text: !!tzData ? tzData.time + " " + tzData.abbreviation : ""
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: units.gu(3)
                font.weight: tz.currentTz ? Font.Normal : Font.Light
                fontSize: "medium"
                color: "black"
            }
            Image {
                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                }
                fillMode: Image.PreserveAspectFit
                height: cityLabel.paintedHeight

                source: "data/tick@30.png"
                visible: tz.currentTz
            }

            onClicked: {
                tzModel.selectedZoneId = tzData.id
                print("Selected tz: " + selectedTimeZone)
            }
        }
    }

    ActivityIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: true
    }

    Column {
        id: column
        anchors.fill: content
        anchors.topMargin: units.gu(4)

        TextField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Enter your city")
            color: UbuntuColors.darkGrey
        }

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            height: column.height - searchField.height - column.spacing - topMargin
            contentHeight: contentItem.childrenRect.height
            clip: true
            flickDeceleration: 1500 * units.gridUnit / 8
            maximumFlickVelocity: 2500 * units.gridUnit / 8
            boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Repeater {
                    id: tzList
                    model: tzFilterModel
                    delegate: Loader {
                        id: loader
                        anchors.left: !!parent ? parent.left : undefined
                        anchors.right: !!parent ? parent.right : undefined
                        height: units.gu(11)
                        asynchronous: true
                        sourceComponent: tzComponent

                        onLoaded: {
                            item.tzData = Qt.binding(function() { return model; });
                            busyIndicator.running = false
                        }
                    }
                    onCountChanged: {
                        print("Displaying " + tzList.count + " items")
                    }
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: selectedTimeZone != ""
            // TODO save the timezone to system
            onClicked: pageStack.next()
        }
    }
}
