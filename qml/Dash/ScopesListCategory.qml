/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import Dash 0.1
import "../Components/ListItems" as ListItems

Item {
    id: root

    property alias model: list.model
    property alias title: header.text
    property var scopeStyle
    property bool editMode: false
    property bool isFavoritesFeed: false
    property bool isAlsoInstalled: false

    visible: !editMode || isFavoritesFeed

    signal requestFavorite(string scopeId, bool favorite)
    signal requestEditMode()
    signal requestScopeMoveTo(string scopeId, int index)
    signal requestActivate(var result)
    signal requestRestore(string scopeId)

    implicitHeight: visible ? childrenRect.height : 0

    ListItems.Header {
        id: header
        width: root.width
        height: units.gu(5)
        color: scopeStyle ? scopeStyle.foreground : theme.palette.normal.baseText
    }

    readonly property double listItemHeight: units.gu(6)

    ListView {
        id: list
        objectName: "scopesListCategoryInnerList"

        readonly property double targetHeight: model.count * listItemHeight
        clip: height != targetHeight
        height: targetHeight
        Behavior on height { enabled: visible; UbuntuNumberAnimation { } }
        width: parent.width
        interactive: false

        anchors.top: header.bottom
        delegate: Loader {
            id: loader
            readonly property bool addDropHint: {
                if (dragMarker.visible) {
                    if (dragItem.originalIndex > index) {
                        return dragMarker.index == index;
                    } else {
                        return dragMarker.index == index - 1;
                    }
                } else {
                    return false;
                }
            }
            asynchronous: true
            width: root.width
            height: listItemHeight + (addDropHint ? units.gu(2) : 0)
            clip: height < listItemHeight
            Behavior on height { enabled: visible; UbuntuNumberAnimation { } }
            sourceComponent: ScopesListCategoryItem {
                objectName: "delegate" + model.scopeId

                width: root.width
                topMargin: height > listItemHeight ? height - listItemHeight : 0

                icon: model.art || model.mascot || ""
                text: model.title || ""
                subtext: model.subtitle || ""
                showStar: model.scopeId !== "clickscope" && (root.isFavoritesFeed || root.isAlsoInstalled)
                isFavorite: root.isFavoritesFeed

                hideChildren: dragItem.loaderToShrink == loader

                onClicked: {
                    if (!editMode) {
                        if (root.isFavoritesFeed)
                            root.requestRestore(model.scopeId);
                        else
                            root.requestActivate(result);
                    }
                }
                onPressAndHold: {
                    if (!editMode) {
                        root.requestEditMode();
                    }
                }
                onRequestFavorite: root.requestFavorite(model.scopeId, favorite);
                onHandlePressed: {
                    if (editMode) {
                        handle.drag.target = dragItem;
                        handle.drag.maximumX = units.gu(1);
                        handle.drag.minimumX = units.gu(1);
                        handle.drag.minimumY = list.y - dragItem.height / 2;
                        handle.drag.maximumY = list.y + list.height - dragItem.height / 2
                        dragItem.icon = icon;
                        dragItem.text = text;
                        dragItem.subtext = subtext;
                        dragItem.originalY = mapToItem(root, 0, 0).y;
                        dragItem.originalIndex = index;
                        dragItem.y = dragItem.originalY;
                        dragItem.x = units.gu(1);
                        dragItem.visible = true;
                        dragItem.loaderToShrink = loader;
                    }
                }
                onHandleReleased: {
                    if (dragItem.visible) {
                        handle.drag.target = undefined;
                        dragItem.visible = false;
                        if (dragMarker.visible && dragMarker.index != index) {
                            root.requestScopeMoveTo(model.scopeId, dragMarker.index);
                        }
                        dragMarker.visible = false;
                        dragItem.loaderToShrink.height = listItemHeight;
                        dragItem.loaderToShrink = null;
                    }
                }
            }
        }
    }

    ListItems.ThinDivider {
        id: dragMarker
        visible: false
        anchors {
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
        property int index: {
            var i = Math.round((dragItem.y - list.y + dragItem.height/2) / listItemHeight);
            if (i < 0) i = 0;
            if (i >= model.count - 1) i = model.count - 1;
            return i;
        }
        y: list.y + index * listItemHeight + units.gu(1)
    }

    ScopesListCategoryItem {
        id: dragItem

        property real originalY
        property int originalIndex
        property var loaderToShrink: null

        objectName: "dragItem"
        visible: false
        showStar: false
        width: root.width
        height: listItemHeight
        opacity: 0.9

        onYChanged: {
            if (!dragMarker.visible && Math.abs(y - originalY) > height / 2) {
                dragMarker.visible = true;
                loaderToShrink.height = 0;
            }
        }
    }
}
