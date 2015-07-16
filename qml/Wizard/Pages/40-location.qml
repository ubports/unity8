/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import QtQuick.Controls 1.3
import AccountsService 0.1
import QMenuModel 0.1 as QMenuModel
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.2
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "locationPage"

    title: i18n.tr("Location Services")
    forwardButtonSourceComponent: forwardButton

    readonly property bool pathSet: AccountsService.hereLicensePathValid
    skipValid: pathSet && (AccountsService.hereLicensePath === "" || termsModel.count > 0)
    skip: skipValid && (AccountsService.hereLicensePath === "" || termsModel.count === 2) // no files but . and ..

    FolderListModel {
        id: termsModel
        folder: AccountsService.hereLicensePath
        nameFilters: ["*.html"]
        showOnlyReadable: true
        showDotAndDotDot: true // so that count == 0 means we're not done scanning yet
    }

    QMenuModel.QDBusActionGroup {
        id: locationActionGroup
        objectName: "locationActionGroup"
        busType: QMenuModel.DBus.SessionBus
        busName: "com.canonical.indicator.location"
        objectPath: "/com/canonical/indicator/location"
        property variant location: action("location-detection-enabled")
        property variant gps: action("gps-detection-enabled")
        Component.onCompleted: start()
    }

    Component.onCompleted: {
        group.bindCheckable(hereCheckLabel)
        group.bindCheckable(gpsCheckLabel)
        group.bindCheckable(nopeCheckLabel)
    }

    ExclusiveGroup {
        id: group
    }

    Item {
        id: column
        anchors.fill: content
        anchors.topMargin: units.gu(4)

        Label {
            id: hereCheckLabel
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                rightMargin: rightMargin
            }

            wrapMode: Text.WordWrap
            color: "#525252"
            font.weight: checked ? Font.Normal : Font.Light
            text: i18n.tr("Use GPS, Wi-Fi hotspots and mobile network anonymously to detect location (recommended)")
            property bool checked: true

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!hereCheckLabel.checked)
                        hereCheckLabel.checked = true
                }
            }
        }

        Label {
            id: hereTermsLabel
            anchors {
                left: parent.left
                right: parent.right
                top: hereCheckLabel.bottom
                topMargin: units.gu(1)
                rightMargin: rightMargin
            }

            wrapMode: Text.WordWrap
            color: "#525252"
            font.weight: Font.Light
            fontSize: "small"
            linkColor: UbuntuColors.orange
            text: i18n.tr("By selecting this option you agree to the Nokia HERE <a href='#'>terms and conditions</a>.")
            onLinkActivated: pageStack.load(Qt.resolvedUrl("here-terms.qml"))
        }

        Image {
            fillMode: Image.PreserveAspectFit
            height: nopeCheckLabel.height
            source: "image://theme/tick"
            opacity: hereCheckLabel.checked ? 1 : 0
            anchors.right: parent.right
            anchors.verticalCenter: hereCheckLabel.verticalCenter
        }

        Label {
            id: gpsCheckLabel
            anchors {
                left: parent.left
                right: parent.right
                top: hereTermsLabel.bottom
                topMargin: units.gu(3)
                rightMargin: rightMargin
            }
            text: i18n.tr("GPS only")
            wrapMode: Text.WordWrap
            color: "#525252"
            font.weight: checked ? Font.Normal : Font.Light
            width: content.width
            property bool checked: false

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!gpsCheckLabel.checked)
                        gpsCheckLabel.checked = true
                }
            }
        }

        Image {
            fillMode: Image.PreserveAspectFit
            height: nopeCheckLabel.height
            source: "image://theme/tick"
            opacity: gpsCheckLabel.checked ? 1 : 0
            anchors.right: parent.right
            anchors.verticalCenter: gpsCheckLabel.verticalCenter
        }

        Label {
            id: nopeCheckLabel
            anchors {
                left: parent.left
                right: parent.right
                top: gpsCheckLabel.bottom
                topMargin: units.gu(3)
                rightMargin: rightMargin
            }
            wrapMode: Text.WordWrap
            color: "#525252"
            font.weight: checked ? Font.Normal : Font.Light
            width: content.width
            text: i18n.tr("Don't use my location")
            property bool checked: false

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!nopeCheckLabel.checked)
                        nopeCheckLabel.checked = true
                }
            }
        }

        Image {
            fillMode: Image.PreserveAspectFit
            height: nopeCheckLabel.height
            source: "image://theme/tick"
            opacity: nopeCheckLabel.checked ? 1 : 0
            anchors.right: parent.right
            anchors.verticalCenter: nopeCheckLabel.verticalCenter
        }

        Label {
            id: infoLabel
            anchors {
                left: parent.left
                right: parent.right
                top: nopeCheckLabel.bottom
                topMargin: units.gu(3)
            }
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: i18n.tr("You can change it later in <em>System Settings</em>.")
            color: "#525252"
            fontSize: "small"
            font.weight: Font.Light
            width: content.width
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: {
                var locationOn = gpsCheckLabel.checked || hereCheckLabel.checked;
                var gpsOn = gpsCheckLabel.checked || hereCheckLabel.checked;
                var hereOn = hereCheckLabel.checked;

                // location service doesn't currently listen to updateState
                // requests, so we activate the actions if needed.
                if (locationActionGroup.location.state != locationOn) {
                    locationActionGroup.location.activate();
                }
                if (locationActionGroup.gps.state != gpsOn) {
                    locationActionGroup.gps.activate();
                }
                AccountsService.hereEnabled = hereOn;
                pageStack.next()
            }
        }
    }
}
