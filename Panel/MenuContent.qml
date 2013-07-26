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

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    property bool __contentActive: false
    property alias currentMenuIndex : menus.currentIndex
    property color backgroundColor: "#221e1c" // FIXME not in palette yet
    property int contentReleaseInterval: 20000

    width: units.gu(40)
    height: units.gu(42)
    color: backgroundColor

    signal menuSelected(int index)

    function activateContent() {
        contentReleaseTimer.stop();
        __contentActive = true;
    }

    function releaseContent() {
        if (__contentActive)
            contentReleaseTimer.restart();
    }

    ListView {
        id: menus
        objectName: "menus"

        anchors.bottom: parent.bottom
        anchors.top: header.bottom
        width: parent.width

        spacing: units.gu(0.5)
        enabled: opacity != 0
        orientation: ListView.Horizontal
        model: indicatorsModel
        interactive: false
        //FIXME: This will make sure that all plugins still alive
        //check bug https://bugs.launchpad.net/manhattan/+bug/1088945 for more details
        cacheBuffer: 2147483647

        delegate: Loader {
            clip: true
            property bool contentActive: content.__contentActive && menuActivator.content[index].active

            onContentActiveChanged: {
                if (contentActive && item) {
                    item.start();
                } else if (!contentActive && item) {
                    item.stop();
                }
            }

            width: menus.width
            height: menus.height
            source: pageSource
            onVisibleChanged: {
                // Reset the indicator states
                if (!visible && item && item["reset"]) {
                    item.reset();
                }
            }
            asynchronous: true

            onLoaded: {
                for(var pName in indicatorProperties) {
                    if (item.hasOwnProperty(pName)) {
                        item[pName] = indicatorProperties[pName];
                    }
                }
                if (contentActive && menus.visible) {
                    item.start();
                }
            }

            // Need to use a binding because the handle height changes.
            // FIXME: Dont know why we're using handle height (introduces dep).. Check with design about bottom margin
            Binding {
                target: item
                property: "anchors.bottomMargin"
                value: handle.height
            }
        }
    }

    Rectangle {
        id: header
        objectName: "header"

        property alias title: pageHeader.text

        color: backgroundColor
        opacity: pageHeader.opacity
        anchors {
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        PageHeader {
            id: pageHeader
            anchors {
                left: parent.left
                right: parent.right
            }
            text: {
                if (indicatorsModel && menus.currentIndex >= 0 && menus.currentIndex < indicatorsModel.count)
                    return indicatorsModel.data(menus.currentIndex, Indicators.IndicatorsModelRole.Title);
                return "";
            }
        }
    }

    Timer {
        id: contentReleaseTimer

        interval: contentReleaseInterval
        onTriggered: {
            __contentActive = false;
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
