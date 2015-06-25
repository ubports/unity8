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

    UbuntuLanguagePlugin {
        id: plugin
    }

    Component.onCompleted: {
        populateModel(["fr", "de"]); // FIXME pass a list of detected languages here
    }

    function populateModel(detectedLangs)
    {
        var langs = LocalePlugin.languages();
        Object.keys(langs).map(function(code) { // prepare the object
            //console.log("Got language:" + code);
            return { "code": code, "language":  langs[code] || code,
                "dept": detectedLangs.indexOf(code) !== -1 ? i18n.tr("Detected") : i18n.tr("All") };
        })
        .sort(function(a, b) { // group by status, sort by language name
            if (a.dept === b.dept) {
                 return a.language.localeCompare(b.language);
            } else if (a.dept === i18n.tr("Detected")) {
                return -1
            }
            return 1
        })
        .forEach(function(lang) { // build the model
            if (lang.code === "C") {
                return;
            }
            model.append(lang);
        });
        busyIndicator.running = false;
        busyIndicator.visible = false;
    }

    ActivityIndicator {
        id: busyIndicator;

        anchors.centerIn: column;
        running: true;
    }

    Column {
        id: column
        anchors.fill: content

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

            height: column.height

            section {
                property: "dept";
                criteria: ViewSection.FullString;
                labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
                delegate: Component {
                    Label {
                        text: section
                        fontSize: "large"
                        color: "black"
                    }
                }
            }

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
                    color: "black" // FIXME proper color from the theme
                }

                Image {
                    anchors {
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    fillMode: Image.PreserveAspectFit
                    height: langLabel.paintedHeight

                    source: "data/tick@30.png"
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
                    //plugin.currentLanguage = listview.currentIndex; // setting system language by some magic index? wtf
                    //System.updateSessionLanguage(selectedLanguage); // TODO
                    i18n.language = i18n.language; // re-notify of change after above call (for qlocale change)
                }
                pageStack.next()
            }
        }
    }
}
