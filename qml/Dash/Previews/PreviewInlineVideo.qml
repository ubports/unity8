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

import QtQuick 2.0
import QtMultimedia 5.0
import Ubuntu.Components 0.1
import Ubuntu.Thumbnailer 0.1
import Ubuntu.Content 0.1
import "../../Components/MediaServices"

/*! \brief Preview widget for video.

    This widget shows video contained in widgetData["source"],
    with a placeholder screenshot specified by widgetData["screenshot"].
 */

PreviewWidget {
    id: root
    implicitWidth: units.gu(35)
    implicitHeight: services.height

    property alias rootItem: services.rootItem

    MediaServices {
        id: services
        width: parent.width

        context: "video"
        sourceData: widgetData
        fullscreen: false

        onClose: fullscreen = false

        actions: [
            Action {
                text: i18n.tr("Share")
                iconSource: "image://theme/share"
                onTriggered: sharePicker.visible = true
            }
        ]
    }

    Component {
        id: contentItemComp
        ContentItem {
            url: widgetData["source"]
        }
    }

    ContentPeerPicker {
        id: sharePicker
        objectName: "sharePickerEvents"
        anchors.fill: parent
        showTitle: false
        visible: false
        parent: rootItem
        z: 100

        contentType: ContentType.Videos
        handler: ContentHandler.Share

        onPeerSelected: {
            visible = false;

            var curTransfer = peer.request();
            if (curTransfer.state === ContentTransfer.InProgress)
            {
                var medias = [ contentItemComp.createObject(parent) ]
                curTransfer.state = ContentTransfer.Charged;
            }
        }
        onCancelPressed: {
            visible = false;
        }
    }
}
