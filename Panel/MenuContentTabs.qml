/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators
import "../Components"

MainView {
    id: content

    property QtObject indicatorsModel: null
    readonly property int currentMenuIndex : tabs.selectedTabIndex
    backgroundColor: "#221e1c" // FIXME not in palette yet
    property int contentReleaseInterval: 20000

    width: units.gu(40)
    height: units.gu(42)

    QtObject {
        id: d
        property bool contentActive: false
    }

    function setCurrentMenuIndex(index) {
        if (currentMenuIndex !== index) {
            tabs.selectedTabIndex = index;
        }
    }

    function activateContent() {
        contentReleaseTimer.stop();
        d.contentActive = true;
    }

    function releaseContent() {
        if (d.contentActive) {
            contentReleaseTimer.restart();
        }
    }

    Tabs {
        id: tabs
        anchors.fill: parent
        selectedTabIndex: -1

        Repeater {
            id: repeater
            model: indicatorsModel
            objectName: "menus"

            // FIXME: This is needed because tabs dont handle repeaters well.
            // Due to the child ordering happening after child insertion.
            // QTBUG-32438
            onItemAdded: {
                parent.childrenChanged();
            }

            Tab {
                id: tab
                title: indicatorsModel ? indicatorsModel.data(index, Indicators.IndicatorsModelRole.Title) : ""

                page: Page {
                    Loader {
                        clip: true
                        anchors.fill: parent
                        source: pageSource
                        asynchronous: true

                        property bool contentActive: d.contentActive

                        onContentActiveChanged: {
                            if (contentActive && item) {
                                item.start()
                            } else if (!contentActive && item) {
                                item.stop()
                            }
                        }

                        onVisibleChanged: {
                            // Reset the indicator states
                            if (!visible && item && item["reset"]) {
                                item.reset()
                            }
                        }

                        onLoaded: {
                            for(var pName in indicatorProperties) {
                                if (item.hasOwnProperty(pName)) {
                                    item[pName] = indicatorProperties[pName]
                                }
                            }
                            if (contentActive && menus.visible) {
                                item.start()
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: contentReleaseTimer

        interval: contentReleaseInterval
        onTriggered: d.contentActive = false
    }
}
