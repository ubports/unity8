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
import Ubuntu.Components 0.1

/*! \brief This component constructs the Preview UI.
 *
 *  Currently it displays all the widgets in a flickable column.
 */

Item {
    id: root

    /*! \brief Model containing preview widgets.
     *
     *  The model should expose "widgetId", "type" and "properties" roles, as well as
     *  have a triggered(QString widgetId, QString actionId, QVariantMap data) method,
     *  that's called when actions are executed in widgets.
     */
    property var previewModel

    //! \brief Should be set to true if this preview is currently displayed.
    property bool isCurrent: false

    //! \brief The ScopeStyle component.
    property var scopeStyle: null

    clip: true

    Binding {
        target: previewModel
        property: "widgetColumnCount"
        value: row.columns
    }

    MouseArea {
        anchors.fill: parent
    }

    Row {
        id: row

        spacing: units.gu(1)
        anchors { fill: parent; margins: spacing }

        property int columns: width >= units.gu(80) ? 2 : 1
        property real columnWidth: width / columns

        Repeater {
            id: repeater;
            model: previewModel

            function findChild(obj, objectName) {
                var childs = new Array(0);
                childs.push(obj)
                while (childs.length > 0) {
                    if (childs[0].objectName === objectName) {
                        return childs[0]
                    }
                    for (var i in childs[0].data) {
                        childs.push(childs[0].data[i])
                    }
                    childs.splice(0, 1);
                }
                return null;
            }

            delegate: ListView {
                id: column
                objectName: "previewListRow" + index
                anchors { top: parent.top; bottom: parent.bottom }
                width: row.columnWidth
                spacing: row.spacing
                bottomMargin: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
                
                readonly property int inputMethodMargin: 30;
                property bool inputMethodVisible: Qt.inputMethod.visible;
                onInputMethodVisibleChanged: {
                    if (!inputMethodVisible)
                        return;

                    var textArea = null;
                    var contentItem = column.contentItem;
                    
                    var reviewTextArea = repeater.findChild(contentItem, "reviewTextArea");
                    if (reviewTextArea !== null && reviewTextArea.activeFocus) {
                        textArea = reviewTextArea;
                    }
                    
                    if (textArea === null) {
                        var commentTextArea = repeater.findChild(contentItem, "commentTextArea");
                        if (commentTextArea !== null && commentTextArea.activeFocus) {
                            textArea = commentTextArea;
                        }
                    }

                    if (textArea === null)
                        return;

                    var textAreaPos = textArea.mapToItem(column, 0, 0);
                    var textAreaGlobalHeight = textAreaPos.y + textArea.implicitHeight
                            + column.height / 2.0;

                    if (textAreaGlobalHeight > column.height) {
                        column.contentY += textAreaGlobalHeight - column.height + inputMethodMargin;
                    }
                }

                model: columnModel
                cacheBuffer: height

                Behavior on contentY { UbuntuNumberAnimation { } }

                delegate: PreviewWidgetFactory {
                    widgetId: model.widgetId
                    widgetType: model.type
                    widgetData: model.properties
                    isCurrentPreview: root.isCurrent
                    scopeStyle: root.scopeStyle
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                    }

                    onTriggered: {
                        previewModel.triggered(widgetId, actionId, data);
                    }

                    onFocusChanged: if (focus) column.positionViewAtIndex(index, ListView.Contain)

                    onHeightChanged: if (focus) column.positionViewAtIndex(index, ListView.Contain)
                }
            }
        }
    }
}
