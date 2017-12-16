/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "." 0.1
import "../Components"

Item {
    id: root
    objectName: "sessionsList"

    signal sessionSelected(string sessionKey)
    signal showLoginList()

    // Sets the position of the background highlight
    function updateHighlight(session) {
        sessionsList.currentIndex = getIndexOfSession(session);
        sessionsList.currentItem.initialSession = session;
    }

    function getIndexOfSession(session) {
        for (var i = 0; i < sessionsList.model.count; i++) {
            var key = sessionsList.model.get(i).key;
            if (key === session) {
                return i;
            }
        }

        return 0; // Just choose the first session
    }

    function currentKey() {
        var session = LightDMService.sessions.data(
            sessionsList.currentIndex, LightDMService.sessionRoles.KeyRole)
        return session;
    }

    Keys.onEnterPressed: {
        sessionSelected(currentKey());
        showLoginList();
        event.accepted = true;
    }

    Keys.onEscapePressed: {
        showLoginList();
        event.accepted = true;
    }

    Keys.onReturnPressed: {
        sessionSelected(currentKey());
        showLoginList();
        event.accepted = true;
    }

    Keys.onDownPressed: {
        if (sessionsList.currentIndex < sessionsList.model.count - 1)
            sessionsList.currentIndex++;
        event.accepted = true;
    }

    Keys.onUpPressed: {
        if (sessionsList.currentIndex > 0)
            sessionsList.currentIndex--;
        event.accepted = true;
    }

    LoginAreaContainer {
        readonly property real margins: sessionsList.anchors.margins
        readonly property real preferredHeight: {
            if (sessionsList.currentItem) {
                return (sessionsList.currentItem.height *
                       (1 + sessionsList.model.count)) + 2 * margins
            } else {
                return sessionsList.headerItem.height + 2 * margins
            }
        }

        height: preferredHeight < parent.height ? preferredHeight : parent.height - units.gu(4)
        width: parent.width

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        UbuntuListView {
            id: sessionsList

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            clip: true
            height: parent.height - units.gu(2.5)
            boundsBehavior: Flickable.StopAtBounds

            model: LightDMService.sessions
            header: ListItemLayout {
                id: header

                padding.leading: 0 // handled by parent's margins

                title.color: theme.palette.normal.raisedText
                title.font.pixelSize: units.gu(2.1)
                title.text: i18n.tr("Select desktop environment")

                Icon {
                    id: icon
                    width: units.gu(3)
                    SlotsLayout.position: SlotsLayout.Leading
                    name: "go-previous"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: showLoginList()
                    }
                }
            }

            headerPositioning: ListView.OverlayHeader

            // The highlighting is all self-managed, so account for that
            highlightFollowsCurrentItem: false
            highlight: QtObject {}

            delegate: ListItem {
                id: delegate
                objectName: "sessionDelegate" + index

                property string initialSession: ""

                divider.visible: false
                visible: y > sessionsList.headerItem.y
                + sessionsList.headerItem.height
                - sessionsList.anchors.margins

               MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sessionsList.currentIndex = index
                        sessionSelected(key)
                        showLoginList()
                    }
                }

                Rectangle {
                    id: backgroundHighlight

                    height: sessionsList.currentItem.height
                    width: sessionsList.currentItem.width
                    color: theme.palette.normal.selection

                    visible: initialSession === key && !!key
                }

                Rectangle {
                    height: parent.height
                    width: parent.width
                    color: "transparent"
                    border {
                        color: theme.palette.normal.focus
                        width: units.gu(0.2)
                    }

                    visible: index === sessionsList.currentIndex
                }

                ListItemLayout {
                    id: layout

                    readonly property color itemColor: theme.palette.normal.raisedText
                    SessionIcon {
                        id: sessionIcon
                        source: icon_url
                        SlotsLayout.position: SlotsLayout.Leading
                        color: parent.itemColor
                    }

                    title.text: display
                    title.color: itemColor
                }
            }
        }
    }
}
