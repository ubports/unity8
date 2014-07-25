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
import QtQuick.Layouts 1.1
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators
import Utils 0.1
import "../Components"
import "Indicators"

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    property bool __contentActive: false
    readonly property alias currentMenuIndex: listViewHeader.currentIndex
    color: "#221e1c" // FIXME not in palette yet
    property int contentReleaseInterval: 20000
    property real headerHeight: listViewHeader

    width: units.gu(40)
    height: units.gu(42)

    function setCurrentMenuIndex(index, animate) {
        listViewHeader.currentIndex = index;
    }

    function activateContent() {
        contentReleaseTimer.stop();
        __contentActive = true;
    }

    function releaseContent() {
        if (__contentActive) {
            contentReleaseTimer.restart();
        }
    }

    ListView {
        id: listViewHeader
        objectName: "indicatorsListViewHeader"
        model: content.indicatorsModel

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(8.5)

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: Flickable.StopAtBounds

        delegate: PageHeader {
            width: ListView.view.width
            height: implicitHeight

            title: indicatorDelegate.title !== "" ? indicatorDelegate.title : identifier

            IndicatorDelegate {
                id: indicatorDelegate

                Component.onCompleted: {
                    for(var pName in indicatorProperties) {
                        if (indicatorDelegate.hasOwnProperty(pName)) {
                            indicatorDelegate[pName] = indicatorProperties[pName];
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: listViewContent
        objectName: "indicatorsListViewContent"
        anchors {
            left: parent.left
            right: parent.right
            top: listViewHeader.bottom
            bottom: parent.bottom
        }
        model: content.indicatorsModel

        currentIndex: listViewHeader.currentIndex
        interactive: false
        highlightMoveDuration: 0
        orientation: ListView.Horizontal

        delegate: Loader {
            id: loader
            width: ListView.view.width
            height: ListView.view.height

            source: pageSource
            asynchronous: true

            readonly property bool indexActive: index >= 0 && index < menuActivator.count && menuActivator.content[index].active
            readonly property bool contentActive: content.__contentActive && indexActive

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
                if (contentActive && listViewContent.visible) {
                    item.start()
                }
            }

            Binding {
                target: loader.item
                property: "objectName"
                value: identifier + "-page"
            }
        }
    }

    Timer {
        id: contentReleaseTimer

        interval: contentReleaseInterval
        onTriggered: {
            content.__contentActive = false;
            menuActivator.clear();
        }
    }

    Indicators.MenuContentActivator {
        id:  menuActivator
        running: content.__contentActive
        baseIndex: content.currentMenuIndex
        count: indicatorsModel.count
    }
}
