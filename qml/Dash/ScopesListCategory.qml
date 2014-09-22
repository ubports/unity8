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

import QtQuick 2.0
import Ubuntu.Components 1.1;
import Dash 0.1
import "../Components/ListItems" as ListItems

Item {
    id: root

    property alias model: list.model
    property var scopeStyle
    property bool isFavoriteFeeds: false

    signal requestFavorite(string scopeId, bool favorite)

    implicitHeight: childrenRect.height

    ListItems.Header {
        id: header
        width: root.width
        height: units.gu(5)
        text: isFavoriteFeeds ? i18n.tr("Favourite Feeds") : i18n.tr("Other Subscribed Feeds")
        color: scopeStyle ? scopeStyle.foreground : Theme.palette.normal.baseText
    }

    property var myTemplate: JSON.parse('{"card-layout":"horizontal","card-size":"small","category-layout":"grid","collapsed-rows":2}')
    property var myComponents: JSON.parse('{"art":{"aspect-ratio":1,"field":"art"},"title":{"field":"title"},"attributes":{}}')

    ListView {
        id: list

        readonly property double targetHeight: model.count * units.gu(6)
        clip: height != targetHeight
        height: targetHeight
        Behavior on height { enabled: visible; UbuntuNumberAnimation { } }
        width: parent.width
        interactive: false

        removeDisplaced: Transition { UbuntuNumberAnimation { properties: "y" } }

        anchors.top: header.bottom
        delegate: Loader {
            asynchronous: true
            width: root.width
            height: units.gu(6)
            sourceComponent: Item {
                width: root.width
                UbuntuShape {
                    id: shape
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    width: units.gu(5)
                    height: units.gu(5)
                    image: Image {
                        source: model["art"] || ""
                        cache: true
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                Label {
                    id: titleLabel
                    anchors {
                        left: shape.right
                        leftMargin: units.gu(1)
                        right: star.right
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    text: model["title"] || ""
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    maximumLineCount: 1
                    verticalAlignment: Text.AlignHCenter
                }
                Icon {
                    id: star
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    height: units.gu(2)
                    width: units.gu(2)
                    visible: !isFavoriteFeeds || index != 0
                    source: isFavoriteFeeds ? "image://theme/starred" : "image://theme/non-starred"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.requestFavorite(model.scopeId, !isFavoriteFeeds);
                    }
                }
            }
        }
    }
}
