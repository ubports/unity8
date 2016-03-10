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
import Unity 0.2
import "../Components"
import "Previews" as Previews

Item {
    id: root

    property bool open: false
    property var scope: null
    property var scopeStyle: null
    property alias showSignatureLine: header.showSignatureLine
    property alias previewModel: preview.previewModel
    readonly property bool processing: previewModel && (!previewModel.loaded || previewModel.processingAction)

    signal backClicked()

    DashPageHeader {
        id: header
        objectName: "pageHeader"
        width: parent.width
        title: root.scope ? root.scope.name : ""
        showBackButton: true
        searchEntryEnabled: false
        scopeStyle: root.scopeStyle

        onBackClicked: root.backClicked()
    }

    onOpenChanged: {
        if (!open) {
            root.scope.cancelActivation();
        }
    }

    Previews.Preview {
        id: preview
        objectName: "preview"
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        scopeStyle: root.scopeStyle
    }

    MouseArea {
        id: processingMouseArea
        objectName: "processingMouseArea"
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        enabled: root.processing
    }
}
