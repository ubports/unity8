/*
 * Copyright (C) 2013, 2015 Canonical, Ltd.
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
import QMenuModel 0.1 as QMenuModel
import Ubuntu.Components 1.3
import Wizard 0.1
import Ubuntu.Connectivity 1.0
import ".." as LocalComponents

LocalComponents.Page {
    id: wifiPage
    objectName: "wifiPage"

    title: i18n.tr("Connect to Wi‑Fi")
    forwardButtonSourceComponent: forwardButton

    readonly property bool connected: Connectivity.online

    function getExtendedProperty(object, propertyName, defaultValue) {
        if (object && object.hasOwnProperty(propertyName)) {
            return object[propertyName];
        }
        return defaultValue;
    }

    function getAPIcon(adHoc, signalStrength, secure) {
        var imageName = "nm-no-connection";

        if (adHoc) {
            imageName = "nm-adhoc";
        } else if (signalStrength == 0) {
            imageName = "nm-signal-00";
        } else if (signalStrength <= 25) {
            imageName = "nm-signal-25";
        } else if (signalStrength <= 50) {
            imageName = "nm-signal-50";
        } else if (signalStrength <= 75) {
            imageName = "nm-signal-75";
        } else if (signalStrength <= 100) {
            imageName = "nm-signal-100";
        }

        if (secure) {
            imageName += "-secure";
        }
        return imageName;
    }

    QMenuModel.UnityMenuModel {
        id: menuModel
        busName: "com.canonical.indicator.network"
        actions: { "indicator": "/com/canonical/indicator/network" }
        menuObjectPath: "/com/canonical/indicator/network/phone_wifi_settings"
    }

    Component {
        id: accessPointComponent
        ListItem {
            id: accessPoint
            objectName: "accessPoint"
            highlightColor: backgroundColor
            enabled: menuData && menuData.sensitive || false
            divider.colorFrom: dividerColor
            divider.colorTo: backgroundColor

            property QtObject menuData: null
            property var unityMenuModel: menuModel
            property var extendedData: menuData && menuData.ext || undefined
            property var strengthAction: QMenuModel.UnityMenuAction {
                model: unityMenuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalWifiApStrengthAction", "")
            }
            readonly property bool secure: getExtendedProperty(extendedData, "xCanonicalWifiApIsSecure", false)
            readonly property bool adHoc: getExtendedProperty(extendedData, "xCanonicalWifiApIsAdhoc", false)
            readonly property bool isConnected: menuData && menuData.actionState
            readonly property bool isEnterprise: getExtendedProperty(extendedData, "xCanonicalWifiApIsEnterprise", false)
            readonly property int signalStrength: strengthAction.valid ? strengthAction.state : 0
            property int menuIndex: -1

            function loadAttributes() {
                if (!unityMenuModel || menuIndex == -1) return;
                unityMenuModel.loadExtendedAttributes(menuIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                          'x-canonical-wifi-ap-is-secure': 'bool',
                                                          'x-canonical-wifi-ap-is-enterprise': 'bool',
                                                          'x-canonical-wifi-ap-strength-action': 'string'});
            }

            Icon {
                id: apIcon
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
                }
                height: units.gu(2.5)
                width: height
                name: getAPIcon(accessPoint.adHoc, accessPoint.signalStrength, accessPoint.secure)
                color: textColor
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: apIcon.right
                anchors.leftMargin: units.gu(2)
                Label {
                    id: apName
                    text: menuData && menuData.label || ""
                    font.weight: accessPoint.isConnected ? Font.Normal : Font.Light
                    fontSize: "medium"
                    color: textColor
                }
                Label {
                    id: connectedLabel
                    text: i18n.tr("Connected")
                    font.weight: Font.Light
                    fontSize: "small"
                    color: okColor
                    visible: accessPoint.isConnected
                }
            }

            onClicked: {
                unityMenuModel.activate(menuIndex);
                listview.positionViewAtBeginning();
            }
        }
    }

    ColumnLayout {
        id: column
        spacing: units.gu(2)
        anchors {
            fill: content
            topMargin: customMargin
            leftMargin: wideMode ? parent.leftMargin : 0
            rightMargin: wideMode ? parent.rightMargin : 0
        }

        Label {
            id: label
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: column.anchors.leftMargin == 0 ? staticMargin : 0
            font.weight: Font.Light
            color: "#68064d"
            wrapMode: Text.Wrap
            text: listview.count > 0 ? i18n.tr("Available Wi-Fi networks")
                                     : i18n.tr("No available Wi-Fi networks")
        }

        ListView {
            id: listview
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            model: menuModel
            Layout.fillHeight: true

            delegate: Loader {
                id: loader

                readonly property bool isAccessPoint: model.type === "unity.widgets.systemsettings.tablet.accesspoint"
                readonly property bool isConnected: item && item.menuData && item.menuData.actionState
                readonly property bool isEnterprise: item && item.isEnterprise

                height: !!sourceComponent ? (isConnected ? units.gu(9) : units.gu(7)) : 0
                anchors.left: parent.left
                anchors.right: parent.right

                asynchronous: true
                sourceComponent: {
                    if (isAccessPoint && !isEnterprise) {
                        return accessPointComponent;
                    }
                    return null;
                }

                onLoaded: {
                    item.menuData = Qt.binding(function() { return model; });
                    item.menuIndex = Qt.binding(function() { return index; });
                    item.loadAttributes();
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: (connected || listview.count === 0) ? i18n.tr("Next") : i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
