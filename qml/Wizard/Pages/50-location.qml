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

import QtQuick 2.4
import AccountsService 0.1
import QMenuModel 0.1 as QMenuModel
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.3
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "locationPage"

    title: i18n.tr("Location")
    forwardButtonSourceComponent: forwardButton

    property bool pathSet: AccountsService.hereLicensePathValid
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

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(3)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Let the phone detect your location:")
        }

        LocalComponents.CheckableSetting {
            id: gpsCheck
            objectName: "gpsCheck"
            showDivider: false
            text: i18n.tr("Using GPS only (less accurate)")
            onTriggered: {
                gpsCheck.checked = true;
                hereCheck.checked = false;
                nopeCheck.checked = false;
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            height: childrenRect.height

            LocalComponents.CheckableSetting {
                id: hereCheck
                objectName: "hereCheck"
                showDivider: false
                text: i18n.tr("Using GPS, anonymized Wi-Fi and cellular network info (recommended)")
                checked: true
                onTriggered: {
                    gpsCheck.checked = false;
                    hereCheck.checked = true;
                    nopeCheck.checked = false;
                }
            }

            Label {
                objectName: "hereTermsLink"
                anchors.left: parent.left
                anchors.leftMargin: hereCheck.labelOffset
                anchors.right: parent.right
                wrapMode: Text.Wrap
                linkColor: theme.palette.normal.foregroundText
                // Translators: HERE is a trademark for Nokia's location service, you probably shouldn't translate it
                text: i18n.tr("By selecting this option you agree to the Nokia HERE <a href='#'>terms and conditions</a>.")
                onLinkActivated: pageStack.load(Qt.resolvedUrl("here-terms.qml"))
            }
        }

        LocalComponents.CheckableSetting {
            id: nopeCheck
            objectName: "nopeCheck"
            showDivider: false
            text: i18n.tr("Not at all")
            onTriggered: {
                gpsCheck.checked = false;
                hereCheck.checked = false;
                nopeCheck.checked = true;
            }
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("You can change your mind later in <b>System Settings</b>.")
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Continue")
            onClicked: {
                var locationOn = gpsCheck.checked || hereCheck.checked;
                var gpsOn = gpsCheck.checked || hereCheck.checked;
                var hereOn = hereCheck.checked;

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
