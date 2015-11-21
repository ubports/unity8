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

Item {
    id: root
    objectName: "sessionsList"

    property string initiallySelectedSession
    property alias selectedIndex: sessionsList.selectedIndex
    signal sessionSelected(string sessionName)

    LoginAreaContainer {
        height: sessionsList.itemHeight * sessionsList.model.count

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        ItemSelector {
            id: sessionsList
            objectName: "sessionsListSelector"

            property color originalBackground
            anchors.centerIn: parent
            width: parent.width - units.gu(1)
            expanded:true
            style: Item{}

            model: LightDMService.sessions
            delegate: OptionSelectorDelegate {
                objectName: "sessionDelegate" + index
                iconSource: icon_url
                text: display
                selected: display.toLowerCase() === initiallySelectedSession.toLowerCase()
            }

            Component.onCompleted: {
                // Disbale the highlighting since it leaks outside of rounded corners
                originalBackground = theme.palette.selected.background
                theme.palette.selected.background = "transparent"
            }
            Component.onDestruction: {
                theme.palette.selected.background = originalBackground
            }

            onDelegateClicked: {
                sessionSelected(sessionsList.model.data(index,
                        LightDMService.sessionRoles.DisplayRole));
            }
        }
    }
}
