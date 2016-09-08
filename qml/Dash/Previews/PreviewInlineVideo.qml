/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Thumbnailer 0.1
import "../../Components"
import "../../Components/MediaServices"

/*! \brief Preview widget for video.

    This widget shows video contained in widgetData["source"],
    with a placeholder screenshot specified by widgetData["screenshot"].
 */

PreviewWidget {
    id: root
    implicitWidth: units.gu(35)
    implicitHeight: services.height

    widgetMargins: -units.gu(1)
    orientationLock: services.fullscreen

    property alias rootItem: services.rootItem

    MediaServices {
        id: services
        width: parent.width

        actions: sharingAction
        context: "video"
        sourceData: widgetData
        fullscreen: false
        maximumEmbeddedHeight: rootItem.height / 2

        onClose: fullscreen = false

        Action {
            id: sharingAction
            iconName: "share"
            visible: sharingPicker.active
            onTriggered: sharingPicker.showPeerPicker()
        }
    }

    SharingPicker {
        id: sharingPicker
        objectName: "sharingPicker"
        shareData: widgetData["share-data"]
    }
}
