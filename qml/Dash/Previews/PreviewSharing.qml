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
import Ubuntu.Content 1.1

Item {
    id: root
    implicitHeight: button.height
    implicitWidth: button.width

    property var shareData
    readonly property bool isUrlExternal: url && url.indexOf("file:///") != 0 && url.indexOf("/") != 0
    readonly property string contentType: shareData ? shareData["contentType"] : ""
    readonly property var url: shareData ? shareData["uri"] : ""
    readonly property Item rootItem: QuickUtils.rootItem(root)

    visible: url != ""

    AbstractButton {
        id: button
        height: units.gu(4)
        width: units.gu(4)
        onClicked: peerPicker.visible = true

        Icon {
            anchors.centerIn: parent
            height: units.gu(3)
            width: units.gu(3)
            source: "image://theme/share"
        }
    }

    Component {
        id: exportItemComponent
        ContentItem {
            name: i18n.tr("Preview Share Item")
        }
    }

    Component {
        id: contentPeerComponent
        ContentPeerPicker {
            handler: ContentHandler.Share
            contentType: {
                // for now, treat all external urls as Links, or it will break contenthub
                if (root.isUrlExternal) return ContentType.Links;

                switch(root.contentType) {
                    case "all": return ContentType.All;
                    case "contacts": return ContentType.Contacts;
                    case "documents": return ContentType.Documents;
                    case "links": return ContentType.Links;
                    case "music": return ContentType.Music;
                    case "pictures": return ContentType.Pictures;
                    case "text": return ContentType.Text;
                    default:
                    case "unknown": return ContentType.Unknown;
                    case "videos": return ContentType.Videos;
                }
            }

            onPeerSelected: {
                var transfer = peer.request();
                if (transfer.state === ContentTransfer.InProgress) {
                    var items = new Array();
                    for (var i = 0; i < url.length; i++) {
                        var exportItem = exportItemComponent.createObject();
                        exportItem.url = url[i];
                        items.push(exportItem);
                    }
                    transfer.items = items;
                    transfer.state = ContentTransfer.Charged;
                }
                peerPicker.visible = false;
            }
            onCancelPressed: peerPicker.visible = false;
        }
    }

    Loader {
        id: peerPicker
        objectName: "peerPicker"
        parent: rootItem
        anchors.fill: parent
        visible: false
        active: root.visible

        sourceComponent: contentPeerComponent
    }
}
