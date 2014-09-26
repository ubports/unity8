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
import Ubuntu.Components 1.1
import Dash 0.1
import "../Components/ListItems" as ListItems

Item {
    id: root

    property alias model: list.model
    property var scopeStyle
    property bool isFavoriteFeeds: false
    property bool editMode: false

    visible: !editMode || isFavoriteFeeds

    signal requestFavorite(string scopeId, bool favorite)
    signal requestEditMode()
    signal requestScopeMoveTo(string scopeId, int index)

    implicitHeight: childrenRect.height

    ListItems.Header {
        id: header
        width: root.width
        height: units.gu(5)
        text: {
            if (categoryId == "favorites") return i18n.tr("Favourite Feeds");
            else if (categoryId == "other") return i18n.tr("Other Subscribed Feeds");
            else return name;
        }
        color: scopeStyle ? scopeStyle.foreground : Theme.palette.normal.baseText
    }

    property var myTemplate: JSON.parse('{"card-layout":"horizontal","card-size":"small","category-layout":"grid","collapsed-rows":2}')
    property var myComponents: JSON.parse('{"art":{"aspect-ratio":1,"field":"art"},"title":{"field":"title"},"attributes":{}}')

    readonly property double listItemHeight: units.gu(6)

    ListView {
        id: list

        readonly property double targetHeight: model.count * listItemHeight
        clip: height != targetHeight
        height: targetHeight
        Behavior on height { enabled: visible; UbuntuNumberAnimation { } }
        width: parent.width
        interactive: false

        removeDisplaced: Transition { UbuntuNumberAnimation { properties: "y" } }
        move: Transition { UbuntuNumberAnimation { properties: "y" } }
        moveDisplaced: Transition { UbuntuNumberAnimation { properties: "y" } }

        anchors.top: header.bottom
        delegate: Loader {
            asynchronous: true
            width: root.width
            height: listItemHeight
            sourceComponent: ScopesListCategoryItem {
                width: root.width

                icon: model.art || ""
                text: model.title || ""
                showStar: model.scopeId != "clickscope"

                onRequestFavorite: root.requestFavorite(model.scopeId, favorite);
                onPressAndHold: {
                    if (!editMode) {
                        root.requestEditMode();
                    } else {
                        dragItem.icon = icon;
                        dragItem.text = text;
                        dragItem.x = units.gu(1)
                        dragItem.y = mapToItem(root, 0, 0).y + units.gu(1)
                        drag.target = dragItem;
                        dragItem.visible = true;
                    }
                }
                onReleased: {
                    if (dragItem.visible) {
                        dragItem.visible = false;
                        if (dragMarker.index != index && dragMarker.index != index + 1) {
                            var targetIndex = dragMarker.index > index ? dragMarker.index - 1 : dragMarker.index;
                            root.requestScopeMoveTo(model.scopeId, targetIndex);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: dragMarker
        color: "black"
        opacity: 0.3
        height: units.dp(2)
        width: root.width
        visible: dragItem.visible
        property int index: {
            var i = Math.round((dragItem.y - list.y) / listItemHeight);
            if (i <= 0) i = 1;
            if (i >= model.count) i = model.count;
            return i;
        }
        y: list.y + index * listItemHeight
    }

    ScopesListCategoryItem {
        id: dragItem
        objectName: "dragItem"
        visible: false
        showStar: false
        width: root.width
        height: listItemHeight
        opacity: 0.9
    }
}
