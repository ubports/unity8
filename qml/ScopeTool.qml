/*
* Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Thumbnailer 0.1 // Register support for image://thumbnailer/ and image://albumart/
import Utils 0.1
import Unity 0.2
import "Components"
import "Dash"

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(72)
    color: "#88FFFFFF"

    // Fake shell object
    QtObject {
        id: shell
    }

    // Fake greeter object
    QtObject {
        id: greeter
        property bool shown
    }

    // Fake panel object
    QtObject {
        id: panel
        signal searchClicked
    }


    Rectangle {
        anchors.fill: dashContent
        color: "#FCFCFC"
    }

    Image {
        anchors.fill: dashContent
        source: root.width > root.height ? "Dash/graphics/paper_landscape.png" : "Dash/graphics/paper_portrait.png"
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignRight
        verticalAlignment: Image.AlignTop
    }

    DashContent {
        id: dashContent

        property var scope: scopes.getScope(currentIndex)
        scopes: Scopes { }

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: controls.left
        }
    }

    Rectangle {
        id: controls
        color: "lightgrey"
        width: units.gu(40)
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors { fill: parent; margins: units.gu(1) }
            spacing: units.gu(1)

            Label {
                text: "Search query"
            }

            TextField {
                id: searchField
                anchors { left: parent.left; right: parent.right }

                onTextChanged: dashContent.scope.searchQuery = text

                Connections {
                    target: dashContent.scope
                    onSearchQueryChanged: searchField.text = dashContent.scope.searchQuery
                }
            }

            Label {
                text: "Category"
                height: units.gu(4)
                verticalAlignment: Text.AlignBottom
            }

            OptionSelector {
                id: categorySelector
                anchors { left: parent.left; right: parent.right }
                model: dashContent.scope ? dashContent.scope.categories : null

                property Item selectedItem

                delegate: OptionSelectorDelegate {
                    id: categoryDelegate
                    text: model.name
                    property string categoryId: model.categoryId
                    property string template: JSON.stringify(JSON.parse(model.rawRendererTemplate), null, "  ");

                    onSelectedChanged: if (selected) categorySelector.selectedItem = categoryDelegate
                }
            }

            TextArea {
                id: categoryJson
                width: parent.width
                autoSize: true
                readOnly: true
                text: categorySelector.selectedItem && categorySelector.selectedItem.template
            }

            Button {
                width: parent.width
                text: "Override category"
                onClicked: {
                    PopupUtils.open(categoryEditor)
                }
            }
        }
    }

    Component {
        id: categoryEditor

        ComposerSheet {
            id: sheet
            title: "Editing category definition"

            TextArea {
                id: categoryEditorArea
                anchors.fill: parent
                wrapMode: Text.WordWrap
                text: categoryJson.text
            }

            onCancelClicked: PopupUtils.close(sheet)
            onConfirmClicked: {
                PopupUtils.close(sheet);
                dashContent.scope.categories.overrideCategoryJson(categorySelector.selectedItem.categoryId, categoryEditorArea.text);
            }
        }
    }
}
