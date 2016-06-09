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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Item {
    id: root

    property alias title: titleLabel.text
    property alias component: loader.sourceComponent
    property alias iconColor: titleLabel.color

    signal goPrevious

    RowLayout {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }
        spacing: units.gu(2)

        AbstractButton {
            id: navigationButton
            objectName: "navigationButton"
            Layout.preferredWidth: units.gu(3)
            Layout.preferredHeight: units.gu(3)
            Layout.alignment: Qt.AlignVCenter

            Icon {
                anchors.fill: parent
                name: "go-previous"
                color: titleLabel.color
            }

            onTriggered: {
                root.goPrevious();
            }
        }

        Label {
            id: titleLabel
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
        }

        Loader {
            id: loader
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: units.gu(3)
        }
    }
}
