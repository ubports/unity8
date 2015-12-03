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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.SystemSettings.LanguagePlugin 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "languagePage"

    title: i18n.tr("Language")
    forwardButtonSourceComponent: forwardButton

    UbuntuLanguagePlugin {
        id: plugin
    }

    function init()
    {
        var detectedLang = "";
        // try to detect the language+country from the SIM card
        if (simManager0.present && simManager0.preferredLanguages.length > 0) {
            detectedLang = simManager0.preferredLanguages[0] + "_" + LocalePlugin.mccToCountryCode(simManager0.mobileCountryCode);
        } else if (simManager1.present && simManager1.preferredLanguages.length > 0) {
            detectedLang = simManager1.preferredLanguages[0] + "_" + LocalePlugin.mccToCountryCode(simManager1.mobileCountryCode);
        } else if (plugin.currentLanguage != -1) {
            detectedLang = plugin.languageCodes[plugin.currentLanguage].split(".")[0]; // remove the encoding part, after dot (en_US.utf8 -> en_US)
        } else {
            detectedLang = "en_US"; // fallback to default lang
        }

        // preselect the detected language
        for (var i = 0; i < plugin.languageCodes.length; i++) {
            var code = plugin.languageCodes[i].split(".")[0]; // remove the encoding part, after dot (en_US.utf8 -> en_US)
            if (detectedLang === code) {
                languagesListView.currentIndex = i;
                languagesListView.positionViewAtIndex(i, ListView.Center);
                break;
            }
        }
    }

    // splash screen (this has to be on the first page)
    Image {
        id: splashImage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        source: "data/Phone Splash Screen bkg.png"
        fillMode: Image.PreserveAspectCrop
        z: 2
        visible: opacity > 0
        Component.onCompleted: splashAnimation.start()
    }

    SequentialAnimation {
        id: splashAnimation
        PauseAnimation { duration: UbuntuAnimation.BriskDuration }
        SmoothedAnimation {
            target: splashImage
            property: "height"
            to: units.gu(16)
            duration: UbuntuAnimation.BriskDuration
        }
        NumberAnimation {
            target: splashImage
            property: 'opacity'
            from: 1
            to: 0
        }
        onStopped: init();
    }

    Column {
        id: column
        anchors.fill: content

        ListView {
            id: languagesListView
            clip: true
            snapMode: ListView.SnapToItem

            anchors {
                left: parent.left
                right: parent.right
            }

            height: column.height

            model: plugin.languageNames

            delegate: ListItem {
                id: itemDelegate
                highlightColor: backgroundColor
                readonly property bool isCurrent: index === ListView.view.currentIndex

                Label {
                    id: langLabel
                    text: modelData

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: leftMargin
                    }

                    fontSize: "medium"
                    font.weight: itemDelegate.isCurrent ? Font.Normal : Font.Light
                    color: textColor
                }

                Image {
                    anchors {
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                        rightMargin: rightMargin
                    }
                    fillMode: Image.PreserveAspectFit
                    height: units.gu(1.5)

                    source: "data/Tick@30.png"
                    visible: itemDelegate.isCurrent
                }

                onClicked: {
                    languagesListView.currentIndex = index;
                    i18n.language = plugin.languageCodes[index];
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: languagesListView.currentIndex
            onClicked: {
                if (plugin.currentLanguage !== languagesListView.currentIndex) {
                    plugin.currentLanguage = languagesListView.currentIndex;
                    System.updateSessionLocale(plugin.languageCodes[plugin.currentLanguage]);
                }
                i18n.language = plugin.languageCodes[plugin.currentLanguage]; // re-notify of change after above call (for qlocale change)
                root.countryCode = plugin.languageCodes[plugin.currentLanguage].split('_')[1].split('.')[0]; // extract the country code, save it for the timezone page

                if (simManager0.present || simManager1.present || root.seenSIMPage) // go to next page
                    pageStack.next();
                else
                    pageStack.load(Qt.resolvedUrl("sim.qml")); // show the SIM page
            }
        }
    }
}
