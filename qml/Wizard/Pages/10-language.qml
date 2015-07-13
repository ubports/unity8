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
import Ubuntu.Components 1.2
import Ubuntu.SystemSettings.LanguagePlugin 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "languagePage"

    title: i18n.tr("Language")
    forwardButtonSourceComponent: forwardButton

    property var detectedLangs: ["en"] // default language

    UbuntuLanguagePlugin {
        id: plugin
    }

    Connections {
        target: modemManager
        onModemsChanged: {
            print("Modems changed")
            if (simManager0.present && simManager0.preferredLanguages.length > 0) {
                detectedLangs = simManager0.preferredLanguages
            } else if (simManager1.present && simManager1.preferredLanguages.length > 0) {
                detectedLangs = simManager1.preferredLanguages
            } else {
                //detectedLangs = ["fr"]
            }

            print("Detected langs: " + detectedLangs)

            populateModel(true, detectedLangs);
        }
    }

    function populateModel(onlyDetected, detectedLangs)
    {
        model.clear()
        var index = 0;
        var selectedIndex = -1;
        var langs = LocalePlugin.languages();
        Object.keys(langs).map(function(code) { // prepare the object
            //console.log("Got language:" + code);

            if (onlyDetected) {
                if (!!detectedLangs && detectedLangs.indexOf(code) !== -1) {
                    return { "code": code, "language": langs[code] || code }
                }
            } else {
                return { "code": code, "language": langs[code] || code }
            }
            return
        })
        .sort(function(a, b) { // sort by language name
            return a.language.localeCompare(b.language);
        })
        .forEach(function(lang) { // build the model
            if (lang.code === "C") {
                return;
            }
            model.append(lang);
            if (!onlyDetected && detectedLangs.length > 0 && lang.code === detectedLangs[0]) { // preselect the first of detected languages
                selectedIndex = index;
                selectLanguage(lang.code, selectedIndex)
            }
            index++;
        });

        languagesListView.positionViewAtIndex(selectedIndex, ListView.Center)
    }

    function selectLanguage(code, index)
    {
        root.language = code
        languagesListView.currentIndex = index
    }

    Column {
        id: column
        anchors.fill: content
        anchors.bottomMargin: units.gu(1)
        spacing: units.gu(2)

        ListView {
            id: languagesListView;

            boundsBehavior: Flickable.StopAtBounds;
            clip: true;
            currentIndex: -1
            snapMode: ListView.SnapToItem

            anchors {
                left: parent.left;
                right: parent.right;
            }

            height: column.height - column.spacing

            model: ListModel {
                id: model;
            }

            delegate: ListItem {
                id: itemDelegate;

                readonly property bool isCurrent: index === ListView.view.currentIndex

                Label {
                    id: langLabel
                    text: language;

                    anchors {
                        left: parent.left;
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }

                    fontSize: "medium"
                    font.weight: itemDelegate.isCurrent ? Font.Normal : Font.Light
                    color: "#525252"
                }

                Image {
                    anchors {
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    fillMode: Image.PreserveAspectFit
                    height: langLabel.paintedHeight

                    source: "data/Tick.png"
                    visible: itemDelegate.isCurrent
                }

                onClicked: {
                    root.language = code
                    ListView.view.currentIndex = index
                    print("Selected language: " + root.language)
                    print("Current index: " + ListView.view.currentIndex)
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: root.language !== ""
            onClicked: {
                if (root.language !== plugin.languageCodes[plugin.currentLanguage]) {
                    i18n.language = i18n.language // re-notify of change after above call (for qlocale change)
                }
                pageStack.next()
            }
        }
    }
}
