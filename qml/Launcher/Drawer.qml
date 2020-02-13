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
import Ubuntu.Components 1.3
import Unity.Launcher 0.1
import Utils 0.1
import "../Components"
import Qt.labs.settings 1.0
import GSettings  1.0
import AccountsService 0.1
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property int panelWidth: 0
    readonly property bool moving: (appList && appList.moving) ? true : false
    readonly property Item searchTextField: searchField
    readonly property real delegateWidth: units.gu(10)
    property url background
    visible: x > -width
    property var fullyOpen: x === 0
    property var fullyClosed: x === -width

    signal applicationSelected(string appId)

    // Request that the Drawer is opened fully, if it was partially closed then
    // brought back
    signal openRequested()

    // Request that the Drawer (and maybe its parent) is hidden, normally if
    // the Drawer has been dragged away.
    signal hideRequested()

    property bool allowSlidingAnimation: false
    property bool draggingHorizontally: false
    property int dragDistance: 0

    property var hadFocus: false
    property var oldSelectionStart: null
    property var oldSelectionEnd: null

    anchors {
        onRightMarginChanged: {
            if (fullyOpen && hadFocus) {
                // See onDraggingHorizontallyChanged below
                searchField.focus = hadFocus;
                searchField.select(oldSelectionStart, oldSelectionEnd);
            } else if (fullyClosed || fullyOpen) {
                searchField.text = "";
                resetOldFocus();
            }
        }
    }

    Behavior on anchors.rightMargin {
        enabled: allowSlidingAnimation && !draggingHorizontally
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    onDraggingHorizontallyChanged: {
        if (draggingHorizontally) {
            // Remove (and put back using anchors.onRightMarginChanged) the
            // focus for the searchfield in order to hide the copy/paste
            // popover when we move the drawer
            hadFocus = searchField.focus;
            oldSelectionStart = searchField.selectionStart;
            oldSelectionEnd = searchField.selectionEnd;
            searchField.focus = false;
        } else {
            if (x < -units.gu(10)) {
                hideRequested();
            } else {
                openRequested();
            }
        }
    }

    Keys.onEscapePressed: {
        root.hideRequested()
    }

    onDragDistanceChanged: {
        anchors.rightMargin = Math.max(-drawer.width, anchors.rightMargin + dragDistance);
    }

    function resetOldFocus() {
        hadFocus = false;
        oldSelectionStart = null;
        oldSelectionEnd = null;
        appList.currentIndex = 0;
        searchField.focus = false;
        appList.focus = false;
    }

    function focusInput() {
        searchField.selectAll();
        searchField.focus = true;
    }

    function unFocusInput() {
        searchField.focus = false;
    }

    Keys.onPressed: {
        if (event.text.trim() !== "") {
            focusInput();
            searchField.text = event.text;
        }
        switch (event.key) {
            case Qt.Key_Right:
            case Qt.Key_Left:
            case Qt.Key_Down:
                appList.focus = true;
                break;
            case Qt.Key_Up:
                focusInput();
                break;
        }
        // Catch all presses here in case the navigation lets something through
        // We never want to end up in the launcher with focus
        event.accepted = true;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#111111"
        opacity: 0.99

        Wallpaper {
            id: background
            anchors.fill: parent
            source: root.background
        }

        FastBlur {
            anchors.fill: background
            source: background
            radius: 64
            cached: true
        }

        // Images with fastblur can't use opacity, so we'll put this on top
        Rectangle {
            anchors.fill: background
            color: parent.color
            opacity: 0.67
        }

        MouseArea {
            id: drawerHandle
            objectName: "drawerHandle"
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(2)
            property int oldX: 0

            onPressed: {
                handle.active = true;
                oldX = mouseX;
            }
            onMouseXChanged: {
                var diff = oldX - mouseX;
                root.draggingHorizontally |= diff > units.gu(2);
                if (!root.draggingHorizontally) {
                    return;
                }
                root.dragDistance += diff;
                oldX = mouseX
            }
            onReleased: reset()
            onCanceled: reset()

            function reset() {
                root.draggingHorizontally = false;
                handle.active = false;
            }

            Handle {
                id: handle
                anchors.fill: parent
                active: parent.pressed
            }
        }

        AppDrawerModel {
            id: appDrawerModel
        }

        AppDrawerProxyModel {
            id: sortProxyModel
            source: appDrawerModel
            filterString: searchField.displayText
            sortBy: AppDrawerProxyModel.SortByAToZ
        }

        Item {
            id: contentContainer
            anchors {
                left: parent.left
                right: drawerHandle.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: root.panelWidth
            }

            Item {
                id: searchFieldContainer
                height: units.gu(4)
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }

                TextField {
                    id: searchField
                    objectName: "searchField"
                    inputMethodHints: Qt.ImhNoPredictiveText; //workaround to get the clear button enabled without the need of a space char event or change in focus
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                    placeholderText: i18n.tr("Search…")
                    z: 100

                    KeyNavigation.down: appList

                    onAccepted: {
                        if (searchField.displayText != "" && appList) {
                            // In case there is no currentItem (it might have been filtered away) lets reset it to the first item
                            if (!appList.currentItem) {
                                appList.currentIndex = 0;
                            }
                            root.applicationSelected(appList.getFirstAppId());
                        }
                    }
                }
            }

            DrawerGridView {
                id: appList
                objectName: "drawerAppList"
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchFieldContainer.bottom
                    bottom: parent.bottom
                }
                height: rows * delegateHeight
                clip: true

                model: sortProxyModel
                delegateWidth: root.delegateWidth
                delegateHeight: units.gu(11)
                delegate: drawerDelegateComponent
                onDraggingVerticallyChanged: {
                    if (draggingVertically) {
                        unFocusInput();
                    }
                }
            }
        }

        Component {
            id: drawerDelegateComponent
            AbstractButton {
                id: drawerDelegate
                width: GridView.view.cellWidth
                height: units.gu(11)
                objectName: "drawerItem_" + model.appId

                readonly property bool focused: index === GridView.view.currentIndex && GridView.view.activeFocus

                onClicked: root.applicationSelected(model.appId)
                onPressAndHold: {
                  if (model.appId.includes(".")) { // Open OpenStore page if app is a click
                    var splitAppId = model.appId.split("_");
                    Qt.openUrlExternally("https://open-store.io/app/" + model.appId.replace("_" + splitAppId[splitAppId.length-1],"") + "/");
                  }
                }
                z: loader.active ? 1 : 0

                Column {
                    width: units.gu(9)
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: childrenRect.height
                    spacing: units.gu(1)

                    UbuntuShape {
                        id: appIcon
                        width: units.gu(6)
                        height: 7.5 / 8 * width
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: "medium"
                        borderSource: 'undefined'
                        source: Image {
                            id: sourceImage
                            asynchronous: true
                            sourceSize.width: appIcon.width
                            source: model.icon
                        }
                        sourceFillMode: UbuntuShape.PreserveAspectCrop

                        StyledItem {
                            styleName: "FocusShape"
                            anchors.fill: parent
                            StyleHints {
                                visible: drawerDelegate.focused
                                radius: units.gu(2.55)
                            }
                        }
                    }

                    Label {
                        id: label
                        text: model.name
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSize: "small"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight

                        Loader {
                            id: loader
                            x: {
                                var aux = 0;
                                if (item) {
                                    aux = label.width / 2 - item.width / 2;
                                    var containerXMap = mapToItem(contentContainer, aux, 0).x
                                    if (containerXMap < 0) {
                                        aux = aux - containerXMap;
                                        containerXMap = 0;
                                    }
                                    if (containerXMap + item.width > contentContainer.width) {
                                        aux = aux - (containerXMap + item.width - contentContainer.width);
                                    }
                                }
                                return aux;
                            }
                            y: -units.gu(0.5)
                            active: label.truncated && (drawerDelegate.hovered || drawerDelegate.focused)
                            sourceComponent: Rectangle {
                                color: UbuntuColors.jet
                                width: fullLabel.contentWidth + units.gu(1)
                                height: fullLabel.height + units.gu(1)
                                radius: units.dp(4)
                                Label {
                                    id: fullLabel
                                    width: Math.min(root.delegateWidth * 2, implicitWidth)
                                    wrapMode: Text.Wrap
                                    horizontalAlignment: Text.AlignHCenter
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    anchors.centerIn: parent
                                    text: model.name
                                    fontSize: "small"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
