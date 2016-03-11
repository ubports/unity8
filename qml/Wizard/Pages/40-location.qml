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

    Item {
        id: column
        anchors.fill: content
        anchors.topMargin: customMargin
        anchors.leftMargin: wideMode ? parent.leftMargin : 0
        anchors.rightMargin: wideMode ? parent.rightMargin : 0

        Item {
            id: hereCheckGroup
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: hereCheckLabel.height + hereTermsLabel.height

            Label {
                id: hereCheckLabel
                objectName: "hereCheckLabel"
                anchors {
                    left: parent.left
                    right: hereTermsCheck.left
                    top: parent.top
                    leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                    rightMargin: units.gu(2)
                }
                lineHeight: 1.2
                wrapMode: Text.WordWrap
                color: textColor
                font.weight: checked ? Font.Normal : Font.Light
                text: i18n.tr("Use GPS, Wi-Fi hotspots and mobile network anonymously to detect location (recommended)")
                property bool checked: true
            }

            Label {
                id: hereTermsLabel
                objectName: "hereTermsLabel"
                anchors {
                    left: parent.left
                    right: hereTermsCheck.left
                    top: hereCheckLabel.bottom
                    topMargin: units.gu(1)
                    leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                    rightMargin: units.gu(2)
                }

                wrapMode: Text.WordWrap
                color: textColor
                font.weight: Font.Light
                fontSize: "small"
                lineHeight: 1.2
                linkColor: UbuntuColors.orange
                text: i18n.tr("By selecting this option you agree to the Nokia HERE") + " <a href='#'>" +
                      // TRANSLATORS: "terms and conditions" is part of the sentence above
                      i18n.tr("terms and conditions") + "</a>."
                Mouse.forwardTo: hereCheckArea // clicking on the link also selects this group
                Mouse.priority: Mouse.AfterItem
                onLinkActivated: {
                    pageStack.load(Qt.resolvedUrl("here-terms.qml"));
                }
            }

            Image {
                id: hereTermsCheck
                fillMode: Image.PreserveAspectFit
                height: units.gu(1.5)
                source: "data/Tick@30.png"
                opacity: hereCheckLabel.checked ? 1 : 0
                anchors.right: parent.right
                anchors.verticalCenter: hereCheckLabel.verticalCenter
                anchors.rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
            }

            MouseArea {
                id: hereCheckArea
                anchors.fill: parent
                z: hereCheckGroup.z - 1 // so that the link can be activated
                onClicked: {
                    if (!hereCheckLabel.checked) {
                        hereCheckLabel.checked = true;
                        gpsCheckLabel.checked = false;
                        nopeCheckLabel.checked = false;
                    }
                }
            }
        }

        Rectangle {
            id: divider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: hereCheckGroup.bottom
            anchors.topMargin: units.gu(3)
            height: units.dp(1)
            color: dividerColor
        }

        Label {
            id: gpsCheckLabel
            objectName: "gpsCheckLabel"
            anchors {
                left: parent.left
                right: parent.right
                top: divider.bottom
                topMargin: units.gu(3)
                leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                rightMargin: units.gu(2)
            }
            text: i18n.tr("GPS only")
            wrapMode: Text.WordWrap
            color: textColor
            font.weight: checked ? Font.Normal : Font.Light
            width: content.width
            property bool checked: false

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!gpsCheckLabel.checked) {
                        hereCheckLabel.checked = false;
                        gpsCheckLabel.checked = true;
                        nopeCheckLabel.checked = false;
                    }
                }
            }
        }

        Image {
            fillMode: Image.PreserveAspectFit
            height: units.gu(1.5)
            source: "data/Tick@30.png"
            opacity: gpsCheckLabel.checked ? 1 : 0
            anchors.right: parent.right
            anchors.verticalCenter: gpsCheckLabel.verticalCenter
            anchors.rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
        }

        Rectangle {
            id: divider2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: gpsCheckLabel.bottom
            anchors.topMargin: units.gu(3)
            height: units.dp(1)
            color: dividerColor
        }

        Label {
            id: nopeCheckLabel
            objectName: "nopeCheckLabel"
            anchors {
                left: parent.left
                right: parent.right
                top: divider2.bottom
                topMargin: units.gu(3)
                leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                rightMargin: units.gu(2)
            }
            wrapMode: Text.WordWrap
            color: textColor
            font.weight: checked ? Font.Normal : Font.Light
            width: content.width
            text: i18n.tr("Don't use my location")
            property bool checked: false

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!nopeCheckLabel.checked) {
                        hereCheckLabel.checked = false;
                        gpsCheckLabel.checked = false;
                        nopeCheckLabel.checked = true;
                    }
                }
            }
        }

        Image {
            fillMode: Image.PreserveAspectFit
            height: units.gu(1.5)
            source: "data/Tick@30.png"
            opacity: nopeCheckLabel.checked ? 1 : 0
            anchors.right: parent.right
            anchors.verticalCenter: nopeCheckLabel.verticalCenter
            anchors.rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
        }

        Rectangle {
            id: divider3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nopeCheckLabel.bottom
            anchors.topMargin: units.gu(3)
            height: units.dp(1)
            color: dividerColor
        }

        Label {
            id: infoLabel
            anchors {
                left: parent.left
                right: parent.right
                top: divider3.bottom
                topMargin: units.gu(4)
                leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                rightMargin: column.anchors.rightMargin == 0 ? staticMargin : 0
            }
            wrapMode: Text.Wrap
            text: i18n.tr("You can change it later in System Settings.")
            color: textColor
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
                pageStack.next();
            }
        }
    }
}
