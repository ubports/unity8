/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import Unity.Launcher 0.1
import Ubuntu.Components.Popups 1.3
import "../Components/ListItems"
import "../Components/"

Rectangle {
    id: root
    color: "#F2111111"

    rotation: inverted ? 180 : 0

    property var model
    property bool inverted: false
    property bool dragging: false
    property bool moving: launcherListView.moving || launcherListView.flicking
    property bool preventHiding: moving || dndArea.draggedIndex >= 0 || quickList.state === "open" || dndArea.pressed
                                 || mouseEventEater.containsMouse || dashItem.hovered
    property int highlightIndex: -2
    property bool shortcutHintsShown: false

    signal applicationSelected(string appId)
    signal showDashHome()
    signal kbdNavigationCancelled()

    onXChanged: {
        if (quickList.state == "open") {
            quickList.state = ""
        }
    }

    function highlightNext() {
        highlightIndex++;
        if (highlightIndex >= launcherListView.count) {
            highlightIndex = -1;
        }
        launcherListView.moveToIndex(Math.max(highlightIndex, 0));
    }
    function highlightPrevious() {
        highlightIndex--;
        if (highlightIndex <= -2) {
            highlightIndex = launcherListView.count - 1;
        }
        launcherListView.moveToIndex(Math.max(highlightIndex, 0));
    }
    function openQuicklist(index) {
        quickList.open(index);
        quickList.selectedIndex = 0;
        quickList.focus = true;
    }

    MouseArea {
        id: mouseEventEater
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onWheel: wheel.accepted = true;
    }

    Column {
        id: mainColumn
        anchors {
            fill: parent
        }

        Rectangle {
            objectName: "buttonShowDashHome"
            width: parent.width
            height: width * .9
            color: UbuntuColors.orange
            readonly property bool highlighted: root.highlightIndex == -1;

            Image {
                objectName: "dashItem"
                width: parent.width * .6
                height: width
                anchors.centerIn: parent
                source: "graphics/home.png"
                rotation: root.rotation
            }
            AbstractButton {
                id: dashItem
                anchors.fill: parent
                activeFocusOnPress: false
                onClicked: root.showDashHome()
            }
            Rectangle {
                objectName: "bfbFocusHighlight"
                anchors.fill: parent
                border.color: "white"
                border.width: units.dp(1)
                color: "transparent"
                visible: parent.highlighted
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - dashItem.height - parent.spacing*2

            Item {
                id: launcherListViewItem
                anchors.fill: parent
                clip: true

                ListView {
                    id: launcherListView
                    objectName: "launcherListView"
                    anchors {
                        fill: parent
                        topMargin: -extensionSize + width * .15
                        bottomMargin: -extensionSize + width * .15
                    }
                    topMargin: extensionSize
                    bottomMargin: extensionSize
                    height: parent.height - dashItem.height - parent.spacing*2
                    model: root.model
                    cacheBuffer: itemHeight * 3
                    snapMode: interactive ? ListView.SnapToItem : ListView.NoSnap
                    highlightRangeMode: ListView.ApplyRange
                    preferredHighlightBegin: (height - itemHeight) / 2
                    preferredHighlightEnd: (height + itemHeight) / 2

                    // for the single peeking icon, when alert-state is set on delegate
                    property int peekingIndex: -1

                    // The size of the area the ListView is extended to make sure items are not
                    // destroyed when dragging them outside the list. This needs to be at least
                    // itemHeight to prevent folded items from disappearing and DragArea limits
                    // need to be smaller than this size to avoid breakage.
                    property int extensionSize: 0

                    // Setting extensionSize after the list has been populated because it has
                    // the potential to mess up with the intial positioning in combination
                    // with snapping to the center of the list. This catches all the cases
                    // where the item would be outside the list for more than itemHeight / 2.
                    // For the rest, give it a flick to scroll to the beginning. Note that
                    // the flicking alone isn't enough because in some cases it's not strong
                    // enough to overcome the snapping.
                    // https://bugreports.qt-project.org/browse/QTBUG-32251
                    Component.onCompleted: {
                        extensionSize = itemHeight * 3
                        flick(0, clickFlickSpeed)
                    }

                    // The height of the area where icons start getting folded
                    property int foldingStartHeight: itemHeight
                    // The height of the area where the items reach the final folding angle
                    property int foldingStopHeight: foldingStartHeight - itemHeight - spacing
                    property int itemWidth: width * .75
                    property int itemHeight: itemWidth * 15 / 16 + units.gu(1)
                    property int clickFlickSpeed: units.gu(60)
                    property int draggedIndex: dndArea.draggedIndex
                    property real realContentY: contentY - originY + topMargin
                    property int realItemHeight: itemHeight + spacing

                    // In case the start dragging transition is running, we need to delay the
                    // move because the displaced transition would clash with it and cause items
                    // to be moved to wrong places
                    property bool draggingTransitionRunning: false
                    property int scheduledMoveTo: -1

                    UbuntuNumberAnimation {
                        id: snapToBottomAnimation
                        target: launcherListView
                        property: "contentY"
                        to: launcherListView.originY + launcherListView.topMargin
                    }

                    UbuntuNumberAnimation {
                        id: snapToTopAnimation
                        target: launcherListView
                        property: "contentY"
                        to: launcherListView.contentHeight - launcherListView.height + launcherListView.originY - launcherListView.topMargin
                    }

                    UbuntuNumberAnimation {
                        id: moveAnimation
                        objectName: "moveAnimation"
                        target: launcherListView
                        property: "contentY"
                        function moveTo(contentY) {
                            from = launcherListView.contentY;
                            to = contentY;
                            restart();
                        }
                    }
                    function moveToIndex(index) {
                        var totalItemHeight = launcherListView.itemHeight + launcherListView.spacing
                        var itemPosition = index * totalItemHeight;
                        var height = launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin
                        var distanceToEnd = index == 0 || index == launcherListView.count - 1 ? 0 : totalItemHeight
                        if (itemPosition + totalItemHeight + distanceToEnd > launcherListView.contentY + launcherListView.originY + launcherListView.topMargin + height) {
                            moveAnimation.moveTo(itemPosition + launcherListView.itemHeight - launcherListView.topMargin - height + distanceToEnd - launcherListView.originY);
                        } else if (itemPosition - distanceToEnd < launcherListView.contentY - launcherListView.originY + launcherListView.topMargin) {
                            moveAnimation.moveTo(itemPosition - distanceToEnd - launcherListView.topMargin + launcherListView.originY);
                        }
                    }

                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; duration: UbuntuAnimation.FastDuration; easing: UbuntuAnimation.StandardEasing }
                    }

                    delegate: FoldingLauncherDelegate {
                        id: launcherDelegate
                        objectName: "launcherDelegate" + index
                        // We need the appId in the delegate in order to find
                        // the right app when running autopilot tests for
                        // multiple apps.
                        readonly property string appId: model.appId
                        itemIndex: index
                        itemHeight: launcherListView.itemHeight
                        itemWidth: launcherListView.itemWidth
                        width: parent.width
                        height: itemHeight
                        iconName: model.icon
                        count: model.count
                        countVisible: model.countVisible
                        progress: model.progress
                        itemRunning: model.running
                        itemFocused: model.focused
                        inverted: root.inverted
                        alerting: model.alerting
                        highlighted: root.highlightIndex == index
                        shortcutHintShown: root.shortcutHintsShown && index <= 9
                        surfaceCount: model.surfaceCount
                        z: -Math.abs(offset)
                        maxAngle: 55
                        property bool dragging: false

                        SequentialAnimation {
                            id: peekingAnimation

                            // revealing
                            PropertyAction { target: root; property: "visible"; value: (launcher.visibleWidth === 0) ? 1 : 0 }
                            PropertyAction { target: launcherListViewItem; property: "clip"; value: 0 }

                            UbuntuNumberAnimation {
                                target: launcherDelegate
                                alwaysRunToEnd: true
                                loops: 1
                                properties: "x"
                                to: (units.gu(.5) + launcherListView.width * .5) * (root.inverted ? -1 : 1)
                                duration: UbuntuAnimation.BriskDuration
                            }

                            // hiding
                            UbuntuNumberAnimation {
                                target: launcherDelegate
                                alwaysRunToEnd: true
                                loops: 1
                                properties: "x"
                                to: 0
                                duration: UbuntuAnimation.BriskDuration
                            }

                            PropertyAction { target: launcherListViewItem; property: "clip"; value: 1 }
                            PropertyAction { target: root; property: "visible"; value: (launcher.visibleWidth === 0) ? 0 : 1 }
                            PropertyAction { target: launcherListView; property: "peekingIndex"; value: -1 }
                        }

                        onAlertingChanged: {
                            if(alerting) {
                                if (!dragging && (launcherListView.peekingIndex === -1 || launcher.visibleWidth > 0)) {
                                    launcherListView.moveToIndex(index)
                                    if (!dragging && launcher.state !== "visible") {
                                        peekingAnimation.start()
                                    }
                                }

                                if (launcherListView.peekingIndex === -1) {
                                    launcherListView.peekingIndex = index
                                }
                            } else {
                                if (launcherListView.peekingIndex === index) {
                                    launcherListView.peekingIndex = -1
                                }
                            }
                        }

                        ThinDivider {
                            id: dropIndicator
                            objectName: "dropIndicator"
                            anchors.centerIn: parent
                            width: parent.width + mainColumn.anchors.leftMargin + mainColumn.anchors.rightMargin
                            opacity: 0
                            source: "graphics/divider-line.png"
                        }

                        states: [
                            State {
                                name: "selected"
                                when: dndArea.selectedItem === launcherDelegate && fakeDragItem.visible && !dragging
                                PropertyChanges {
                                    target: launcherDelegate
                                    itemOpacity: 0
                                }
                            },
                            State {
                                name: "dragging"
                                when: dragging
                                PropertyChanges {
                                    target: launcherDelegate
                                    height: units.gu(1)
                                    itemOpacity: 0
                                }
                                PropertyChanges {
                                    target: dropIndicator
                                    opacity: 1
                                }
                            },
                            State {
                                name: "expanded"
                                when: dndArea.draggedIndex >= 0 && (dndArea.preDragging || dndArea.dragging || dndArea.postDragging) && dndArea.draggedIndex != index
                                PropertyChanges {
                                    target: launcherDelegate
                                    angle: 0
                                    offset: 0
                                    itemOpacity: 0.6
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "selected"
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.FastDuration }
                            },
                            Transition {
                                from: "*"
                                to: "expanded"
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.FastDuration }
                                UbuntuNumberAnimation { properties: "angle,offset" }
                            },
                            Transition {
                                from: "expanded"
                                to: ""
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.BriskDuration }
                                UbuntuNumberAnimation { properties: "angle,offset" }
                            },
                            Transition {
                                id: draggingTransition
                                from: "selected"
                                to: "dragging"
                                SequentialAnimation {
                                    PropertyAction { target: launcherListView; property: "draggingTransitionRunning"; value: true }
                                    ParallelAnimation {
                                        UbuntuNumberAnimation { properties: "height" }
                                        NumberAnimation { target: dropIndicator; properties: "opacity"; duration: UbuntuAnimation.FastDuration }
                                    }
                                    ScriptAction {
                                        script: {
                                            if (launcherListView.scheduledMoveTo > -1) {
                                                launcherListView.model.move(dndArea.draggedIndex, launcherListView.scheduledMoveTo)
                                                dndArea.draggedIndex = launcherListView.scheduledMoveTo
                                                launcherListView.scheduledMoveTo = -1
                                            }
                                        }
                                    }
                                    PropertyAction { target: launcherListView; property: "draggingTransitionRunning"; value: false }
                                }
                            },
                            Transition {
                                from: "dragging"
                                to: "*"
                                NumberAnimation { target: dropIndicator; properties: "opacity"; duration: UbuntuAnimation.SnapDuration }
                                NumberAnimation { properties: "itemOpacity"; duration: UbuntuAnimation.BriskDuration }
                                SequentialAnimation {
                                    ScriptAction { script: if (index == launcherListView.count-1) launcherListView.flick(0, -launcherListView.clickFlickSpeed); }
                                    UbuntuNumberAnimation { properties: "height" }
                                    ScriptAction { script: if (index == launcherListView.count-1) launcherListView.flick(0, -launcherListView.clickFlickSpeed); }
                                    PropertyAction { target: dndArea; property: "postDragging"; value: false }
                                    PropertyAction { target: dndArea; property: "draggedIndex"; value: -1 }
                                }
                            }
                        ]
                    }

                    MouseArea {
                        id: dndArea
                        objectName: "dndArea"
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors {
                            fill: parent
                            topMargin: launcherListView.topMargin
                            bottomMargin: launcherListView.bottomMargin
                        }
                        drag.minimumY: -launcherListView.topMargin
                        drag.maximumY: height + launcherListView.bottomMargin

                        property int draggedIndex: -1
                        property var selectedItem
                        property bool preDragging: false
                        property bool dragging: !!selectedItem && selectedItem.dragging
                        property bool postDragging: false
                        property int startX
                        property int startY

                        onPressed: {
                            processPress(mouse);
                        }

                        function processPress(mouse) {
                            selectedItem = launcherListView.itemAt(mouse.x, mouse.y + launcherListView.realContentY)
                        }

                        onClicked: {
                            var index = Math.floor((mouseY + launcherListView.realContentY) / launcherListView.realItemHeight);
                            var clickedItem = launcherListView.itemAt(mouseX, mouseY + launcherListView.realContentY)

                            // Check if we actually clicked an item or only at the spacing in between
                            if (clickedItem === null) {
                                return;
                            }

                            if (mouse.button & Qt.RightButton) { // context menu
                                // Opening QuickList
                                quickList.open(index);
                                return;
                            }

                            Haptics.play();

                            // First/last item do the scrolling at more than 12 degrees
                            if (index == 0 || index == launcherListView.count - 1) {
                                if (clickedItem.angle > 12 || clickedItem.angle < -12) {
                                    launcherListView.moveToIndex(index);
                                } else {
                                    root.applicationSelected(LauncherModel.get(index).appId);
                                }
                                return;
                            }

                            // the rest launches apps up to an angle of 30 degrees
                            if (clickedItem.angle > 30 || clickedItem.angle < -30) {
                                launcherListView.moveToIndex(index);
                            } else {
                                root.applicationSelected(LauncherModel.get(index).appId);
                            }
                        }

                        onCanceled: {
                            endDrag(drag);
                        }

                        onReleased: {
                            endDrag(drag);
                        }

                        function endDrag(dragItem) {
                            var droppedIndex = draggedIndex;
                            if (dragging) {
                                postDragging = true;
                            } else {
                                draggedIndex = -1;
                            }

                            if (!selectedItem) {
                                return;
                            }

                            selectedItem.dragging = false;
                            selectedItem = undefined;
                            preDragging = false;

                            dragItem.target = undefined

                            progressiveScrollingTimer.stop();
                            launcherListView.interactive = true;
                            if (droppedIndex >= launcherListView.count - 2 && postDragging) {
                                snapToBottomAnimation.start();
                            } else if (droppedIndex < 2 && postDragging) {
                                snapToTopAnimation.start();
                            }
                        }

                        onPressAndHold: {
                            processPressAndHold(mouse, drag);
                        }

                        function processPressAndHold(mouse, dragItem) {
                            if (Math.abs(selectedItem.angle) > 30) {
                                return;
                            }

                            Haptics.play();

                            draggedIndex = Math.floor((mouse.y + launcherListView.realContentY) / launcherListView.realItemHeight);

                            quickList.open(draggedIndex)

                            launcherListView.interactive = false

                            var yOffset = draggedIndex > 0 ? (mouse.y + launcherListView.realContentY) % (draggedIndex * launcherListView.realItemHeight) : mouse.y + launcherListView.realContentY

                            fakeDragItem.iconName = launcherListView.model.get(draggedIndex).icon
                            fakeDragItem.x = units.gu(0.5)
                            fakeDragItem.y = mouse.y - yOffset + launcherListView.anchors.topMargin + launcherListView.topMargin
                            fakeDragItem.angle = selectedItem.angle * (root.inverted ? -1 : 1)
                            fakeDragItem.offset = selectedItem.offset * (root.inverted ? -1 : 1)
                            fakeDragItem.count = LauncherModel.get(draggedIndex).count
                            fakeDragItem.progress = LauncherModel.get(draggedIndex).progress
                            fakeDragItem.flatten()
                            dragItem.target = fakeDragItem

                            startX = mouse.x
                            startY = mouse.y
                        }

                        onPositionChanged: {
                            processPositionChanged(mouse)
                        }

                        function processPositionChanged(mouse) {
                            if (draggedIndex >= 0) {
                                if (!selectedItem.dragging) {
                                    var distance = Math.max(Math.abs(mouse.x - startX), Math.abs(mouse.y - startY))
                                    if (!preDragging && distance > units.gu(1.5)) {
                                        preDragging = true;
                                        quickList.state = "";
                                    }
                                    if (distance > launcherListView.itemHeight) {
                                        selectedItem.dragging = true
                                        preDragging = false;
                                    }
                                }
                                if (!selectedItem.dragging) {
                                    return
                                }

                                var itemCenterY = fakeDragItem.y + fakeDragItem.height / 2

                                // Move it down by the the missing size to compensate index calculation with only expanded items
                                itemCenterY += (launcherListView.itemHeight - selectedItem.height) / 2

                                if (mouseY > launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin - launcherListView.realItemHeight) {
                                    progressiveScrollingTimer.downwards = false
                                    progressiveScrollingTimer.start()
                                } else if (mouseY < launcherListView.realItemHeight) {
                                    progressiveScrollingTimer.downwards = true
                                    progressiveScrollingTimer.start()
                                } else {
                                    progressiveScrollingTimer.stop()
                                }

                                var newIndex = (itemCenterY + launcherListView.realContentY) / launcherListView.realItemHeight

                                if (newIndex > draggedIndex + 1) {
                                    newIndex = draggedIndex + 1
                                } else if (newIndex < draggedIndex) {
                                    newIndex = draggedIndex -1
                                } else {
                                    return
                                }

                                if (newIndex >= 0 && newIndex < launcherListView.count) {
                                    if (launcherListView.draggingTransitionRunning) {
                                        launcherListView.scheduledMoveTo = newIndex
                                    } else {
                                        launcherListView.model.move(draggedIndex, newIndex)
                                        draggedIndex = newIndex
                                    }
                                }
                            }
                        }
                    }
                    Timer {
                        id: progressiveScrollingTimer
                        interval: 2
                        repeat: true
                        running: false
                        property bool downwards: true
                        onTriggered: {
                            if (downwards) {
                                var minY =  -launcherListView.topMargin
                                if (launcherListView.contentY > minY) {
                                    launcherListView.contentY = Math.max(launcherListView.contentY - units.dp(2), minY)
                                }
                            } else {
                                var maxY = launcherListView.contentHeight - launcherListView.height + launcherListView.topMargin + launcherListView.originY
                                if (launcherListView.contentY < maxY) {
                                    launcherListView.contentY = Math.min(launcherListView.contentY + units.dp(2), maxY)
                                }
                            }
                        }
                    }
                }
            }

            LauncherDelegate {
                id: fakeDragItem
                objectName: "fakeDragItem"
                visible: dndArea.draggedIndex >= 0 && !dndArea.postDragging
                itemWidth: launcherListView.itemWidth
                itemHeight: launcherListView.itemHeight
                height: itemHeight
                width: itemWidth
                rotation: root.rotation
                itemOpacity: 0.9
                onVisibleChanged: if (!visible) iconName = "";

                function flatten() {
                    fakeDragItemAnimation.start();
                }

                UbuntuNumberAnimation {
                    id: fakeDragItemAnimation
                    target: fakeDragItem;
                    properties: "angle,offset";
                    to: 0
                }
            }
        }
    }

    UbuntuShapeForItem {
        id: quickListShape
        objectName: "quickListShape"
        anchors.fill: quickList
        opacity: quickList.state === "open" ? 0.95 : 0
        visible: opacity > 0
        rotation: root.rotation
        aspect: UbuntuShape.Flat

        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        image: quickList

        Image {
            anchors {
                right: parent.left
                rightMargin: -units.dp(4)
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -quickList.offset * (root.inverted ? -1 : 1)
            }
            height: units.gu(1)
            width: units.gu(2)
            source: "graphics/quicklist_tooltip.png"
            rotation: 90
        }
    }

    InverseMouseArea {
        anchors.fill: quickListShape
        enabled: quickList.state == "open" || pressed

        onClicked: {
            quickList.state = "";
            quickList.focus = false;
            root.kbdNavigationCancelled();
        }

        // Forward for dragging to work when quickList is open

        onPressed: {
            var m = mapToItem(dndArea, mouseX, mouseY)
            dndArea.processPress(m)
        }

        onPressAndHold: {
            var m = mapToItem(dndArea, mouseX, mouseY)
            dndArea.processPressAndHold(m, drag)
        }

        onPositionChanged: {
            var m = mapToItem(dndArea, mouseX, mouseY)
            dndArea.processPositionChanged(m)
        }

        onCanceled: {
            dndArea.endDrag(drag);
        }

        onReleased: {
            dndArea.endDrag(drag);
        }
    }

    Rectangle {
        id: quickList
        objectName: "quickList"
        color: theme.palette.normal.background
        // Because we're setting left/right anchors depending on orientation, it will break the
        // width setting after rotating twice. This makes sure we also re-apply width on rotation
        width: root.inverted ? units.gu(30) : units.gu(30)
        height: quickListColumn.height
        visible: quickListShape.visible
        anchors {
            left: root.inverted ? undefined : parent.right
            right: root.inverted ? parent.left : undefined
            margins: units.gu(1)
        }
        y: itemCenter - (height / 2) + offset
        rotation: root.rotation

        property var model
        property string appId
        property var item
        property int selectedIndex: -1

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Down:
                selectedIndex++;
                if (selectedIndex >= popoverRepeater.count) {
                    selectedIndex = 0;
                }
                event.accepted = true;
                break;
            case Qt.Key_Up:
                selectedIndex--;
                if (selectedIndex < 0) {
                    selectedIndex = popoverRepeater.count - 1;
                }
                event.accepted = true;
                break;
            case Qt.Key_Left:
            case Qt.Key_Escape:
                quickList.selectedIndex = -1;
                quickList.focus = false;
                quickList.state = ""
                event.accepted = true;
                break;
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Space:
                if (quickList.selectedIndex >= 0) {
                    LauncherModel.quickListActionInvoked(quickList.appId, quickList.selectedIndex)
                }
                quickList.selectedIndex = -1;
                quickList.focus = false;
                quickList.state = ""
                root.kbdNavigationCancelled();
                event.accepted = true;
                break;
            }
        }

        // internal
        property int itemCenter: item ? root.mapFromItem(quickList.item).y + (item.height / 2) + quickList.item.offset : units.gu(1)
        property int offset: itemCenter + (height/2) + units.gu(1) > parent.height ? -itemCenter - (height/2) - units.gu(1) + parent.height :
                             itemCenter - (height/2) < units.gu(1) ? (height/2) - itemCenter + units.gu(1) : 0

        function open(index) {
            var itemPosition = index * launcherListView.itemHeight;
            var height = launcherListView.height - launcherListView.topMargin - launcherListView.bottomMargin
            item = launcherListView.itemAt(launcherListView.width / 2, itemPosition + launcherListView.itemHeight / 2);
            quickList.model = launcherListView.model.get(index).quickList;
            quickList.appId = launcherListView.model.get(index).appId;
            quickList.state = "open";
        }

        Item {
            width: parent.width
            height: quickListColumn.height

            Column {
                id: quickListColumn
                width: parent.width
                height: childrenRect.height

                Repeater {
                    id: popoverRepeater
                    model: quickList.model

                    ListItem {
                        objectName: "quickListEntry" + index
                        selected: index === quickList.selectedIndex
                        height: label.implicitHeight + label.anchors.topMargin + label.anchors.bottomMargin
                        color: model.clickable ? (selected ? theme.palette.highlighted.background : "transparent") : theme.palette.disabled.background
                        highlightColor: !model.clickable ? quickList.color : undefined // make disabled items visually unclickable
                        divider.colorFrom: UbuntuColors.inkstone
                        divider.colorTo: UbuntuColors.inkstone

                        Label {
                            id: label
                            anchors.fill: parent
                            anchors.leftMargin: units.gu(3) // 2 GU for checkmark, 3 GU total
                            anchors.rightMargin: units.gu(2)
                            anchors.topMargin: units.gu(2)
                            anchors.bottomMargin: units.gu(2)
                            verticalAlignment: Label.AlignVCenter
                            text: model.label
                            fontSize: index == 0 ? "medium" : "small"
                            font.weight: index == 0 ? Font.Medium : Font.Light
                            color: model.clickable ? theme.palette.normal.backgroundText : theme.palette.disabled.backgroundText
                        }

                        onClicked: {
                            if (!model.clickable) {
                                return;
                            }
                            Haptics.play();
                            quickList.state = "";
                            // Unsetting model to prevent showing changing entries during fading out
                            // that may happen because of triggering an action.
                            LauncherModel.quickListActionInvoked(quickList.appId, index);
                            quickList.focus = false;
                            root.kbdNavigationCancelled();
                            quickList.model = undefined;
                        }
                    }
                }
            }
        }
    }
}
