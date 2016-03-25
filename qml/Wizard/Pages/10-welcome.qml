/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

    OnScreenKeyboardPlugin {
        id: oskPlugin
    }

    function init()
    {
        var detectedLang = "";
        // try to detect the language+country from the SIM card
        if (root.simManager0.present && root.simManager0.preferredLanguages.length > 0) {
            detectedLang = root.simManager0.preferredLanguages[0] + "_" + LocalePlugin.mccToCountryCode(root.simManager0.mobileCountryCode);
        } else if (root.simManager1.present && root.simManager1.preferredLanguages.length > 0) {
            detectedLang = root.simManager1.preferredLanguages[0] + "_" + LocalePlugin.mccToCountryCode(root.simManager1.mobileCountryCode);
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
                i18n.language = plugin.languageCodes[i];
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
        source: wideMode ? "data/Desktop_splash_screen_bkg.png" : "data/Phone_splash_screen_bkg.png"
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

    ListView {
        id: languagesListView
        clip: true
        snapMode: ListView.SnapToItem

        anchors {
            fill: content
            leftMargin: wideMode ? parent.leftMargin : 0
            rightMargin: wideMode ? parent.rightMargin : 0
            topMargin: wideMode ? parent.customMargin : 0
        }

        model: plugin.languageNames

        delegate: ListItem {
            id: itemDelegate
            objectName: "languageDelegate" + index
            highlightColor: backgroundColor
            divider.colorFrom: dividerColor
            divider.colorTo: backgroundColor
            readonly property bool isCurrent: index === ListView.view.currentIndex

            Label {
                id: langLabel
                text: modelData

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: languagesListView.anchors.leftMargin == 0 ? staticMargin : 0
                }

                fontSize: "medium"
                font.weight: itemDelegate.isCurrent ? Font.Normal : Font.Light
                color: textColor
            }

            Image {
                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                    rightMargin: languagesListView.anchors.rightMargin == 0 ? staticMargin : 0
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

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: languagesListView.currentIndex != -1
            onClicked: {
                if (plugin.currentLanguage !== languagesListView.currentIndex) {
                    var locale = plugin.languageCodes[languagesListView.currentIndex];
                    var language = locale.split("_")[0].split(".")[0];
                    plugin.currentLanguage = languagesListView.currentIndex;
                    oskPlugin.setCurrentLayout(language);
                    System.updateSessionLocale(locale);
                }
                i18n.language = plugin.languageCodes[plugin.currentLanguage]; // re-notify of change after above call (for qlocale change)

                if (!root.modemManager.available || !root.modemManager.ready || root.modemManager.modems.length === 0 ||
                        (root.simManager0.present && root.simManager0.ready) || (root.simManager1.present && root.simManager1.ready) ||
                        root.seenSIMPage) { // go to next page
                    pageStack.next();
                }
                else {
                    pageStack.load(Qt.resolvedUrl("sim.qml")); // show the SIM page
                }
            }
        }
    }
}
