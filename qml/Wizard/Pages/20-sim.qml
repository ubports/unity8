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

import QtQuick 2.4
import MeeGo.QOfono 0.2
import Ubuntu.Components 1.3
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "simPage"

    title: i18n.tr("Add a SIM card and restart your device")
    forwardButtonSourceComponent: forwardButton

    skipValid: !manager.available ||
               (manager.ready && (manager.modems.length < 1 || simManager0.ready)
                              && (manager.modems.length < 2 || simManager1.ready))
    skip: !manager.available || manager.modems.length === 0 || simManager0.present || simManager1.present

    OfonoManager {
        id: manager
        property bool ready: false
        onModemsChanged: ready = true
    }

    // Ideally we would query the system more cleverly than hardcoding two
    // modems.  But we don't yet have a more clever way.  :(
    OfonoSimManager {
        id: simManager0
        modemPath: manager.modems.length >= 1 ? manager.modems[0] : ""
    }

    OfonoSimManager {
        id: simManager1
        modemPath: manager.modems.length >= 2 ? manager.modems[1] : ""
    }

    Column {
        anchors.fill: content
        spacing: units.gu(4)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Without it, you won’t be able to make calls or use text messaging.")
        }

        Image {
            id: image
            source: "data/meet_ubuntu_simcard@30.png"
            height: units.gu(6.5)
            width: units.gu(9)
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Skip")
            onClicked: pageStack.next()
        }
    }
}
