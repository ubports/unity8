/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import "../../Components"

/*! \brief Preview widget for commenting.

    The widget can show a field to enter a comment.
    It is possible to customise the submit button's label by setting widgetData["submit-label"]
    The successeful submit emits triggered(widgetId, "commented", data),
    with data being {"comment": comment}.
*/

PreviewWidget {
    id: root
    implicitHeight: commentContainer.implicitHeight

    property alias commentText: commentTextArea.text

    function submit() {
        // checks if comment text area actually contains something
        if (commentTextArea.text === "") return;

        var data = { "comment": commentTextArea.text };
        triggered(root.widgetId, "commented", data);
    }

    Item {
        id: commentContainer
        implicitHeight: commentSubmitContainer.implicitHeight + anchors.topMargin

        readonly property real innerMargin: units.gu(1)

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        Item {
            id: commentSubmitContainer
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            implicitHeight: commentTextArea.implicitHeight + anchors.topMargin

            TextField {
                id: commentTextArea
                objectName: "commentTextArea"
                anchors {
                    top: parent.top
                    left: parent.left
                    right: submitButton.left
                    rightMargin: commentContainer.innerMargin
                }
            }

            Button {
                id: submitButton
                objectName: "submitButton"

                readonly property bool readyToSubmit: commentTextArea.text.length > 0

                anchors {
                    top: parent.top
                    right: parent.right
                }
                color: readyToSubmit ? Theme.palette.selected.base : Theme.palette.normal.base
                text: widgetData["submit-label"] || i18n.tr("Send")
                onClicked: {
                    if (readyToSubmit) root.submit()
                }
            }
        }
    }
}
