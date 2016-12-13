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
    readonly property bool moving: listLoader.item && listLoader.item.moving

    signal applicationSelected(string appId)

    property bool draggingHorizontally: false
    property int dragDistance: 0

    onFocusChanged: {
        if (focus) {
            searchField.selectAll();
        }
    }

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

    Settings {
        property alias selectedTab: sections.selectedIndex
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        color: "#BF000000"

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

            TextField {
                id: searchField
                objectName: "searchField"
                anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                placeholderText: i18n.tr("Search…")
                focus: true

                KeyNavigation.down: sections

                onAccepted: {
                    if (searchField.displayText != "" && listLoader.item && listLoader.item.currentItem) {
                        root.applicationSelected(listLoader.item.getFirstAppId());
                    }
                }
            }

            Item {
                id: sectionsContainer
                anchors { left: parent.left; top: searchField.bottom; right: parent.right; }
                height: sections.height
                clip: true
                z: 2

                Sections {
                    id: sections
                    width: parent.width

                    KeyNavigation.up: searchField
                    KeyNavigation.down: headerFocusScope
                    KeyNavigation.backtab: searchField
                    KeyNavigation.tab: headerFocusScope

                    actions: [
                        Action {
                            text: i18n.ctr("Apps sorted alphabetically", "A-Z")
                        // TODO: Disabling this for now as we don't get the right input from u-a-l yet.
                        },
                        Action {
                            text: i18n.ctr("Most used apps", "Most used")
                        }
                    ]

                    Rectangle {
                        anchors.bottom: parent.bottom
                        height: units.dp(1)
                        color: 'gray'
                        width: contentContainer.width
                    }
                }
            }

            FocusScope {
                id: headerFocusScope
                KeyNavigation.up: sections
                KeyNavigation.down: listLoader.item
                KeyNavigation.backtab: sections
                KeyNavigation.tab: listLoader.item
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

            Loader {
                id: listLoader
                anchors { left: parent.left; top: sectionsContainer.bottom; right: parent.right; bottom: parent.bottom; leftMargin: units.gu(1); rightMargin: units.gu(1) }

                KeyNavigation.up: headerFocusScope
                KeyNavigation.down: searchField
                KeyNavigation.backtab: headerFocusScope
                KeyNavigation.tab: searchField

                sourceComponent: {
                    switch (sections.selectedIndex) {
                    case 0: return aToZComponent;
                    case 1: return mostUsedComponent;
                    }
                }
                Binding {
                    target: listLoader.item || null
                    property: "objectName"
                    value: "drawerItemList"
                }
            }

            MouseArea {
                parent: listLoader.item ? listLoader.item : null
                anchors.fill: parent
                propagateComposedEvents: true
                property int oldX: 0
                onPressed: {
                    oldX = mouseX;
                }
                onMouseXChanged: {
                    var diff = oldX - mouseX;
                    root.draggingHorizontally |= diff > units.gu(2);
                    if (!root.draggingHorizontally) {
                        return;
                    }
                    propagateComposedEvents = false;
                    parent.interactive = false;
                    root.dragDistance += diff;
                    oldX = mouseX
                }
                onReleased: {
                    if (root.draggingHorizontally) {
                        root.draggingHorizontally = false;
                        parent.interactive = true;
                    }
                    reactivateTimer.start();
                }
                Timer {
                    id: reactivateTimer
                    interval: 0
                    onTriggered: parent.propagateComposedEvents = true;
                }
            }

            Component {
                id: mostUsedComponent
                DrawerListView {
                    id: mostUsedListView

                    header: MoreAppsHeader {
                        width: parent.width
                        height: units.gu(6)
                        highlighted: headerFocusScope.activeFocus
                        onClicked: headerFocusScope.trigger();
                    }

                    model: AppDrawerProxyModel {
                        source: sortProxyModel
                        group: AppDrawerProxyModel.GroupByAll
                        sortBy: AppDrawerProxyModel.SortByUsage
                    }

                    delegate: UbuntuShape {
                        width: parent.width
                        color: "#20ffffff"
                        aspect: UbuntuShape.Flat
                        // NOTE: Cannot use gridView.rows here as it would evaluate to 0 at first and only update later,
                        // which messes up the ListView.
                        height: (Math.ceil(mostUsedGridView.model.count / mostUsedGridView.columns) * mostUsedGridView.delegateHeight) + units.gu(2)

                        readonly property string appId: model.appId

                        DrawerGridView {
                            id: mostUsedGridView
                            anchors.fill: parent
                            topMargin: units.gu(1)
                            bottomMargin: units.gu(1)
                            clip: true

                            interactive: true
                            focus: index == mostUsedListView.currentIndex

                            model: sortProxyModel

                            delegateWidth: units.gu(8)
                            delegateHeight: units.gu(10)
                            delegate: drawerDelegateComponent
                        }
                    }
                }
            }

            Component {
                id: aToZComponent
                DrawerListView {
                    id: aToZListView

                    header: MoreAppsHeader {
                        width: parent.width
                        height: units.gu(6)
                        highlighted: headerFocusScope.activeFocus
                        onClicked: headerFocusScope.trigger();
                    }

                    model: AppDrawerProxyModel {
                        source: sortProxyModel
                        sortBy: AppDrawerProxyModel.SortByAToZ
                        group: AppDrawerProxyModel.GroupByAToZ
                    }

                    delegate: UbuntuShape {
                        width: parent.width
                        color: "#20ffffff"
                        aspect: UbuntuShape.Flat

                        readonly property string appId: model.appId

                        // NOTE: Cannot use gridView.rows here as it would evaluate to 0 at first and only update later,
                        // which messes up the ListView.
                        height: (Math.ceil(gridView.model.count / gridView.columns) * gridView.delegateHeight) +
                                categoryNameLabel.implicitHeight + units.gu(2)

                        Label {
                            id: categoryNameLabel
                            anchors { left: parent.left; top: parent.top; right: parent.right; margins: units.gu(1) }
                            text: model.letter
                        }

                        DrawerGridView {
                            id: gridView
                            anchors { left: parent.left; top: categoryNameLabel.bottom; right: parent.right; topMargin: units.gu(1) }
                            height: rows * delegateHeight

                            interactive: true
                            focus: index == aToZListView.currentIndex
                            onFocusChanged: print("drawer grid", index, "has focus", focus)

                            onCurrentIndexChanged: print("grid currentIndex changed", currentIndex)

                            model: AppDrawerProxyModel {
                                id: categoryModel
                                source: sortProxyModel
                                filterLetter: model.letter
                            }
                            delegateWidth: units.gu(8)
                            delegateHeight: units.gu(10)
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
                height: units.gu(10)
                objectName: "drawerItem_" + model.appId

                readonly property bool focused: index === GridView.view.currentIndex && GridView.view.activeFocus

                onClicked: root.applicationSelected(model.appId)

                Column {
                    width: units.gu(8)
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: childrenRect.height
                    spacing: units.gu(1)

                    UbuntuShape {
                        id: appIcon
                        width: units.gu(6)
                        height: 7.5 / 8 * width
                        anchors.horizontalCenter: parent.horizontalCenter
                        backgroundMode: UbuntuShape.SolidColor
                        backgroundColor: UbuntuColors.lightGrey
                        radius: "medium"
                        borderSource: 'undefined'
                        source: Image {
                            id: sourceImage
                            sourceSize.width: appIcon.width
                            source: model.icon
                        }
                        sourceFillMode: UbuntuShape.PreserveAspectCrop

                        Image {
                            objectName: "focusRing"
                            anchors.centerIn: parent
                            height: width * 15 / 16
                            width: parent.width + units.gu(1)
                            source: "graphics/launcher-app-focus-ring.svg"
                            sourceSize.width: width
                            sourceSize.height: height
                            visible: drawerDelegate.focused
                        }
                    }

                    Label {
                        text: model.name
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        fontSize: "small"
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
