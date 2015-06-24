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

import QtQuick 2.3
import Ubuntu.Components 1.2
import Ubuntu.SystemSettings.LanguagePlugin 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "languagePage"

    title: i18n.tr("Language")
    forwardButtonSourceComponent: forwardButton

    property string selectedLanguage: ""

    UbuntuLanguagePlugin {
        id: plugin
    }

    Component.onCompleted: {
        populateModel(); // FIXME pass a list of detected languages here
    }

    function populateModel(detectedLangs)
    {
        console.log("LanguagePage::populateModel: detected languages:" + detectedLangs);
        var allLangs = LocalePlugin.languages();
        if (!!detectedLangs) {
            addLanguagesToModel(detectedLangs);
            var remainingLangs = Object.keys(allLangs).filter(function(lang) {
                return (detectedLangs.indexOf(lang) === -1);
            });
            addLanguagesToModel(remainingLangs); // FIXME this assumes an array
        } else {
            addLanguagesToModel(allLangs);
        }

        busyIndicator.running = false;
        busyIndicator.visible = false;
    }

    function addLanguagesToModel(langs)
    {
        Object.keys(langs).map(function(code) { // prepare the object
            return { "code": code, "name": langs[code] };
        })
        .sort(function(a, b) { // sort by language name, not code
            return a.name.localeCompare(b.name);
        })
        .forEach(function(language) { // build the model
            model.append(
                        { "language": language.name,
                          "code": language.code
                        }
                        );
        });
    }

    ActivityIndicator {
        id: busyIndicator;

        anchors.centerIn: parent;
        running: true;
    }

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(1)

        ListView {
            id: languagesListView;

            boundsBehavior: Flickable.StopAtBounds;
            clip: true;
            currentIndex: -1

            anchors {
                left: parent.left;
                right: parent.right;
                topMargin: topMargin;
            }

            height: column.height - column.spacing - topMargin

            section {
                property: "language";
                criteria: ViewSection.FirstCharacter;
            }

            model: ListModel {
                id: model;
            }

            delegate: ListItem {
                id: itemDelegate;

                readonly property bool isCurrent: index === ListView.view.currentIndex

                Label {
                    text: language;

                    anchors {
                        left: parent.left;
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }

                    fontSize: "medium"
                    font.weight: itemDelegate.isCurrent ? Font.Normal : Font.Light
                }

                onClicked: {
                    selectedLanguage = code
                    ListView.view.currentIndex = index
                    print("Selected language: " + selectedLanguage)
                    print("Current index: " + ListView.view.currentIndex)
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: selectedLanguage !== ""
            onClicked: {
                if (selectedLanguage !== plugin.languageCodes[plugin.currentLanguage]) {
                    //plugin.currentLanguage = listview.currentIndex; // setting system language by some magic index? wtf
                    //System.updateSessionLanguage(selectedLanguage); // TODO
                    i18n.language = i18n.language; // re-notify of change after above call (for qlocale change)
                }
                pageStack.next()
            }
        }
    }
}
