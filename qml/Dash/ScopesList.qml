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
import Dash 0.1
import "../Components"

Item {
    id: root

    property alias scopesListFlickable: scopesListFlickable

    // Properties set by parent
    property var scope: null

    // Properties used by parent
    readonly property bool processing: scope ? (scope.searchInProgress || scope.activationInProgress) : false

    // Signals
    signal backClicked()
    signal storeClicked()
    signal requestFavorite(string scopeId, bool favorite)
    signal requestFavoriteMoveTo(string scopeId, int index)
    signal requestRestore(string scopeId)

    Item {
        id: autoscroller

        property bool dragging: false
        property var dragItem: new Object();

        readonly property bool fuzzyAtYEnd: {
            var contentHeight = root.scopesListFlickable.contentHeight
            var contentY = root.scopesListFlickable.contentY
            var dragItemHeight = dragItem ? autoscroller.dragItem.height : 0
            var flickableHeight = root.scopesListFlickable.height

            if (!dragItem) {
                return true;
            } else {
                return contentY >= (contentHeight - flickableHeight) - dragItemHeight
            }
        }

        readonly property real bottomBoundary: {
            var contentHeight = root.scopesListFlickable.contentHeight
            var contentY = root.scopesListFlickable.contentY
            var dragItemHeight = dragItem ? autoscroller.dragItem.height : 0
            var heightRatio = root.scopesListFlickable.visibleArea.heightRatio

            if (!dragItem) {
                return true;
            } else {
                return (heightRatio * contentHeight) -
                       (1.5 * dragItemHeight) + contentY
            }
        }

        readonly property int delayMs: 32
        readonly property real topBoundary: dragItem ? root.scopesListFlickable.contentY + (.5 * dragItem.height) : 0

        visible: false
        readonly property real maxStep: units.dp(10)
        function stepSize(scrollingUp) {
            var delta, step;
            if (scrollingUp) {
                delta = dragItem.y - topBoundary;
                delta /= (1.5 * dragItem.height);
            } else {
                delta = dragItem.y - bottomBoundary;
                delta /= (1.5 * dragItem.height);
            }

            step = Math.abs(delta) * autoscroller.maxStep
            return Math.ceil(step);
        }


        Timer {
            interval: autoscroller.delayMs
            running: autoscroller.dragItem ? (autoscroller.dragging &&
                autoscroller.dragItem.y < autoscroller.topBoundary &&
                !root.scopesListFlickable.atYBeginning) : false
            repeat: true
            onTriggered: {
                root.scopesListFlickable.contentY -= autoscroller.stepSize(true);
                autoscroller.dragItem.y -= autoscroller.stepSize(true);
            }
        }

        Timer {
            interval: autoscroller.delayMs
            running: autoscroller.dragItem ? (autoscroller.dragging &&
                autoscroller.dragItem.y >= autoscroller.bottomBoundary &&
                !autoscroller.fuzzyAtYEnd) : false
            repeat: true
            onTriggered: {
                root.scopesListFlickable.contentY += autoscroller.stepSize(false);
                autoscroller.dragItem.y += autoscroller.stepSize(false);
            }
        }
    }

    function autoscroll(dragging, dragItem) {
        if (dragging) {
            autoscroller.dragItem = dragItem
            autoscroller.dragging = true;
        } else {
            autoscroller.dragItem = null;
            autoscroller.dragging = false
        }
    }

    state: "browse"

    property var scopeStyle: ScopeStyle {}

    onStateChanged: {
        if (state == "edit") {
            // As per design entering edit mode clears the possible existing search
            header.resetSearch(false /* false == unfocus */);
        }
    }

    DashBackground {
        anchors.fill: parent
    }

    DashPageHeader {
        id: header
        objectName: "pageHeader"
        title: i18n.tr("Manage")
        width: parent.width
        clip: true
        showBackButton: true
        backIsClose: root.state == "edit"
        storeEntryEnabled: root.state == "browse"
        searchEntryEnabled: false
        scopeStyle: root.scopeStyle
        onBackClicked: {
            if (backIsClose) {
                root.state = "browse"
            } else {
                root.backClicked()
            }
        }
        onStoreClicked: root.storeClicked();
        z: 1
    }

    ListView {
        id: scopesListFlickable
        objectName: "scopesListFlickable"
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        model: scope ? scope.categories : null
            delegate: Loader {
                asynchronous: true
                width: root.width
                active: results.count > 0
                visible: active
                sourceComponent: ScopesListCategory {
                    objectName: "scopesListCategory" + categoryId

                    model: results

                    title: {
                        if (isFavoritesFeed) return i18n.tr("Home");
                        else if (isAlsoInstalled) return i18n.tr("Also installed");
                        else return name;
                    }

                    editMode: root.state == "edit"
                    scopeStyle: root.scopeStyle
                    isFavoritesFeed: categoryId == "favorites"
                    isAlsoInstalled: categoryId == "other"

                    onItemDragging: autoscroll(dragging, dragItem);
                    onRequestFavorite: root.requestFavorite(scopeId, favorite);
                    onRequestEditMode: root.state = "edit";
                    onRequestScopeMoveTo: root.requestFavoriteMoveTo(scopeId, index);
                    onRequestActivate: root.scope.activate(result, categoryId);
                    onRequestRestore: root.requestRestore(scopeId);
            }
        }
    }
}
