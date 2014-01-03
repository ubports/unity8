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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Unity 0.1
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


    Scopes {
        id: scopes
    }

    Rectangle {
        anchors.fill: scopeView
        color: "#FCFCFC"
    }

    GenericScopeView {
        id: scopeView

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: controls.left
        }

        scope: scopes.loaded ? scopes.get(scopeSelector.selectedIndex) : undefined
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

        Column {
            anchors { fill: parent; margins: units.gu(1) }
            spacing: units.gu(1)

            Label {
                text: "Search query"
            }

            TextField {
                id: searchField
                anchors { left: parent.left; right: parent.right }

                onTextChanged: scopeView.scope.searchQuery = text

                Connections {
                    target: scopeView.scope
                    onSearchQueryChanged: searchField.text = scopeView.scope.searchQuery
                }
            }

            Label {
                text: "Scope selection"
                height: units.gu(4)
                verticalAlignment: Text.AlignBottom
            }

            OptionSelector {
                id: scopeSelector
                anchors { left: parent.left; right: parent.right }

                model: scopes
                delegate: OptionSelectorDelegate {
                    text: model.title
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

                model: scopeView.scope ? scopeView.scope.categories : null
                delegate: OptionSelectorDelegate {
                    text: model.name
                }

                onSelectedIndexChanged: {
                    categoryJson.refreshText();
                }
            }

            Repeater {
                id: categoryRepeater
                model: categorySelector.model
                Item {
                    property var data: model.rawRendererTemplate
                    property var categoryId: model.categoryId
                    onDataChanged: {
                        if (model.index != categorySelector.selectedIndex) return;
                        categoryJson.refreshText();
                    }
                }
                onItemAdded: categoryJson.refreshText()
            }

            TextArea {
                id: categoryJson
                width: parent.width
                autoSize: true
                readOnly: true

                function refreshText() {
                    if (categoryRepeater.count > categorySelector.selectedIndex) {
                        var item = categoryRepeater.itemAt(categorySelector.selectedIndex);
                        if (item == null) return;
                        categoryJson.text = JSON.stringify(JSON.parse(item.data), null, "    ");
                    }
                }
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
                var categoryId = categoryRepeater.itemAt(categorySelector.selectedIndex).categoryId;
                scopeView.scope.categories.overrideCategoryJson(categoryId, categoryEditorArea.text);
            }
        }
    }
}
