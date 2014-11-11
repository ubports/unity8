/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import "../Components" as LocalComponents

LocalComponents.Page {
    title: i18n.tr("All done")
    forwardButtonSourceComponent: forwardButton
    hasBackButton: false

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(1)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            fontSize: "large"
            font.bold: true
            text: i18n.tr("Nice work!")
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Your phone is now ready to use.")
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Finish")
            onClicked: root.quitWizard()
        }
    }
}
