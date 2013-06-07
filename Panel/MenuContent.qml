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
import "Menus"
import "../Components"

Rectangle {
    id: content

    property QtObject indicatorsModel: null
    property bool animate: true // FIXME: Remove. This doesnt seem to be being used and it's referenced in Indicators.
    property bool overviewActive: true // "state of the menu"
    property bool __shown: false
    property bool __contentActive: false
    property alias currentIndex : menus.currentIndex
    property color backgroundColor: "#221e1c"
    property int contentReleaseInterval: 5000

    width: units.gu(40)
    height: units.gu(42)
    color: backgroundColor
    enabled: __shown

    signal menuSelected(int index)

    function showMenu() {
        __shown = true
        overviewActive = false
    }

    function showOverview() {
        __shown = true
        overviewActive = true
    }

    function hideAll() {
        __shown = false
    }

    function activateContent() {
        contentReleaseTimer.stop()
        __contentActive = true
    }

    function releaseContent() {
        if (__contentActive)
            contentReleaseTimer.restart()
    }

    ListView {
        id: menus
        objectName: "menus"

        anchors.bottom: parent.bottom
        anchors.top: header.bottom
        width: parent.width

        spacing: units.gu(0.5)
        opacity: !overviewActive && __shown ? 1 : 0
        enabled: opacity != 0
        orientation: ListView.Horizontal
        model: indicatorsModel
        interactive: false
        //FIXME: This will make sure that all plugins still alive
        //check bug https://bugs.launchpad.net/manhattan/+bug/1088945 for more details
        cacheBuffer: 2147483647

        delegate: Loader {
            clip: true
            property bool contentActive: content.__contentActive

            onContentActiveChanged: {
                if (contentActive && item) {
                    item.start()
                } else if (!contentActive && item) {
                    item.stop()
                }
            }

            width: menus.width
            height: menus.height
            source: component
            visible: content.__shown
            onVisibleChanged: {
                // Reset the indicator states
                if (!visible && item) {
                    item.reset()
                }
            }
            asynchronous: true

            onStatusChanged: {
                if (status == Loader.Ready) {
                    for(var pName in initialProperties) {
                        if (item.hasOwnProperty(pName)) {
                            item[pName] = initialProperties[pName]
                        }
                    }
                    if (contentActive && menus.visible) {
                        item.start()
                    }
                }
            }

            // FIXME: QTBUG-30632 - asynchronous loader crashes when changing index quickly.
            Component.onDestruction: {
                active = false;
            }

            // Need to use a binding because the handle height changes.
            // FIXME: Dont know why we're using handle height (introduces dep).. Check with design about bottom margin
            Binding {
                target: item
                property: "anchors.bottomMargin"
                value: handle.height
            }
        }

        Behavior on opacity { NumberAnimation {duration: 200} }
    }

    Overview {
        id: overview
        objectName: "overview"

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        // FIXME: Dont know why we're using handle height (introduces dep).. Check with design about bottom margin
        anchors.bottomMargin: handle.height

        width: content.width
        indicatorsModel: content.indicatorsModel
        enabled: content.overviewActive && content.__shown
        opacity: content.overviewActive && content.__shown ? 1 : 0
        Behavior on opacity {NumberAnimation{duration: 200}}
        visible: opacity != 0

        onMenuSelected: {
            var storedDuration = menus.highlightMoveDuration
            var storedVelocity = menus.highlightMoveVelocity
            menus.highlightMoveDuration = 0
            menus.highlightMoveVelocity = 100000

            menus.currentIndex = modelIndex
            content.overviewActive = false

            menus.highlightMoveDuration = storedDuration
            menus.highlightMoveVelocity = storedVelocity

            content.menuSelected(modelIndex)
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
            text: content.overviewActive ? i18n.tr("Device") : (indicatorsModel && menus.currentIndex >= 0 && menus.currentIndex < indicatorsModel.count) ?  indicatorsModel.get(menus.currentIndex).title : ""
            opacity: __shown ? 1 : 0
            Behavior on opacity {NumberAnimation{duration: 100}}
        }
    }

    Timer {
        id: contentReleaseTimer

        interval: contentReleaseInterval
        onTriggered: __contentActive = false
    }
}
