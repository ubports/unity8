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

FocusScope {
    id: root

    property int panelWidth: 0
    readonly property bool moving: singleGroupListView && singleGroupListView.moving
    readonly property Item searchTextField: searchField
    readonly property real delegateWidth: units.gu(10)

    signal applicationSelected(string appId)

    property bool firstOpen: true
    property bool draggingHorizontally: false
    property int dragDistance: 0

    function focusInput() {
        searchField.selectAll();
        searchField.focus = true;
    }

    Keys.onPressed: {
        if (event.text.trim() !== "") {
            focusInput();
            searchField.text = event.text;
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
            anchors.fill: parent
            anchors.leftMargin: root.panelWidth

            Item {
                id: searchFieldContainer
                height: units.gu(4)
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }

                TextField {
                    id: searchField
                    objectName: "searchField"
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                    }
                    placeholderText: i18n.tr("Search…")
                    z: 100

                    KeyNavigation.down: singleGroupListView

                    onAccepted: {
                        if (searchField.displayText != "" && singleGroupListView) {
                            // In case there is no currentItem (it might have been filtered away) lets reset it to the first item
                            if (!appList.currentItem) {
                                appList.currentIndex = 0;
                            }
                            root.applicationSelected(appList.getFirstAppId());
                        }
                    }
                }
            }

            FocusScope {
                id: headerFocusScope
                objectName: "headerFocusScope"
                KeyNavigation.up: searchField
                KeyNavigation.down: singleGroupListView
                KeyNavigation.backtab: searchField
                KeyNavigation.tab: singleGroupListView
                activeFocusOnTab: true

                GSettings {
                    id: settings
                    schema.id: "com.canonical.Unity8"
                }

                Keys.onPressed: {
                    switch (event.key) {
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                    case Qt.Key_Space:
                        trigger();
                        event.accepted = true;
                    }
                }

                function trigger() {
                    Qt.openUrlExternally(settings.appstoreUri)
                }
            }

            MouseArea {
                id: horizontalDragDetector
                parent: singleGroupListView
                anchors.fill: parent
                propagateComposedEvents: true
                property int oldX: 0
                onPressed: {
                    if (root.firstOpen) {
                        mouse.accepted = false;
                        root.firstOpen = false;
                        return;
                    }
                    oldX = mouseX;
                }
                onMouseXChanged: {
                    var diff = oldX - mouseX;
                    root.draggingHorizontally |= diff > units.gu(2);
                    if (!root.draggingHorizontally) {
                        return;
                    }
                    parent.interactive = false;
                    root.dragDistance += diff;
                    oldX = mouseX
                }
                onReleased: reset();
                onCanceled: reset();
                function reset() {
                    if (root.draggingHorizontally) {
                        root.draggingHorizontally = false;
                        parent.interactive = true;
                    }
                }
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchFieldContainer.bottom
                    bottom: parent.bottom
                }
                z: 1

                Flickable {
                    id: singleGroupListView
                    clip: true

                    contentHeight: appListContainer.height

                    anchors.fill: parent

                    Item {
                        id: appListContainer
                        width: parent.width - units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter

                        readonly property string appId: model.appId

                        // NOTE: Cannot use gridView.rows here as it would evaluate to 0 at first and only update later,
                        // which messes up the ListView.
                        height: (Math.ceil(appList.model.count / appList.columns) * appList.delegateHeight) + units.gu(2)

                        DrawerGridView {
                            id: appList
                            anchors { left: parent.left; top: parent.top; right: parent.right; topMargin: units.gu(1) }
                            height: rows * delegateHeight

                            interactive: false
                            focus: index == aToZListView.currentIndex

                            model: AppDrawerProxyModel {
                                id: categoryModel
                                source: sortProxyModel
                                dynamicSortFilter: false
                            }
                            delegateWidth: root.delegateWidth
                            delegateHeight: units.gu(11)
                            delegate: drawerDelegateComponent
                        }
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
