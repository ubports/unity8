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

    Component {
        id: tzComponent
        ListItem {
            id: tz
            objectName: "tz"
            property QtObject tzData: null

            Label {
                id: cityLabel
                text: tzData.city
                anchors.left: parent.left
                anchors.top: parent.top
            }
            Label {
                id: timeLabel
                text: tzData.time
                anchors.right: parent.right
                anchors.top: parent.top
            }
            Label {
                id: abbrevLabel
                text: tzData.abbreviation
                anchors.right: parent.right
                anchors.top: timeLabel.bottom
            }
        }
    }

    Column {
        id: column
        spacing: units.gu(2)
        anchors.leftMargin: leftMargin
        anchors.rightMargin: rightMargin
        anchors.top: content.top
        anchors.bottom: content.bottom
        anchors.left: tzPage.left
        anchors.right: tzPage.right

        TextField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Enter your city")
        }

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: topMargin
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
                    id: mainMenu

                    model: tzFilterModel

                    delegate: Loader {
                        id: loader
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: units.gu(6)
                        asynchronous: true
                        sourceComponent: tzComponent

                        onLoaded: {
                            item.tzData = Qt.binding(function() { return model; });
                        }
                    }
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: pageStack.next()
        }
    }
}
