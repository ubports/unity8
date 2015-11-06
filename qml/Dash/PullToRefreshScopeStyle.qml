/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components.Styles 1.3

/**
 * TODO: Once the SDK version of PullToRefreshStyle doesn't have bug 1375799
 * (https://launchpad.net/bugs/1375799) anymore, we should switch to using a
 * a subclass of the Ambiance version with a hidden ActivityIndicator.
 */
PullToRefreshStyle {
    releaseToRefresh: styledItem.target.originY - styledItem.target.contentY > activationThreshold

    Connections {
        property bool willRefresh: false

        target: styledItem.target
        onDraggingChanged: {
            if (!styledItem.target.dragging && releaseToRefresh) {
                willRefresh = true
            }
        }
        onContentYChanged: {
            if (styledItem.target.originY - styledItem.target.contentY == 0 && willRefresh) {
                styledItem.refresh()
                willRefresh = false
            }
        }
    }

    Label {
        id: pullLabel
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        states: [
            State {
                name: "pulling"
                when: styledItem.target.dragging && !releaseToRefresh
                PropertyChanges { target: pullLabel; text: i18n.tr("Pull to refresh…") }
            },
            State {
                name: "releasable"
                when: styledItem.target.dragging && releaseToRefresh
                PropertyChanges { target: pullLabel; text: i18n.tr("Release to refresh…") }
            }
        ]
        transitions: Transition {
            SequentialAnimation {
                UbuntuNumberAnimation {
                    target: pullLabel
                    property: "opacity"
                    to: 0.0
                }
                PropertyAction {
                    target: pullLabel
                    property: "text"
                }
                UbuntuNumberAnimation {
                    target: pullLabel
                    property: "opacity"
                    to: 1.0
                }
            }
        }
    }
}
