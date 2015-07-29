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
    objectName: "countryPage"

    title: i18n.tr("Region")
    forwardButtonSourceComponent: forwardButton

    Component.onCompleted: {
        if (!modemManager.available) { // don't wait for the modem if it's not there
            init()
        }
    }

    Connections {
        target: modemManager
        onModemsChanged: {
            print("Modems changed")
            init()
        }
    }

    function init()
    {
        var detectedCountry
        if (simManager0.present && simManager0.mobileCountryCode) {
            detectedCountry = LocalePlugin.mccToCountryCode(simManager0.mobileCountryCode)
            print("SIM 0 detected country:", detectedCountry)
        } else if (simManager1.present && simManager1.mobileCountryCode) {
            detectedCountry = LocalePlugin.mccToCountryCode(simManager1.mobileCountryCode)
            print("SIM 1 detected country:", detectedCountry)
        } else if (!detectedCountry) {
            detectedCountry = preferedCountry() // fallback to prefered country
            print("No SIM country detected, falling back to prefered country:", detectedCountry)
        }

        populateModel(detectedCountry)
    }

    // return a prefered country for a language, but only if there's exactly one
    function preferedCountry()
    {
        var countries = Object.keys(LocalePlugin.countriesForLanguage(root.language))
        if (countries.length === 1) {
            return countries[0]
        }
        // TODO should we ultimately fallback to "US" here?
    }

    function populateModel(preferedCountry)
    {
        var countries = LocalePlugin.countries();
        var index = 0
        var selectedIndex = -1
        //console.log("All countries:" + countries);
        print("Prefered country", preferedCountry)
        Object.keys(countries).map(function(code) { // prepare the object
            //console.log("Got country:" + code);
            return { "code": code, "country":  countries[code] || code };
        })
        .sort(function(a, b) { // sort by country name
            return a.country.localeCompare(b.country);
        })
        .forEach(function(country) { // build the model
            //console.debug("Adding country:" + country.code);
            if (country.code === "C") {
                return;
            }
            model.append(country);
            if (preferedCountry && country.code === preferedCountry) { // preselect the prefered country, if any
                selectedIndex = index;
                selectCountry(country.code, selectedIndex)
            }
            index++;
        });
        busyIndicator.running = false;
        busyIndicator.visible = false;

        if (selectedIndex !== -1) {
            regionsListView.positionViewAtIndex(selectedIndex, ListView.Center)
        }
    }

    function selectCountry(code, index)
    {
        root.country = code
        regionsListView.currentIndex = index
        print("Selected country: " + root.country)
        print("Current index: " + regionsListView.currentIndex)
    }

    UbuntuLanguagePlugin {
        id: plugin
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
            id: regionsListView;

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
                delegate: Label {
                    fontSize: "x-large"
                }
            }

            model: ListModel {
                id: model;
            }

            delegate: ListItem {
                id: itemDelegate;

                readonly property bool isCurrent: index === ListView.view.currentIndex

                Label {
                    id: countryLabel
                    text: country;

                    anchors {
                        left: parent.left;
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
                    height: countryLabel.paintedHeight

                    source: "image://theme/tick"
                    visible: itemDelegate.isCurrent
                }

                onClicked: {
                    selectCountry(code, index)
                }
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            enabled: root.country !== ""
            onClicked: {
                if (root.language !== plugin.languageCodes[plugin.currentLanguage]) {
                    plugin.currentLanguage = plugin.languageCodes.indexOf(root.language)
                    System.updateSessionLanguage(root.language + "_" + root.country); // also updates the locale
                }
                pageStack.next()
            }
        }
    }
}
