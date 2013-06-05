/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

Column {
    property var model: undefined

    // Hud gives lots of results, make sure we have 5 at most
    // FIXME This should use SortFilterProxyModel
    // but there is a problem with the hud-service refreshing the
    // data for no reason so we use the internal model + timer
    // to fix those issues
    ListModel {
        id: internalModel
    }

    Connections {
        target: model
        // Accumulate count changes since hud clears
        // and then readds items to the models which means
        // even if the result is the same we get lots of count changes
        onCountChanged: updateModelTimer.restart()
    }

    onModelChanged: updateModelTimer.restart()

    Timer {
        id: updateModelTimer
        interval: 30
        onTriggered: updateModel()
    }

    function updateModel() {
        internalModel.clear()
        for (var i = 0; i < 5 && i < model.count; ++i) {
            var itemData = model.get(i)
            internalModel.append({"name": itemData.column_1, "highlights": itemData.column_2, "context": itemData.column_3, "contextHighlights": itemData.column_4})
        }
    }

    signal activated(int index)

    height: repeater.height

    Repeater {
        id: repeater
        objectName: "resultListRepeater"
        model: internalModel

        delegate: MouseArea {
            id: delegate
            height: result.height + separatorLine.height * 2
            anchors.left: parent.left
            anchors.right: parent.right

            onClicked: activated(index)

            BorderImage {
                id: separatorLine
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                source: "graphics/divider.sci"
                visible: index == 0
            }

            Result {
                id: result
                height: units.gu(6)
                anchors.top: separatorLine.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                nameText: name
                nameHighlights: highlights
                contextSnippetText: context
                contextSnippetHighlights: contextHighlights
            }

            BorderImage {
                anchors.top: result.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                source: "graphics/divider.sci"
            }

            Component.onCompleted: fadeIn.start()
            NumberAnimation { id: fadeIn; target: resultList; alwaysRunToEnd: true; property: "opacity"; duration: 200; from: 0; to: 1 }
        }
    }
}
